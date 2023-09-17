import 'package:in_app_update/in_app_update.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/services/update_manager/dialogs_mixin.dart';
import 'package:mawaqit/src/services/update_manager/update_manager.dart';

class GooglePlayUpdateImpl extends UpdateManager with UpdateManagerDialogsMixin {
  @override
  Future<String?> checkForUpdate() async {
    final info = await InAppUpdate.checkForUpdate();

    if (info.updateAvailability == UpdateAvailability.updateAvailable) {
      return Api.getLatestVersion();
    } else {
      return null;
    }
  }

  @override
  Future<void> startUpdate() async {
    await InAppUpdate.performImmediateUpdate();
  }
}
