// audio_status.dart
import 'package:equatable/equatable.dart';

enum AudioStatus { playing, paused }

class AudioControlState extends Equatable {
  final AudioStatus status;
  final bool isLoading;
  final String? error;
  final bool shouldShowControls;
  final bool isConfigured; // Add this field

  const AudioControlState({
    this.status = AudioStatus.paused,
    this.isLoading = false,
    this.error,
    this.shouldShowControls = false,
    this.isConfigured = false, // Initialize it
  });

  AudioControlState copyWith({
    AudioStatus? status,
    bool? isLoading,
    String? error,
    bool? shouldShowControls,
    bool? isConfigured, // Add to copyWith
  }) {
    return AudioControlState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      shouldShowControls: shouldShowControls ?? this.shouldShowControls,
      isConfigured: isConfigured ?? this.isConfigured,
    );
  }

  @override
  List<Object?> get props => [status, isLoading, error, shouldShowControls, isConfigured];
}
