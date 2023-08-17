import 'package:google_api_availability/google_api_availability.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/services/update_manager/google_play_manager.dart';
import 'package:mawaqit/src/services/update_manager/mawaqit_update_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// logic for updating the app
/// - check the latest build number from the google play
/// - check if that build number is downloaded and available on the desk
/// - If so, show a dialog to ask the user to install the update
/// - If not, Check if not check if device has google play services installed, use the google play services to do the update
/// - If not, show a dialog to ask the user to install the update from the browser
abstract class UpdateManager {
  static UpdateManager? _instance;

  UpdateManager();

  factory UpdateManager.instance() {
    _instance ??= new MawaqitUpdateManager();

    return _instance!;
  }

  Future<void> init() async {
    final hasGooglePlay = await GoogleApiAvailability.instance
        .checkGooglePlayServicesAvailability();

    /// if user have google play use it to update the app
    if (hasGooglePlay == GooglePlayServicesAvailability.success)
      _instance = GooglePlayUpdateImpl();

    final newVersion = await checkForUpdate();
    if (newVersion == null) return;

    final showDialog = await shouldShowUpdateDialog(newVersion);

    if (!showDialog) return;

    final update = await showUpdateDialog(newVersion);

    if (!update) return;

    await startUpdate();
  }

  Future<String?> checkForUpdate();

  bool compareTwoVersion({
    required String oldVersion,
    required String newVersion,
  });

  Future<String> currentAppVersion() =>
      PackageInfo.fromPlatform().then((value) => value.version);

  /// check to show the update dialog or not
  Future<bool> shouldShowUpdateDialog(String newVersion);

  /// show the update dialog
  Future<bool> showUpdateDialog(String newVersion);

  /// start the update process
  Future<void> startUpdate();
}
