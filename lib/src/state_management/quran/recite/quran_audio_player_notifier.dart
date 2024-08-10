import 'dart:async';
import 'dart:developer';
import 'dart:math' show Random;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
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
      final currentPlayerState = audioPlayer.playing ? AudioPlayerState.playing : AudioPlayerState.paused;
      state = AsyncData(
        state.value!.copyWith(
          surahName: localSuwar[index].name,
          playerState: currentPlayerState,
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
