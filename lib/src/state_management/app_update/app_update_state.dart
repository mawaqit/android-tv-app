
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

  AppUpdateState({
    required this.message,
    required this.releaseNote,
    required this.appUpdateStatus,
  });

  // Named constructor to create an initial state with default values.
  AppUpdateState.initial() : message = '', releaseNote = '' , appUpdateStatus = AppUpdateStatus.initial;

  AppUpdateState copyWith({
    String? message,
    String? releaseNote,
    AppUpdateStatus? appUpdateStatus,
  }) {
    return AppUpdateState(
      message: message ?? this.message,
      releaseNote: releaseNote ?? this.releaseNote,
      appUpdateStatus: appUpdateStatus ?? this.appUpdateStatus,
    );
  }

  @override
  List get props => [message, releaseNote, appUpdateStatus];
}
