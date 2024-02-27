import 'package:equatable/equatable.dart';

enum InAppUpdateStatus {
  idle,
  updateNotAvailable,
  updateAvailable,
  updateDownloaded,
  updateFailed,
}

class InAppUpdateState extends Equatable {
  final InAppUpdateStatus inAppUpdateStatus;

  InAppUpdateState({
    required this.inAppUpdateStatus,
  });

  factory InAppUpdateState.idle() {
    return InAppUpdateState(inAppUpdateStatus: InAppUpdateStatus.idle);
  }

  InAppUpdateState copyWith({
    InAppUpdateStatus? inAppUpdateStatus,
  }) {
    return InAppUpdateState(
      inAppUpdateStatus: inAppUpdateStatus ?? this.inAppUpdateStatus,
    );
  }

  @override
  List<Object> get props => [inAppUpdateStatus];
}
