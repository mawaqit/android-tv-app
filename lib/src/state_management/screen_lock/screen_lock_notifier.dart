import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/helpers/TimeShiftManager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mawaqit/src/services/toggle_screen_feature_manager.dart';
import 'screen_lock_state.dart';

class ScreenLockNotifier extends AsyncNotifier<ScreenLockState> {
  ScreenLockNotifier();

  @override
  Future<ScreenLockState> build() async {
    return await _initializePreferences();
  }

  Future<ScreenLockState> _initializePreferences() async {
    final timeShiftManager = TimeShiftManager();
    final prefs = await SharedPreferences.getInstance();
    final isActive = await ToggleScreenFeature.getToggleFeatureState();

    return ScreenLockState(
      selectedTime:
          DateTime.now().add(Duration(hours: timeShiftManager.shift, minutes: timeShiftManager.shiftInMinutes)),
      isfajrIshaonly: prefs.getBool(TurnOnOffTvConstant.kisFajrIshaOnly) ?? false,
      isActive: isActive,
      selectedMinuteBefore: prefs.getInt(TurnOnOffTvConstant.kMinuteBeforeKey) ?? 30,
      selectedMinuteAfter: prefs.getInt(TurnOnOffTvConstant.kMinuteAfterKey) ?? 30,
    );
  }

  void toggleActive(bool newValue) async {
    final currentState = state.value!;
    state = AsyncValue.loading();
    ToggleScreenFeature.toggleFeatureState(newValue);

    if (!newValue) {
      await ToggleScreenFeature.cancelAllScheduledTimers();
    }

    state = AsyncValue.data(currentState.copyWith(isActive: newValue));
  }

  void adjustTimeFromTimePicker(DateTime selectedTime) {
    state = AsyncValue.data(state.value!.copyWith(selectedTime: selectedTime));
  }

  void selectNextMinuteBefore(int selectMinuteBefore) {
    final newMinute = (selectMinuteBefore + 1) % 60;
    state = AsyncValue.data(state.value!.copyWith(selectedMinuteBefore: newMinute < 10 ? 10 : newMinute));
  }

  void selectPreviousMinuteBefore(int selectMinuteBefore) {
    final newMinute = (selectMinuteBefore - 1 + 60) % 60;
    state = AsyncValue.data(state.value!.copyWith(selectedMinuteBefore: newMinute < 10 ? 59 : newMinute));
  }

  void selectNextMinuteAfter(int selectMinuteAfter) {
    final newMinute = (selectMinuteAfter + 1) % 60;
    state = AsyncValue.data(state.value!.copyWith(selectedMinuteAfter: newMinute < 10 ? 10 : newMinute));
  }

  void selectPreviousMinuteAfter(int selectMinuteAfter) {
    final newMinute = (selectMinuteAfter - 1 + 60) % 60;
    state = AsyncValue.data(state.value!.copyWith(selectedMinuteAfter: newMinute < 10 ? 59 : newMinute));
  }

  Future<void> saveSettings(List<String> times, bool isIshaFajrOnly) async {
    await ToggleScreenFeature.cancelAllScheduledTimers();
    ToggleScreenFeature.scheduleToggleScreen(
      isIshaFajrOnly,
      times,
      state.value!.selectedMinuteBefore,
      state.value!.selectedMinuteAfter,
    );
    ToggleScreenFeature.toggleFeatureState(true);

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(TurnOnOffTvConstant.kMinuteBeforeKey, state.value!.selectedMinuteBefore);
    prefs.setInt(TurnOnOffTvConstant.kMinuteAfterKey, state.value!.selectedMinuteAfter);
    prefs.setBool(TurnOnOffTvConstant.kisFajrIshaOnly, isIshaFajrOnly);
  }
}

final screenLockNotifierProvider = AsyncNotifierProvider<ScreenLockNotifier, ScreenLockState>(ScreenLockNotifier.new);
