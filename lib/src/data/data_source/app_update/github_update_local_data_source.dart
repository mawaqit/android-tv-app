import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/state_management/app_update/app_update_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GithubUpdateLocalDataSource {
  final SharedPreferences _prefs;

  GithubUpdateLocalDataSource(this._prefs);

  Future<DateTime?> getLastUpdateCheck() async {
    final timestamp = _prefs.getInt(AppUpdateConstant.kLastUpdateCheck);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  Future<void> saveLastUpdateCheck(DateTime timestamp) async {
    await _prefs.setInt(AppUpdateConstant.kLastUpdateCheck, timestamp.millisecondsSinceEpoch);
  }

  Future<String?> getCurrentVersion() async {
    return _prefs.getString(AppUpdateConstant.kCurrentVersion);
  }

  Future<void> saveCurrentVersion(String version) async {
    await _prefs.setString(AppUpdateConstant.kCurrentVersion, version);
  }
}

final githubUpdateLocalDataSourceProvider = FutureProvider<GithubUpdateLocalDataSource>((ref) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  return GithubUpdateLocalDataSource(prefs);
});
