import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';
import 'package:mawaqit/src/state_management/quran/recite/quran_audio_player_state.dart';

import '../../../data/repository/quran/recite_impl.dart';
import '../../../domain/model/quran/audio_file_model.dart';
import '../../../helpers/connectivity_provider.dart';
import '../../../models/address_model.dart';
import 'download_audio_quran/download_audio_quran_notifier.dart';
import 'download_audio_quran/download_audio_quran_state.dart';

class QuranAudioPlayer extends AsyncNotifier<QuranAudioPlayerState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  late ConcatenatingAudioSource playlist;
  int index = 0;
  List<SurahModel> localSuwar = [];
  late StreamSubscription<int?> currentIndexSubscription;

  @override
  QuranAudioPlayerState build() {
    ref.onDispose(() {
      audioPlayer.dispose();
      currentIndexSubscription.cancel();
      log('quran: QuranAudioPlayer: disposed');
    });
    log('quran: QuranAudioPlayer: build');

    return QuranAudioPlayerState(
      playerState: AudioPlayerState.stopped,
      audioPlayer: audioPlayer,
      position: Duration.zero,
      reciterName: '',
      surahName: '',
    );
  }

  Future<void> downloadAudio({
    required String reciterId,
    required String moshafId,
    required int surahId,
    required String url,
  }) async {
    final audioRepository = await ref.read(reciteImplProvider.future);
    final audioFileModel = AudioFileModel(
      reciterId,
      moshafId,
      surahId.toString(),
      url,
    );

    final downloadStateNotifier = ref.read(
      downloadStateProvider(
        DownloadStateProviderParameter(reciterId: reciterId, moshafId: moshafId),
      ).notifier,
    );

    downloadStateNotifier.updateDownloadProgress(surahId, 0);

    try {
      await audioRepository.downloadAudio(audioFileModel, (progress) {
        downloadStateNotifier.updateDownloadProgress(surahId, progress / 100);
      });

      downloadStateNotifier.markAsDownloaded(surahId);

      await getDownloadedSuwarByReciterAndRiwayah(
        moshafId: moshafId,
        reciterId: reciterId,
      );

      await refreshPlaylist();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> refreshPlaylist() async {
    final currentIndex = audioPlayer.currentIndex;
    await audioPlayer.setAudioSource(playlist, initialIndex: currentIndex);
    await _updatePlayerState();
  }

  Future<void> _updatePlayerState() async {
    final index = audioPlayer.currentIndex ?? 0;
    final position = audioPlayer.position;

    if (index < localSuwar.length) {
      state = AsyncData(
        state.value!.copyWith(
          surahName: localSuwar[index].name,
          playerState: audioPlayer.playing ? AudioPlayerState.playing : AudioPlayerState.paused,
          position: position,
        ),
      );
    }
  }

  Future<int> _downloadAllSuwar(
    List<SurahModel> suwar,
    String reciterId,
    String moshafId,
    String server,
  ) async {
    final downloadStateNotifier = ref.read(
      downloadStateProvider(
        DownloadStateProviderParameter(reciterId: reciterId, moshafId: moshafId),
      ).notifier,
    );

    int downloadedCount = 0;
    for (final surah in suwar) {
      final downloadState = ref.read(
        downloadStateProvider(
          DownloadStateProviderParameter(reciterId: reciterId, moshafId: moshafId),
        ),
      );
      if (!downloadState.downloadedSuwar.contains(surah.id)) {
        downloadStateNotifier.setDownloadStatus(DownloadStatus.downloading);
        await downloadAudio(
          reciterId: reciterId,
          moshafId: moshafId,
          surahId: surah.id,
          url: surah.getSurahUrl(server),
        );
        downloadedCount++;
      }
    }
    return downloadedCount;
  }

  Future<void> downloadAllSuwar({
    required String reciterId,
    required String moshafId,
    required MoshafModel moshaf,
    required List<SurahModel> suwar,
  }) async {
    try {
      state = AsyncLoading();
      final downloadedCount = await _downloadAllSuwar(
        suwar,
        reciterId,
        moshafId,
        moshaf.server,
      );
      state = AsyncData(state.value!);

      final downloadStateNotifier = ref.read(
        downloadStateProvider(
          DownloadStateProviderParameter(reciterId: reciterId, moshafId: moshafId),
        ).notifier,
      );

      if (downloadedCount > 0) {
        downloadStateNotifier.setDownloadStatus(DownloadStatus.completed);
      } else {
        downloadStateNotifier.setDownloadStatus(DownloadStatus.noNewDownloads);
      }
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> getDownloadedSuwarByReciterAndRiwayah({
    required String reciterId,
    required String moshafId,
  }) async {
    final audioRepository = await ref.read(reciteImplProvider.future);
    state = AsyncLoading();
    try {
      final downloadedAudioList = await audioRepository.getDownloadedSuwarByReciterAndRiwayah(
        reciterId: reciterId,
        moshafId: moshafId,
      );

      final downloadedSurahIds =
          downloadedAudioList.map((file) => int.parse(file.path.split('/').last.split('.').first)).toSet();

      final downloadStateNotifier = ref.read(downloadStateProvider(
        DownloadStateProviderParameter(reciterId: reciterId, moshafId: moshafId),
      ).notifier);

      downloadStateNotifier.initializeDownloadedSuwar(downloadedSurahIds);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  void initialize({
    required MoshafModel moshaf,
    required SurahModel surah,
    required List<SurahModel> suwar,
    required String reciterId,
  }) async {
    try {
      final audioRepository = await ref.read(reciteImplProvider.future);
      List<AudioSource> audioSources = [];
      localSuwar = [];

      for (var s in suwar) {
        bool isDownloaded = await audioRepository.isSurahDownloaded(
          reciterId: reciterId,
          moshafId: moshaf.id.toString(),
          surahNumber: s.id,
        );

        if (isDownloaded) {
          String localPath = await audioRepository.getLocalSurahPath(
            reciterId: reciterId,
            surahNumber: s.id.toString(),
            moshafId: moshaf.id.toString(),
          );
          audioSources.add(AudioSource.uri(Uri.file(localPath)));
          localSuwar.add(s);
          log('quran: QuranAudioPlayer: isDownloaded: ${s.name}, path: ${localPath}');
        } else if (ref.read(connectivityProvider).hasValue &&
            ref.read(connectivityProvider).value == ConnectivityStatus.connected) {
          audioSources.add(AudioSource.uri(Uri.parse(s.getSurahUrl(moshaf.server))));
          localSuwar.add(s);
          log('quran: QuranAudioPlayer: isOnline: ${s.name}, url: ${s.getSurahUrl(moshaf.server)}');
        }
      }

      if (audioSources.isEmpty) {
        throw Exception('No audio sources available');
      }

      playlist = ConcatenatingAudioSource(children: audioSources);
      index = localSuwar.indexOf(surah);
      await audioPlayer.setAudioSource(playlist, initialIndex: index);

      currentIndexSubscription = audioPlayer.currentIndexStream.listen((index) {
        log('quran: QuranAudioPlayer: currentIndexStream called');
        _updatePlayerState();
      });

      audioPlayer.playerStateStream.listen((playerState) {
        _updatePlayerState();
      });

      state = AsyncData(
        state.value!.copyWith(
          surahName: surah.name,
          reciterName: moshaf.name,
        ),
      );
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> play() async {
    state = AsyncData(
      state.value!.copyWith(
        playerState: AudioPlayerState.playing,
      ),
    );
    await audioPlayer.play();
  }

  Future<void> pause() async {
    state = AsyncData(
      state.value!.copyWith(
        playerState: AudioPlayerState.paused,
      ),
    );
    await audioPlayer.pause();
  }

  Future<void> stop() async {
    await audioPlayer.stop();
    state = AsyncData(
      state.value!.copyWith(
        playerState: AudioPlayerState.stopped,
      ),
    );
  }

  Future<void> seekTo(Duration position) async {
    try {
      await audioPlayer.seek(position);
      state = AsyncData(
        state.value!.copyWith(
          position: position,
        ),
      );
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  void dispose() {
    audioPlayer.dispose();
    state = AsyncData(
      state.value!.copyWith(
        playerState: AudioPlayerState.stopped,
      ),
    );
  }

  Future<void> seekToNext() async {
    try {
      await audioPlayer.seekToNext();
      log('quran: QuranAudioPlayer: seekToNext called');
    } catch (e, s) {
      log('quran: QuranAudioPlayer: seekToNext error: $e');
      state = AsyncError(e, s);
    }
  }

  Future<void> seekToPrevious() async {
    try {
      await audioPlayer.seekToPrevious();
      log('quran: QuranAudioPlayer: seekToPrevious called');
    } catch (e, s) {
      log('quran: QuranAudioPlayer: seekToPrevious error: $e');
      state = AsyncError(e, s);
    }
  }

  Future<void> shuffle() async {
    state = await AsyncValue.guard(() async {
      final bool isShuffled = !state.value!.isShuffled;
      await audioPlayer.setShuffleModeEnabled(isShuffled);
      return state.value!.copyWith(
        isShuffled: isShuffled,
      );
    });
  }

  Future<void> repeat() async {
    state = await AsyncValue.guard(() async {
      final isRepeating = !state.value!.isRepeating;
      if (isRepeating) {
        await audioPlayer.setLoopMode(LoopMode.one);
      } else {
        await audioPlayer.setLoopMode(LoopMode.off);
      }
      return state.value!.copyWith(
        isRepeating: isRepeating,
      );
    });
  }

  Future<void> toggleVolume() async {
    state = await AsyncValue.guard(() async {
      await Future.delayed(Duration(seconds: 1));
      return state.value!.copyWith(isVolumeOpened: !state.value!.isVolumeOpened);
    });
  }

  Future<void> closeVolume() async {
    state = await AsyncValue.guard(() async {
      await Future.delayed(Duration(seconds: 0));
      return state.value!.copyWith(isVolumeOpened: false);
    });
  }

  Future<void> resetIsVolumeOpened() async {
    state = await AsyncValue.guard(() async {
      return state.value!.copyWith(isVolumeOpened: false);
    });
  }

  Future<void> setVolume(double volume) async {
    if (volume < 0.0) volume = 0.0;
    if (volume > 1.0) volume = 1.0;

    await audioPlayer.setVolume(volume);
    state = AsyncData(
      state.value!.copyWith(
        volume: volume,
      ),
    );
  }

  Future<void> increaseVolume() async {
    final newVolume = (state.value!.volume + 0.1).clamp(0.0, 1.0);
    await setVolume(newVolume);
  }

  Future<void> decreaseVolume() async {
    final newVolume = (state.value!.volume - 0.1).clamp(0.0, 1.0);
    await setVolume(newVolume);
  }

  Stream<Duration> get positionStream => audioPlayer.positionStream;
}

final quranPlayerNotifierProvider =
    AsyncNotifierProvider<QuranAudioPlayer, QuranAudioPlayerState>(QuranAudioPlayer.new);
