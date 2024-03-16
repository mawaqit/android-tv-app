import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_store/open_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import '../../const/constants.dart';
import '../../helpers/AppDate.dart';
import 'app_update_state.dart';

class AppUpdateNotifier extends AsyncNotifier<AppUpdateState> {
  build() async {
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
      final upgrader = Upgrader(
        messages: UpgraderMessages(
          code: languageCode,
        ),
      );

      await upgrader.initialize(); // Prepares the Upgrader package for use.
      String? releaseNotes = upgrader.releaseNotes; // Retrieves release notes, if available.
      String message = upgrader.message(); // Constructs a message for the update prompt.
      final isUpdateAvailable = upgrader.isUpdateAvailable(); // Checks if an update is available.

      final isDisplayUpdate =
          await _shouldDisplayUpdate(prayerTimeList); // Determines if the update prompt should be displayed.

      if (isDisplayUpdate && isUpdateAvailable) {
        await shared.setInt('last_popup_display', DateTime.now().millisecondsSinceEpoch);
        return AppUpdateState(
          appUpdateStatus: AppUpdateStatus.updateAvailable,
          message: message,
          releaseNote: releaseNotes ?? '',
        );
      } else {
        return AppUpdateState(
          appUpdateStatus: AppUpdateStatus.noUpdate,
          message: '',
          releaseNote: '',
        );
      }
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

  /// [_shouldDisplayUpdate] Determines whether the update prompt should be displayed based on prayer times and the last time the prompt was shown.
  Future<bool> _shouldDisplayUpdate(List<String> prayerTimeList) async {
    final sharedPreferences = await ref.read(sharedPreferencesProvider.future);
    final DateTime now = DateTime.now().add(AppDateTime.difference);
    final lastPopupDisplay =
        sharedPreferences.getInt('last_popup_display') ?? 0; // // Gets the time of the last update prompt
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

    return isBetweenTwoPrays && isAfterOneWeek;
  }
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final appUpdateProvider = AsyncNotifierProvider<AppUpdateNotifier, AppUpdateState>(AppUpdateNotifier.new);
