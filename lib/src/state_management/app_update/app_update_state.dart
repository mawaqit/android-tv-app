import 'package:equatable/equatable.dart';

// Enum defining the various states of app update status.
enum AppUpdateStatus {
  openStore, // Indicates that the app store page should be opened.
  noUpdate, // Indicates there are no new updates available.
  updateAvailable, // Indicates a new update is available.
  initial, // Initial state, before any update check has occurred.
}

class AppUpdateState extends Equatable {
  final String message; // Message associated with the update status.
  final String releaseNote; // Release notes for the update.
  final AppUpdateStatus appUpdateStatus; // Current app update status.
  final bool isAutoUpdateChecking; // Indicates if an update is available.
  final bool isUpdateDismissed; // Indicates if the update prompt has been dismissed.

  AppUpdateState({
    required this.message,
    required this.releaseNote,
    required this.appUpdateStatus,
    required this.isUpdateDismissed,
    this.isAutoUpdateChecking = true,
  });

  // Named constructor to create an initial state with default values.
  AppUpdateState.initial()
      : message = '',
        releaseNote = '',
        appUpdateStatus = AppUpdateStatus.initial,
        isAutoUpdateChecking = true,
        isUpdateDismissed = false;

  AppUpdateState copyWith({
    String? message,
    String? releaseNote,
    AppUpdateStatus? appUpdateStatus,
    bool? isAutoUpdateChecking,
    bool? isUpdateDismissed,
  }) {
    return AppUpdateState(
      isAutoUpdateChecking: isAutoUpdateChecking ?? this.isAutoUpdateChecking,
      message: message ?? this.message,
      releaseNote: releaseNote ?? this.releaseNote,
      appUpdateStatus: appUpdateStatus ?? this.appUpdateStatus,
      isUpdateDismissed: isUpdateDismissed ?? this.isUpdateDismissed,
    );
  }

  @override
  List get props => [
        message,
        releaseNote,
        appUpdateStatus,
        isAutoUpdateChecking,
        isUpdateDismissed,
      ];
}
