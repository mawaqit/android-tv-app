import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_store/open_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import '../../../main.dart';
import '../../const/constants.dart';
import '../../helpers/AppDate.dart';
import 'app_update_state.dart';

class AppUpdateNotifier extends AsyncNotifier<AppUpdateState> {
  @override
  Future<AppUpdateState> build() async {
    return AppUpdateState.initial();
  }

  /// [startScheduleUpdate] Initiates the process to check for app updates and updates the state accordingly. This method takes a `languageCode`
  ///
  /// to customize messages for the user and a list of `prayerTimeList` to determine the time of the prays to display update prompts.
  Future<void> startScheduleUpdate({
    required String languageCode,
    required List<String> prayerTimeList,
  }) async {
    state = AsyncLoading();
    final shared = await ref.read(sharedPreferencesProvider.future);
    state = await AsyncValue.guard(() async {
      final isAutoUpdateCheckingEnabled = shared.getBool(CacheKey.kAutoUpdateChecking) ?? true;
      final isDismissed = shared.getBool(CacheKey.kIsUpdateDismissed) ?? false;

      if (!isAutoUpdateCheckingEnabled) {
        return state.value!.copyWith(
          appUpdateStatus: AppUpdateStatus.noUpdate,
          isAutoUpdateChecking: false,
        );
      }

      final upgrader = Upgrader(
        messages: UpgraderMessages(
          code: languageCode,
        ),
      );
      await upgrader.initialize(); // Prepares the Upgrader package for use.
      String? releaseNotes = upgrader.releaseNotes; // Retrieves release notes, if available.
      String message = upgrader.message(); // Constructs a message for the update prompt.
      final isUpdateAvailable = upgrader.isUpdateAvailable(); // Checks if an update is available.

      final lastDismissedVersion = shared.getString(CacheKey.kUpdateDismissedVersion) ?? '0.0.0';

      logger.d(
          'AppUpdateNotifier: isDismissed: $isDismissed, isUpdateAvailable: $isUpdateAvailable, lastDismissedVersion: $lastDismissedVersion, message $message ');

      if (isDismissed &&
          isUpdateAvailable &&
          lastDismissedVersion != '0.0.0' &&
          lastDismissedVersion == upgrader.currentAppStoreVersion()) {
        return state.value!.copyWith(
          appUpdateStatus: AppUpdateStatus.noUpdate,
          isUpdateDismissed: true,
        );
      }

      final isDisplayUpdate =
          await _shouldDisplayUpdate(prayerTimeList); // Determines if the update prompt should be displayed.

      log('AppUpdateNotifier: isDisplayUpdate: $isDisplayUpdate, isUpdateAvailable: $isUpdateAvailable');

      if (isDisplayUpdate && isUpdateAvailable) {
        return state.value!.copyWith(
          appUpdateStatus: AppUpdateStatus.updateAvailable,
          message: message,
          releaseNote: releaseNotes ?? '',
        );
      } else {
        return state.value!.copyWith(
          appUpdateStatus: AppUpdateStatus.noUpdate,
          message: '',
          releaseNote: '',
        );
      }
    });
  }

  /// [dismissUpdate] Dismisses the update prompt and updates the state to indicate the prompt has been dismissed.
  Future<void> dismissUpdate() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final shared = await ref.read(sharedPreferencesProvider.future);
      await shared.setBool(CacheKey.kIsUpdateDismissed, true);

      final upgrader = Upgrader();
      await upgrader.initialize();

      await shared.setInt(CacheKey.kLastPopupDisplay, AppDateTime.now().millisecondsSinceEpoch);
      final latestAppStoreVersion = upgrader.currentAppStoreVersion();
      logger.d('AppUpdateNotifier: dismissUpdate: $latestAppStoreVersion');
      await shared.setString(CacheKey.kUpdateDismissedVersion, latestAppStoreVersion ?? '0.0.0');
      return state.value!.copyWith(appUpdateStatus: AppUpdateStatus.noUpdate, isUpdateDismissed: true);
    });
  }

  /// [openStore] Opens the store page for the app to facilitate updating. This method updates the state to indicate the store page is open.
  Future<void> openStore() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      OpenStore.instance.open(
        androidAppBundleId: kGooglePlayId,
      );
      return state.value!.copyWith(appUpdateStatus: AppUpdateStatus.openStore);
    });
  }

  /// [toggleAutoUpdateChecking] Toggles the auto-update checking feature on or off. This method updates the state to reflect the new setting.`
  Future<void> toggleAutoUpdateChecking() async {
    state = AsyncLoading();
    logger.d('AppUpdateNotifier: start toggleAutoUpdateChecking before');
    state = await AsyncValue.guard(() async {
      logger.d('AppUpdateNotifier: start toggleAutoUpdateChecking');
      final shared = await ref.read(sharedPreferencesProvider.future);
      final isAutoUpdateCheckingEnabled = shared.getBool(CacheKey.kAutoUpdateChecking) ?? true;
      await shared.setBool(CacheKey.kAutoUpdateChecking, !isAutoUpdateCheckingEnabled);
      logger.d('AppUpdateNotifier: change toggleAutoUpdateChecking into ${!isAutoUpdateCheckingEnabled}');
      return state.value!.copyWith(isAutoUpdateChecking: !isAutoUpdateCheckingEnabled);
    });
  }

  /// [_shouldDisplayUpdate] Determines whether the update prompt should be displayed based on prayer times and the last time the prompt was shown.
  Future<bool> _shouldDisplayUpdate(List<String> prayerTimeList) async {
    final sharedPreferences = await ref.read(sharedPreferencesProvider.future);
    final DateTime now = AppDateTime.now();
    final lastPopupDisplay =
        sharedPreferences.getInt(CacheKey.kLastPopupDisplay) ?? 0; // gets the time of the last update prompt
    final oneWeekAgo =
        now.subtract(Duration(days: 7)).millisecondsSinceEpoch; // Calculates the timestamp for one week ago.

    final DateFormat formatter = DateFormat.Hm();

    // Convert prayer times to DateTime objects for today
    final DateTime maghribTimeToday = formatter.parse(prayerTimeList[3]);
    final DateTime ishaTimeToday = formatter.parse(prayerTimeList[4]);
    final DateTime maghribDateTime =
        DateTime(now.year, now.month, now.day, maghribTimeToday.hour, maghribTimeToday.minute);
    final DateTime ishaDateTime = DateTime(now.year, now.month, now.day, ishaTimeToday.hour, ishaTimeToday.minute);

    // Compare only the current time's hour and minute with maghrib and isha times
    final isBetweenTwoPrays = now.isAfter(maghribDateTime) && now.isBefore(ishaDateTime);
    // Check if the last popup display was more than a week ago
    final bool isAfterOneWeek = lastPopupDisplay < oneWeekAgo;

    logger.d('AppUpdateNotifier: isBetweenTwoPrays: $isBetweenTwoPrays, isAfterOneWeek: $isAfterOneWeek');
    return isBetweenTwoPrays && isAfterOneWeek;
  }
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final appUpdateProvider = AsyncNotifierProvider<AppUpdateNotifier, AppUpdateState>(AppUpdateNotifier.new);
