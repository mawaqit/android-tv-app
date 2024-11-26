import 'package:equatable/equatable.dart';

enum UpdateStatus {
  initial,
  checking,
  available,
  notAvailable,
  downloading,
  installing,
  completed,
  error,
  cancelled,
}

class UpdateState extends Equatable {
  final UpdateStatus status;
  final double? progress;
  final String? message;
  final String? error;
  final String? downloadUrl;
  final String? filePath;
  final String? currentVersion;
  final String? availableVersion;

  const UpdateState({
    this.status = UpdateStatus.initial,
    this.progress,
    this.message,
    this.error,
    this.downloadUrl,
    this.filePath,
    this.currentVersion,
    this.availableVersion,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    double? progress,
    String? message,
    String? error,
    String? downloadUrl,
    String? filePath,
    String? currentVersion,
    String? availableVersion,
  }) {
    return UpdateState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      error: error ?? this.error,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      filePath: filePath ?? this.filePath,
      currentVersion: currentVersion ?? this.currentVersion,
      availableVersion: availableVersion ?? this.availableVersion,
    );
  }

  @override
  List<Object?> get props => [
        status,
        progress,
        message,
        error,
        downloadUrl,
        filePath,
      ];
}
