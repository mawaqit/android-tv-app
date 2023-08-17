import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/services/update_manager/update_manager.dart';
import 'package:mawaqit/src/widgets/update_manager/update_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLastUpdateDialogDate =
    'UpdateManagerDialogsMixin.last_update_dialog_date';
const _kLastUpdateVersion = 'UpdateManagerDialogsMixin.last_update_version';
const _kLastUpdateDialogSelection =
    'UpdateManagerDialogsMixin.last_update_dialog_selection';

mixin UpdateManagerDialogsMixin on UpdateManager {
  late SharedPreferences _prefs;

  String get lastDialogVersion => _prefs.getString(_kLastUpdateVersion) ?? '';
  String get lastDialogSelection =>
      _prefs.getString(_kLastUpdateDialogSelection) ?? '';
  String get lastDialogDate => _prefs.getString(_kLastUpdateDialogDate) ?? '';

  Future<void> setupPreferences(String version, String selection) async {
    await _prefs.setString(_kLastUpdateVersion, version);
    await _prefs.setString(_kLastUpdateDialogSelection, selection);
    await _prefs.setString(
      _kLastUpdateDialogDate,
      DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    return super.init();
  }

  @override
  Future<bool> shouldShowUpdateDialog(String newVersion) async {
    /// we having new version and we didn't show the dialog before
    if (lastDialogVersion != newVersion) return true;

    if (lastDialogSelection == 'later')
      return DateTime.tryParse(lastDialogDate)
              ?.isBefore(DateTime.now().add(Duration(days: -7))) ??
          true;

    /// if last update failed
    if (lastDialogSelection == 'update') return true;

    return false;
  }

  @override
  Future<bool> showUpdateDialog(String version) async {
    final value = await showDialog<bool>(
      context: AppRouter.navigationKey.currentContext!,
      builder: (context) => AppUpdateDialog(
        onLater: () async {
          await setupPreferences(version, 'later');
          Navigator.of(context).pop(false);
        },
        onUpdate: () {
          setupPreferences(version, 'update');
          Navigator.of(context).pop(true);
        },
        onNever: () {
          setupPreferences(version, 'never');
          Navigator.of(context).pop(false);
        },
      ),
    );

    return value ?? false;
  }

  @override
  bool compareTwoVersion({
    required String oldVersion,
    required String newVersion,
  }) {
    final oldVersionComponents = oldVersion
        .replaceAll(RegExp('-.*'), '')
        .replaceAll('\+.*', '')
        .split('.')
        .map((e) => e.padLeft(4, '0'))
        .join('');

    final newVersionComponents = newVersion
        .replaceAll(RegExp('-.*'), '')
        .replaceAll('\+.*', '')
        .split('.')
        .map((e) => e.padLeft(4, '0'))
        .join('');

    return int.parse(newVersionComponents) > int.parse(oldVersionComponents);
  }
}
