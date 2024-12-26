// audio_control_state.dart

import 'package:equatable/equatable.dart';

enum AudioStatus {
  initial,    // Initial state before any playback
  playing,    // Currently playing
  paused,     // Paused
  stopped     // Completely stopped
}

class AudioControlState extends Equatable {
  final AudioStatus status;
  final String? currentAudioUrl;
  final Duration? position;      // Current playback position
  final Duration? duration;      // Total duration of current audio
  final double volume;          // Volume level (0.0 to 1.0)
  final bool isLooping;         // Is audio set to loop
  final bool isPlaylist;        // Whether current audio is part of playlist

  const AudioControlState({
    this.status = AudioStatus.initial,
    this.currentAudioUrl,
    this.position,
    this.duration,
    this.volume = 1.0,
    this.isLooping = false,
    this.isPlaylist = false,
  });

  AudioControlState copyWith({
    AudioStatus? status,
    String? currentAudioUrl,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isLooping,
    bool? isPlaylist,
  }) {
    return AudioControlState(
      status: status ?? this.status,
      currentAudioUrl: currentAudioUrl ?? this.currentAudioUrl,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isLooping: isLooping ?? this.isLooping,
      isPlaylist: isPlaylist ?? this.isPlaylist,
    );
  }

  bool get isPlaying => status == AudioStatus.playing;
  bool get isPaused => status == AudioStatus.paused;
  bool get isStopped => status == AudioStatus.stopped;
  bool get isInitial => status == AudioStatus.initial;
  bool get hasAudio => currentAudioUrl != null;

  // Progress as percentage (0.0 to 1.0)
  double get progress {
    if (position == null || duration == null) return 0.0;
    return position!.inMilliseconds / duration!.inMilliseconds;
  }

  @override
  List<Object?> get props => [
    status,
    currentAudioUrl,
    position,
    duration,
    volume,
    isLooping,
    isPlaylist,
  ];

  bool get showButton => isPlaying || isPaused || isStopped;

  bool get showPlaying => isPlaying;

  bool get showPaused => isPaused || isStopped;

  // Factory for initial state
  factory AudioControlState.initial() => const AudioControlState();
}
