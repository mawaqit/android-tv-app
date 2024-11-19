import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreUpdateLocalDataSource {
  final SharedPreferences _prefs;

  StoreUpdateLocalDataSource(this._prefs);

  Future<bool> isDismissed() async {
    return _prefs.getBool(CacheKey.kIsUpdateDismissed) ?? false;
  }

  Future<void> setDismissed(bool value) async {
    await _prefs.setBool(CacheKey.kIsUpdateDismissed, value);
  }

  Future<String?> getDismissedVersion() async {
    return _prefs.getString(CacheKey.kUpdateDismissedVersion);
  }

  Future<void> setDismissedVersion(String version) async {
    await _prefs.setString(CacheKey.kUpdateDismissedVersion, version);
  }

  Future<bool> isAutoUpdateEnabled() async {
    return _prefs.getBool(CacheKey.kAutoUpdateChecking) ?? false;
  }

  Future<void> setAutoUpdateEnabled(bool value) async {
    await _prefs.setBool(CacheKey.kAutoUpdateChecking, value);
  }

  // Future<DateTime?> getLastUpdateCheck() async {
  //   final timestamp = _prefs.getInt(CacheKey.kLastUpdateCheck);
  //   return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  // }
  //
  // Future<void> setLastUpdateCheck(DateTime timestamp) async {
  //   await _prefs.setInt(CacheKey.kLastUpdateCheck, timestamp.millisecondsSinceEpoch);
  // }
}

final storeUpdateLocalDataSourceProvider = FutureProvider<StoreUpdateLocalDataSource>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return StoreUpdateLocalDataSource(prefs);
});
