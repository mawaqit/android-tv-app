import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/pages/app_update/app_update_screen.dart';
import 'package:mawaqit/src/services/update_manager/dialogs_mixin.dart';
import 'package:mawaqit/src/services/update_manager/update_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MawaqitUpdateManager extends UpdateManager with UpdateManagerDialogsMixin {
  @override
  Future<String?> checkForUpdate() async {
    final currentVersion = await PackageInfo.fromPlatform().then(
      (value) => value.version,
    );
    final newVersion = await Api.getLatestVersion();

    if (compareTwoVersion(oldVersion: currentVersion, newVersion: newVersion)) return newVersion;

    return null;
  }

  @override
  Future<void> startUpdate() {
    return AppRouter.push(AppUpdateScreen());
  }
}
