import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/services/background_audio_schedule_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../../const/constants.dart';
import '../../../domain/model/quran/moshaf_model.dart';
import '../../../domain/model/quran/reciter_model.dart';
import 'audio_control_notifier.dart';
import 'schedule_listening_state.dart';

/// A notifier that manages the scheduling state for Quran recitation scheduling.
///
/// This class handles the persistence and management of schedule-related settings,
/// including time ranges, reciter selection, and playback preferences.
class ScheduleNotifier extends AsyncNotifier<ScheduleState> {
  late final SharedPreferences _prefs;
  final FlutterBackgroundService _service = FlutterBackgroundService();

  @override
  Future<ScheduleState> build() async {
    _prefs = await SharedPreferences.getInstance();
    await BackgroundAudioScheduleService.initialize();
    return _loadSavedSchedule();
  }

  /// Loads the saved schedule state from SharedPreferences.
  Future<ScheduleState> _loadSavedSchedule() async {
    final isScheduleEnabled = _prefs
            .getBool(BackgroundScheduleAudioServiceConstant.kScheduleEnabled) ??
        false;
    final startTime = _parseTimeOfDay(
        _prefs.getString(BackgroundScheduleAudioServiceConstant.kStartTime) ??
            '08:00');
    final endTime = _parseTimeOfDay(
        _prefs.getString(BackgroundScheduleAudioServiceConstant.kEndTime) ??
            '20:00');
    final isRandomEnabled =
        _prefs.getBool(BackgroundScheduleAudioServiceConstant.kRandomEnabled) ??
            false;

    final savedReciterName = _prefs
        .getString(BackgroundScheduleAudioServiceConstant.kSelectedReciter);
    final reciterList = state.value?.reciterList ?? [];

    final selectedReciter = _findSelectedReciter(savedReciterName, reciterList);
    final selectedMoshaf = _findSelectedMoshaf(selectedReciter);

    return ScheduleState(
      isScheduleEnabled: isScheduleEnabled,
      startTime: startTime,
      endTime: endTime,
      selectedReciter: selectedReciter,
      selectedMoshaf: selectedMoshaf,
      selectedSurahId:
          _prefs.getInt(BackgroundScheduleAudioServiceConstant.kSelectedSurah),
      isRandomEnabled: isRandomEnabled,
      reciterList: reciterList,
    );
  }

  /// Finds the selected reciter from the saved name and reciter list.
  ReciterModel? _findSelectedReciter(
      String? savedReciterName, List<ReciterModel> reciterList) {
    if (savedReciterName == null || reciterList.isEmpty) return null;

    return reciterList.firstWhere(
      (reciter) => reciter.name == savedReciterName,
      orElse: () => reciterList.first,
    );
  }

  /// Finds the selected moshaf for the given reciter.
  MoshafModel? _findSelectedMoshaf(ReciterModel? selectedReciter) {
    if (selectedReciter == null || selectedReciter.moshaf.isEmpty) return null;

    final savedMoshafId = _prefs
        .getString(BackgroundScheduleAudioServiceConstant.kSelectedMoshaf);
    if (savedMoshafId == null) return selectedReciter.moshaf.first;

    return selectedReciter.moshaf.firstWhere(
      (moshaf) => moshaf.id == savedMoshafId,
      orElse: () => selectedReciter.moshaf.first,
    );
  }

  /// Parses a time string in format "HH:mm" to TimeOfDay.
  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// Enables or disables the schedule.
  Future<void> setScheduleEnabled(bool enabled) async {
    if (enabled) {
      await _prefs.setBool(
          BackgroundScheduleAudioServiceConstant.kPendingSchedule, true);
    }

    state = AsyncData(state.value!.copyWith(isScheduleEnabled: enabled));

    if (!enabled) {
      await _disableSchedule();
      state = AsyncData(state.value!.copyWith(isScheduleEnabled: false));
    }
  }

  Future<void> setStartTime(TimeOfDay time) async {
    state = AsyncData(state.value!.copyWith(startTime: time));
  }

  /// Sets the end time for the schedule. Returns false if the end time is before start time.
  Future<bool> setEndTime(TimeOfDay time) async {
    final isValidEndTime = _isValidEndTime(time);
    if (isValidEndTime) {
      state = AsyncData(state.value!.copyWith(endTime: time));
    }
    return isValidEndTime;
  }

  bool _isValidEndTime(TimeOfDay time) {
    final startTime = state.value!.startTime;
    return time.hour > startTime.hour ||
        (time.hour == startTime.hour && time.minute > startTime.minute);
  }

  Future<void> setSelectedReciter(ReciterModel? reciter) async {
    state = AsyncData(state.value!.copyWith(
      selectedReciter: reciter,
      selectedMoshaf:
          reciter?.moshaf.isNotEmpty == true ? reciter!.moshaf.first : null,
      selectedSurahId: null,
      isRandomEnabled: false,
    ));
  }

  Future<void> setSelectedMoshaf(MoshafModel? moshaf) async {
    if (moshaf == null) {
      state = AsyncData(state.value!.copyWith(
        selectedMoshaf: null,
        selectedSurahId: null,
      ));
      return;
    }

    final currentReciter = state.value!.selectedReciter;
    if (currentReciter != null) {
      final exactMoshaf = _findExactMoshaf(currentReciter, moshaf);
      state = AsyncData(state.value!.copyWith(
        selectedReciter: currentReciter,
        selectedMoshaf: exactMoshaf,
        selectedSurahId: exactMoshaf.surahList.isNotEmpty
            ? exactMoshaf.surahList.first
            : null,
      ));
    }
  }

  MoshafModel _findExactMoshaf(ReciterModel reciter, MoshafModel moshaf) {
    return reciter.moshaf.firstWhere(
      (m) => m.id == moshaf.id,
      orElse: () => moshaf,
    );
  }

  void setRandomEnabled(bool enabled) {
    state = AsyncData(state.value!.copyWith(
      isRandomEnabled: enabled,
      selectedSurahId: enabled ? null : state.value!.selectedSurahId,
    ));
  }

  void setSelectedSurahId(int? surahId) {
    state = AsyncData(state.value!.copyWith(
      selectedSurahId: surahId,
      isRandomEnabled: surahId == null ? state.value!.isRandomEnabled : false,
    ));
  }

  /// Generates a list of random Surah URLs for playback.
  List<String> _generateRandomUrls() {
    final random = Random();
    final currentState = state.value!;
    final availableSurahs = currentState.selectedMoshaf!.surahList;
    final count = min(5, availableSurahs.length);

    return List.generate(count, (_) {
      final randomSurahId =
          availableSurahs[random.nextInt(availableSurahs.length)]
              .toString()
              .padLeft(3, '0');
      return '${currentState.selectedMoshaf!.server}$randomSurahId.mp3';
    });
  }

  /// Saves the current schedule configuration.
  Future<bool> saveSchedule() async {
    final currentState = state.value!;

    if (!_isValidScheduleState(currentState)) {
      return false;
    }

    await _disableSchedule();
    await _prefs
        .remove(BackgroundScheduleAudioServiceConstant.kPendingSchedule);
    await _savePreferences(currentState);

    final now = TimeOfDay.now();
    final isInRange = _isTimeInRange(
      now,
      currentState.startTime,
      currentState.endTime,
    );

    await _prefs.reload();
    _service.invoke('update_schedule');

    if (isInRange) {
      ref.read(audioControlProvider.notifier).togglePlayback();
      await _prefs.setBool(
          BackgroundScheduleAudioServiceConstant.kManualPause, false);
    }

    return true;
  }

  bool _isValidScheduleState(ScheduleState state) {
    return state.isScheduleEnabled == true &&
        state.selectedReciter != null &&
        state.selectedMoshaf != null &&
        (state.selectedSurahId != null || state.isRandomEnabled);
  }

  /// Saves the current state to SharedPreferences.
  Future<void> _savePreferences(ScheduleState currentState) async {
    final startTimeString = _formatTimeOfDay(currentState.startTime);
    final endTimeString = _formatTimeOfDay(currentState.endTime);

    await Future.wait([
      _prefs.setBool(
          BackgroundScheduleAudioServiceConstant.kScheduleEnabled, true),
      _prefs.setString(
          BackgroundScheduleAudioServiceConstant.kStartTime, startTimeString),
      _prefs.setString(
          BackgroundScheduleAudioServiceConstant.kEndTime, endTimeString),
      _prefs.setString(BackgroundScheduleAudioServiceConstant.kSelectedReciter,
          currentState.selectedReciter!.name),
      _prefs.setString(BackgroundScheduleAudioServiceConstant.kSelectedMoshaf,
          currentState.selectedMoshaf!.id.toString()),
      _prefs.setBool(BackgroundScheduleAudioServiceConstant.kRandomEnabled,
          currentState.isRandomEnabled),
    ]);

    await _savePlaybackPreferences(currentState);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _savePlaybackPreferences(ScheduleState currentState) async {
    if (currentState.isRandomEnabled) {
      final randomUrls = _generateRandomUrls();
      await Future.wait([
        _prefs.setStringList(
            BackgroundScheduleAudioServiceConstant.kRandomUrls, randomUrls),
        _prefs.remove(BackgroundScheduleAudioServiceConstant.kSelectedSurah),
        _prefs.remove(BackgroundScheduleAudioServiceConstant.kSelectedSurahUrl),
      ]);
    } else {
      await Future.wait([
        _prefs.setInt(BackgroundScheduleAudioServiceConstant.kSelectedSurah,
            currentState.selectedSurahId!),
        _prefs.setString(
            BackgroundScheduleAudioServiceConstant.kSelectedSurahUrl,
            currentState.selectedMoshaf!.server),
        _prefs.remove(BackgroundScheduleAudioServiceConstant.kRandomUrls),
      ]);
    }
  }

  /// Checks if the current time is within the scheduled range.
  bool _isTimeInRange(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final now = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    return startMinutes <= endMinutes
        ? now >= startMinutes && now < endMinutes
        : now >= startMinutes || now < endMinutes;
  }

  /// Disables the current schedule and clears all related preferences.
  Future<void> _disableSchedule() async {
    await Future.wait([
      _prefs.setBool(BackgroundScheduleAudioServiceConstant.kManualPause, true),
      _prefs.remove(BackgroundScheduleAudioServiceConstant.kPendingSchedule),
      _prefs.remove(BackgroundScheduleAudioServiceConstant.kScheduleEnabled),
      _prefs.remove(BackgroundScheduleAudioServiceConstant.kStartTime),
      _prefs.remove(BackgroundScheduleAudioServiceConstant.kEndTime),
      _prefs.remove(BackgroundScheduleAudioServiceConstant.kSelectedReciter),
      _prefs.remove(BackgroundScheduleAudioServiceConstant.kSelectedMoshaf),
      _prefs.remove(BackgroundScheduleAudioServiceConstant.kSelectedSurah),
      _prefs.remove(BackgroundScheduleAudioServiceConstant.kSelectedSurahUrl),
      _prefs.remove(BackgroundScheduleAudioServiceConstant.kRandomEnabled),
      _prefs.remove(BackgroundScheduleAudioServiceConstant.kRandomUrls),
    ]);

    _service.invoke('kStopAudio');
    await _prefs.reload();
    _service.invoke('update_schedule');
  }

  Future<void> updateReciterList(List<ReciterModel> reciterList) async {
    state = AsyncData(state.value!.copyWith(reciterList: reciterList));
  }
}

/// Provider for the ScheduleNotifier.
final scheduleProvider = AsyncNotifierProvider<ScheduleNotifier, ScheduleState>(
  () => ScheduleNotifier(),
);
