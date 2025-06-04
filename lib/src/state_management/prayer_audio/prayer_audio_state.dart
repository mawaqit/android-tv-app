import 'package:just_audio/just_audio.dart';

class PrayerAudioState {
  final Duration? duration;
  final ProcessingState processingState;

  const PrayerAudioState({
    this.duration,
    this.processingState = ProcessingState.idle,
  });

  PrayerAudioState copyWith({
    Duration? duration,
    ProcessingState? processingState,
  }) {
    return PrayerAudioState(
      duration: duration ?? this.duration,
      processingState: processingState ?? this.processingState,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrayerAudioState && other.duration == duration && other.processingState == processingState;
  }

  @override
  int get hashCode => duration.hashCode ^ processingState.hashCode;

  @override
  String toString() => 'PrayerAudioState(duration: $duration, processingState: $processingState)';
}
