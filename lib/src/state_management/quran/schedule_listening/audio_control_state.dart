// audio_status.dart
import 'package:equatable/equatable.dart';

enum AudioStatus { playing, paused }

class AudioControlState extends Equatable {
  final AudioStatus status;
  final bool isLoading;
  final String? error;
  final bool shouldShowControls;

  const AudioControlState({
    this.status = AudioStatus.paused,
    this.isLoading = false,
    this.error,
    this.shouldShowControls = false,
  });

  AudioControlState copyWith({
    AudioStatus? status,
    bool? isLoading,
    String? error,
    bool? shouldShowControls,
  }) {
    return AudioControlState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      shouldShowControls: shouldShowControls ?? this.shouldShowControls,
    );
  }

  @override
  List<Object?> get props => [status, isLoading, error, shouldShowControls];
}
