import 'package:google_api_availability/google_api_availability.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:mawaqit/main.dart';

/// logic for updating the app
/// - check the latest build number from the google play
/// - check if that build number is downloaded and available on the desk
/// - If so, show a dialog to ask the user to install the update
/// - If not, Check if not check if device has google play services installed, use the google play services to do the update
/// - If not, show a dialog to ask the user to install the update from the browser
class UpdateManager {
  static Future<void> init() async {
    try {
      await checkForUpdate();
    } catch (e, error) {
      logger.w(e, 'Update manager', error);
    }
  }

  /// check if there is a new version of the app
  /// if there is a new version, this method will return true
  static Future<void> checkForUpdate([int? buildNumber]) async {
    await InAppUpdate.checkForUpdate().then((value) => logger.d(value));
    // final update = await AppVersionUpdate.checkForUpdates(country: 'fr', playStoreId: 'com.mawaqit.androidtv');
    //
    // logger.d(update.storeVersion);
  }

  /// show a dialog to ask the user to install the update
  /// handle if user clicked on later before
  /// handle if user clicked on update now
  static Future<void> showUpdateDialog() async {
    //
  }

  /// check if the device has google play services installed
  static Future<bool> checkGoogleService() async => GoogleApiAvailability.instance
      .checkGooglePlayServicesAvailability()
      .then((value) => value == GooglePlayServicesAvailability.success);

  static Future<void> triggerGoogleUpdate() async {}

  /// installed the downloaded apk file from the desk
  static Future<void> triggerAppUpdate() async {}

  /// if there are an already downloaded apk file, this method will return true
  /// save the build number of the downloaded apk file in the shared preferences
  static Future<void> checkForDownloadedUpdate() async {}

  /// download the apk file and save it in the device
  static Future<void> downloadUpdate() async {}
}
