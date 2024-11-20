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

  const UpdateState({
    this.status = UpdateStatus.initial,
    this.progress,
    this.message,
    this.error,
    this.downloadUrl,
    this.filePath,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    double? progress,
    String? message,
    String? error,
    String? downloadUrl,
    String? filePath,
  }) {
    return UpdateState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      error: error ?? this.error,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      filePath: filePath ?? this.filePath,
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
