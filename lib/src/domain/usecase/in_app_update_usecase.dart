import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import '../../data/data_source/in_app_update_data_source.dart';
import '../../state_management/in_app_update/in_app_update_state.dart';
import '../repository/in_app_update_repository.dart';

class InAppUpdateUseCase {
  final InAppUpdateRepository inAppUpdateRepository;
  final SharedPreferences sharedPreferences;

  InAppUpdateUseCase({
    required this.inAppUpdateRepository,
    required this.sharedPreferences,
  });

  Future<InAppUpdateStatus> checkForUpdateUseCase() async {
    final isAvailableUpdate = await inAppUpdateRepository.checkForUpdate();
    if (isAvailableUpdate) {
      return InAppUpdateStatus.updateAvailable;
    } else {
      return InAppUpdateStatus.updateNotAvailable;
    }
  }

  Future<InAppUpdateStatus> performImmediateUpdateUseCase() async {
    print('startFlexibleUpdateUseCase');
    final isAvailableUpdate = await inAppUpdateRepository.checkForUpdate();
    if (isAvailableUpdate) {
      await inAppUpdateRepository.performImmediateUpdate();
      return InAppUpdateStatus.updateDownloaded;
    } else {
      return InAppUpdateStatus.updateNotAvailable;
    }
  }

  Future<void> scheduleUpdateUseCase(List<String> prayerTimeList) async {
    // Retrieves the timestamp of the last popup display from SharedPreferences, defaulting to 0 if not set.
    final lastPopupDisplay = sharedPreferences.getInt('last_popup_display') ?? 0;

    logger.i('Last popup display: $lastPopupDisplay');

    // Calculates the timestamp for one week ago.
    final oneWeekAgo = DateTime.now().subtract(Duration(days: 7)).millisecondsSinceEpoch;
    // convert string 24 time to DateTime
    final maghribTime = DateFormat("H:mm").parse(prayerTimeList[3]);
    logger.i('in app update maghribTime: $maghribTime');
    final ishaTime = DateFormat("H:mm").parse(prayerTimeList[4]);
    logger.i('in app update ishaTime: $ishaTime');

    final isAvailableUpdate = await inAppUpdateRepository.checkForUpdate();

    if (DateTime.now().isAfter(maghribTime) &&
        DateTime.now().isBefore(ishaTime) &&
        DateTime.now().millisecondsSinceEpoch >= lastPopupDisplay + oneWeekAgo
        && isAvailableUpdate) {
      // Updates the 'last_popup_display' timestamp in SharedPreferences to the current time.
      final check = await sharedPreferences.setInt('last_popup_display', DateTime.now().millisecondsSinceEpoch);
      logger.d('update: check: $check');

      // Initiates the installation of the update.
      await performImmediateUpdateUseCase();
    } else {
      logger.i('update: no update available');
    }
  }
}

final inAppUpdateUseCaseProvider = FutureProvider<InAppUpdateUseCase>(
  (ref) async {
    SharedPreferences sharedPreference = await SharedPreferences.getInstance();
    final inAppUpdateRepository = ref.read(inAppUpdateDataSourceProvider);
    return InAppUpdateUseCase(
      inAppUpdateRepository: inAppUpdateRepository,
      sharedPreferences: sharedPreference,
    );
  },
);
