import 'package:mawaqit/src/domain/model/app_update_info.dart';
import 'package:mawaqit/src/domain/model/download_progress.dart';

abstract class AppUpdateRepository {
  // Core update checking and info
  Future<UpdateInfo> getLatestUpdate(String languageCode);

  Future<bool> isUpdateAvailable(String currentVersion, String languageCode);

  // Update actions
  Future<String?> downloadUpdate(String url, void Function(DownloadProgress) onProgress);

  Future<void> openStore();

  Future<void> cancelUpdate();

  // Update preferences
  Future<bool> isDismissed();

  Future<void> setDismissed(bool value);

  Future<bool> isAutoUpdateEnabled();

  Future<void> setAutoUpdateEnabled(bool value);

  Future<void> setDismissedVersion(String version);

  Future<String?> getDismissedVersion();

  // Update check timing
  Future<DateTime?> getLastUpdateCheck();

  Future<void> saveLastUpdateCheck(DateTime timestamp);
}
