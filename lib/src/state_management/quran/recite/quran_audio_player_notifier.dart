import 'dart:async';
import 'dart:developer';
import 'dart:math' show Random;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mawaqit/src/data/repository/quran/recite_impl.dart';
import 'package:mawaqit/src/domain/model/quran/audio_file_model.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';
import 'package:mawaqit/src/state_management/quran/recite/quran_audio_player_state.dart';

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

  void initialize({
    required MoshafModel moshaf,
    required SurahModel surah,
    required List<SurahModel> suwar,
  }) async {
    log('quran: QuranAudioPlayer: play audio: ${surah.name}, url ${surah.getSurahUrl(moshaf.server)}');

    playlist = ConcatenatingAudioSource(
      shuffleOrder: DefaultShuffleOrder(),
      children: suwar
          .map(
            (e) => AudioSource.uri(
              Uri.parse(
                e.getSurahUrl(moshaf.server),
              ),
            ),
          )
          .toList(),
    );
    index = suwar.indexOf(surah);
    localSuwar = suwar;
    await audioPlayer.setAudioSource(playlist, initialIndex: index);
    log('quran: QuranAudioPlayer: initialized ${surah.name}, url ${surah.getSurahUrl(moshaf.server)}');
    currentIndexSubscription = audioPlayer.currentIndexStream.listen((index) {
      log('quran: QuranAudioPlayer: currentIndexStream called');
      final index = audioPlayer.currentIndex ?? 0;
      state = AsyncData(
        state.value!.copyWith(
          surahName: localSuwar[index].name,
          playerState: AudioPlayerState.playing,
          reciterName: moshaf.name,
        ),
      );
    });
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
        downloadState: DownloadState.notDownloaded,
      );
    });
  }

  Future<void> downloadAndPlayAudio({
    required String reciterId,
    required String riwayahId,
    required String surahId,
    required String url,
    required String filename,
  }) async {
    final audioRepository = await ref.read(reciteImplProvider.future);
    final audioFileModel = AudioFileModel(
      reciterId,
      riwayahId,
      surahId,
      url,
    );

    state = AsyncLoading();
    try {
      final filePath = await audioRepository.downloadAudio(audioFileModel, (progress) {
        state = AsyncData(
          state.value!.copyWith(
            downloadProgress: progress.toInt(),
            downloadState: DownloadState.downloading,
          ),
        );
      });

      // Play the audio
      await audioPlayer.setFilePath(filePath);
      state = AsyncData(
        state.value!.copyWith(
          downloadState: DownloadState.downloaded,
        ),
      );
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> playLocalAudio({
    required String reciterId,
    required String riwayahId,
    required String surahId,
  }) async {
    final audioRepository = await ref.read(reciteImplProvider.future);
    final audioFileModel = AudioFileModel(
      reciterId,
      riwayahId,
      surahId,
      '',
    );

    state = AsyncLoading();
    try {
      final filePath = await audioRepository.getAudioPath(audioFileModel);
      await audioPlayer.setFilePath(filePath);
      await audioPlayer.play();

      state = AsyncData(
        state.value!.copyWith(
          downloadState: DownloadState.notDownloaded,
        ),
      );
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Stream<Duration> get positionStream => audioPlayer.positionStream;
}

final quranPlayerNotifierProvider =
    AsyncNotifierProvider<QuranAudioPlayer, QuranAudioPlayerState>(QuranAudioPlayer.new);
