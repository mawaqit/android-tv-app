import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/src/data/repository/app_update/app_update_repository_impl.dart';
import 'package:mawaqit/src/domain/repository/app_update/app_update_repository.dart';
import 'package:open_store/open_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import '../../../main.dart';
import '../../const/constants.dart';
import '../../helpers/AppDate.dart';
import '../../services/mosque_manager.dart';
import 'app_update_state.dart';

class AppUpdateNotifier extends AsyncNotifier<AppUpdateState> {
  Timer? _updateTimer;
  late final AppUpdateRepository _repository;

  @override
  Future<AppUpdateState> build() async {
    ref.onDispose(() {
      _updateTimer?.cancel();
    });

    // Initialize repository with parameters
    final params = AppUpdateRepositoryParameters(
      isRooted: false, // Set based on your root detection logic
      languageCode: 'en', // Set your default language
    );
    _repository = await ref.watch(appUpdateRepositoryProvider(params).future);

    return AppUpdateState.initial();
  }

  void startUpdateScheduler(MosqueManager mosque, String languageCode) {
    final now = AppDateTime.now();
    if (now.weekday == DateTime.friday) {
      final duration = _calculateDurationUntilThirtyMinutesAfterMaghrib(mosque, now);
      if (_updateTimer != null) _updateTimer!.cancel();
      _updateTimer = Timer(duration, () async {
        final today = mosque.useTomorrowTimes ? AppDateTime.tomorrow() : AppDateTime.now();
        final prays = mosque.times?.dayTimesStrings(today);
        await _startScheduleUpdate(
          languageCode: languageCode,
          prayerTimeList: prays ?? [],
        );
      });
    } else {
      log('AppUpdateNotifier: startUpdateScheduler: Today is not Friday. Skipping update scheduler.');
    }
  }

  Future<void> _startScheduleUpdate({
    required String languageCode,
    required List<String> prayerTimeList,
  }) async {
    state = const AsyncValue.loading();

    try {
      final isAutoUpdateEnabled = await _repository.isAutoUpdateEnabled();
      if (!isAutoUpdateEnabled) {
        state = AsyncValue.data(state.value!.copyWith(
          appUpdateStatus: AppUpdateStatus.noUpdate,
          isAutoUpdateChecking: false,
        ));
        return;
      }

      final isDismissed = await _repository.isDismissed();
      final lastDismissedVersion = await _repository.getDismissedVersion() ?? '0.0.0';
      final updateInfo = await _repository.getLatestUpdate(languageCode);
      final isUpdateAvailable = await _repository.isUpdateAvailable(lastDismissedVersion, languageCode);

      if (isDismissed && isUpdateAvailable && lastDismissedVersion == updateInfo.version) {
        state = AsyncValue.data(state.value!.copyWith(
          appUpdateStatus: AppUpdateStatus.noUpdate,
          isUpdateDismissed: true,
        ));
        return;
      }

      final isDisplayUpdate = await _shouldDisplayUpdate(prayerTimeList);

      if (isDisplayUpdate && isUpdateAvailable) {
        state = AsyncValue.data(state.value!.copyWith(
          appUpdateStatus: AppUpdateStatus.updateAvailable,
          message: updateInfo.message,
          releaseNote: updateInfo.releaseNotes,
        ));
      } else {
        state = AsyncValue.data(state.value!.copyWith(
          appUpdateStatus: AppUpdateStatus.noUpdate,
          message: '',
          releaseNote: '',
        ));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> dismissUpdate() async {
    state = const AsyncValue.loading();

    try {
      await _repository.setDismissed(true);
      final updateInfo = await _repository.getLatestUpdate('en');
      await _repository.setDismissedVersion(updateInfo.version);
      await _repository.saveLastUpdateCheck(DateTime.now());

      state = AsyncValue.data(state.value!.copyWith(
        appUpdateStatus: AppUpdateStatus.noUpdate,
        isUpdateDismissed: true,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> openStore() async {
    state = const AsyncValue.loading();

    try {
      await _repository.openStore();
      state = AsyncValue.data(state.value!.copyWith(
        appUpdateStatus: AppUpdateStatus.openStore,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleAutoUpdateChecking() async {
    state = const AsyncValue.loading();

    try {
      final isEnabled = await _repository.isAutoUpdateEnabled();
      await _repository.setAutoUpdateEnabled(!isEnabled);
      state = AsyncValue.data(state.value!.copyWith(
        isAutoUpdateChecking: !isEnabled,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Duration _calculateDurationUntilThirtyMinutesAfterMaghrib(MosqueManager mosque, DateTime currentDateTime) {
    // Your existing implementation
    final timeList = mosque.times?.dayTimesStrings(currentDateTime);
    final formatter = DateFormat.Hm();
    final maghribTimeToday = formatter.parse(timeList![3]);

    log('AppUpdateNotifier: startUpdateScheduler: maghribTimeToday: $maghribTimeToday');

    final maghribDateTime = DateTime(
      currentDateTime.year,
      currentDateTime.month,
      currentDateTime.day,
      maghribTimeToday.hour,
      maghribTimeToday.minute,
    );

    final thirtyMinutesAfterMaghrib = maghribDateTime.add(const Duration(minutes: 30));
    return thirtyMinutesAfterMaghrib.difference(currentDateTime);
  }

  Future<bool> _shouldDisplayUpdate(List<String> prayerTimeList) async {
    final lastCheck = await _repository.getLastUpdateCheck();
    if (lastCheck == null) return true;

    final now = AppDateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    if (lastCheck.isBefore(oneWeekAgo)) return true;

    final formatter = DateFormat.Hm();
    final maghribTime = formatter.parse(prayerTimeList[3]);
    final ishaTime = formatter.parse(prayerTimeList[4]);

    final maghribDateTime = DateTime(now.year, now.month, now.day, maghribTime.hour, maghribTime.minute);
    final ishaDateTime = DateTime(now.year, now.month, now.day, ishaTime.hour, ishaTime.minute);

    return now.isAfter(maghribDateTime) && now.isBefore(ishaDateTime);
  }
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final appUpdateProvider = AsyncNotifierProvider<AppUpdateNotifier, AppUpdateState>(AppUpdateNotifier.new);
