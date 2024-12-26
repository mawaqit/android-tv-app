// audio_control_notifier.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mawaqit/src/data/repository/audio_repostiory_impl.dart';
import 'package:mawaqit/src/domain/repository/audio_repository.dart';
import 'package:mawaqit/src/state_management/quran/schedule_listening/audio_control_state.dart';

class AudioNotifier extends AsyncNotifier<AudioControlState> {
  late final AudioRepository _repository;
  StreamSubscription? _playbackStateSubscription;

  @override
  Future<AudioControlState> build() async {
    _repository = ref.read(audioRepositoryProvider);
    await _repository.initialize();

    // Listen to playback state changes
    if (_repository is AudioRepositoryImpl) {
      _playbackStateSubscription?.cancel();
      _playbackStateSubscription =
          (_repository as AudioRepositoryImpl).playbackStateStream.listen(_handlePlaybackStateChange);
    }

    return AudioControlState.initial();
  }

  void _handlePlaybackStateChange(bool isPlaying) {
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.copyWith(
          status: isPlaying ? AudioStatus.playing : AudioStatus.paused,
        ),
      );
    }
  }

  Future<void> playAudio(String audioUrl, {bool createPlaylist = false}) async {
    try {
      state = const AsyncValue.loading();

      await _repository.playAudio(audioUrl, createPlaylist: createPlaylist);

      final player = _repository.player;

      // Update initial state
      state = AsyncValue.data(AudioControlState(
        status: AudioStatus.playing,
        currentAudioUrl: audioUrl,
        duration: player?.duration,
        isPlaylist: createPlaylist,
      ));

      // Setup position and duration listeners
      _setupPositionStream();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> stopPlayback() async {
    final currentState = state.value ?? AudioControlState.initial();

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.stopPlayback();
      return currentState.copyWith(
        status: AudioStatus.stopped,
        position: Duration.zero,
      );
    });
  }

  Future<void> pausePlayback() async {
    final currentState = state.value ?? AudioControlState.initial();

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.pausePlayback();
      return currentState.copyWith(
        status: AudioStatus.paused,
      );
    });
  }

  Future<void> resumePlayback() async {
    final currentState = state.value ?? AudioControlState.initial();

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.resumePlayback();
      return currentState.copyWith(
        status: AudioStatus.playing,
      );
    });
  }

  Future<void> setVolume(double volume) async {
    final currentState = state.value ?? AudioControlState.initial();

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.player?.setVolume(volume);
      return currentState.copyWith(
        volume: volume,
      );
    });
  }

  Future<void> setLooping(bool isLooping) async {
    final currentState = state.value ?? AudioControlState.initial();

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.player?.setLoopMode(
        isLooping ? LoopMode.one : LoopMode.off,
      );
      return currentState.copyWith(
        isLooping: isLooping,
      );
    });
  }

  void _setupPositionStream() {
    final player = _repository.player;
    if (player == null) return;

    player.positionStream.listen((position) {
      if (state.hasValue) {
        state = AsyncValue.data(state.value!.copyWith(
          position: position,
        ));
      }
    });

    player.durationStream.listen((duration) {
      if (state.hasValue) {
        state = AsyncValue.data(state.value!.copyWith(
          duration: duration,
        ));
      }
    });
  }

  bool isPlaying() => state.value?.isPlaying ?? false;
}

final audioNotifierProvider = AsyncNotifierProvider<AudioNotifier, AudioControlState>(() {
  return AudioNotifier();
});
