import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mawaqit/src/domain/error/prayer_audio_exceptions.dart';

@immutable
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

    return other is PrayerAudioState &&
        other.duration == duration &&
        other.processingState == processingState;
  }

  @override
  int get hashCode {
    return duration.hashCode ^ processingState.hashCode;
  }

  @override
  String toString() {
    return 'PrayerAudioState(duration: $duration, processingState: $processingState)';
  }
}
