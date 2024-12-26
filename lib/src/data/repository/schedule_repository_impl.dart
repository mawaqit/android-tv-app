// data/repositories/schedule_repository_impl.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/state_management/app_update/app_update_notifier.dart';
import 'package:workmanager/workmanager.dart';
import 'package:mawaqit/src/data/repository/quran/recite_impl.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/domain/model/schedule_model.dart';
import 'package:mawaqit/src/domain/repository/schedule_repository.dart';
import 'package:mawaqit/src/helpers/language_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mawaqit/src/services/work_manager_callback.dart';

import 'package:mawaqit/src/const/constants.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final SharedPreferences _prefs;
  final ReciteImpl _reciteRepository;
  static const String backgroundTaskName = 'scheduleAudioTask';

  ScheduleRepositoryImpl(
      this._prefs,
      this._reciteRepository,
      ) {
    _initializeWorkManager();
  }

  Future<void> _initializeWorkManager() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  @override
  Future<ScheduleModel> getSchedule() async {
    final isScheduleEnabled = _prefs.getBool(BackgroundScheduleAudioServiceConstant.kScheduleEnabled) ?? false;
    final startTime = _parseTimeOfDay(
      _prefs.getString(BackgroundScheduleAudioServiceConstant.kStartTime) ?? ScheduleListeningConstant.startTime,
    );
    final endTime = _parseTimeOfDay(
      _prefs.getString(BackgroundScheduleAudioServiceConstant.kEndTime) ?? ScheduleListeningConstant.endTime,
    );
    final isRandomEnabled = _prefs.getBool(BackgroundScheduleAudioServiceConstant.kRandomEnabled) ?? false;
    final selectedSurahId = _prefs.getInt(BackgroundScheduleAudioServiceConstant.kSelectedSurah);

    final reciterList = await _getReciterList();
    final savedReciterName = _prefs.getString(BackgroundScheduleAudioServiceConstant.kSelectedReciter);
    final savedMoshafId = _prefs.getInt(BackgroundScheduleAudioServiceConstant.kSelectedMoshaf) ;

    ReciterModel? selectedReciter;
    if (savedReciterName != null && reciterList.isNotEmpty) {
      selectedReciter = reciterList.firstWhere(
            (reciter) => reciter.name == savedReciterName,
        orElse: () => reciterList.first,
      );
    }

    MoshafModel? selectedMoshaf;
    if (selectedReciter != null && savedMoshafId != null) {
      selectedMoshaf = selectedReciter.moshaf.firstWhere(
            (moshaf) => moshaf.id == savedMoshafId,
        orElse: () => selectedReciter!.moshaf.first,
      );
    }

    return ScheduleModel(
      isScheduleEnabled: isScheduleEnabled,
      startTime: startTime,
      endTime: endTime,
      selectedReciter: selectedReciter,
      selectedMoshaf: selectedMoshaf,
      selectedSurahId: selectedSurahId,
      isRandomEnabled: isRandomEnabled,
      reciterList: reciterList,
    );
  }

  @override
  Future<void> saveSchedule(ScheduleModel schedule) async {
    final startTimeString = _formatTimeOfDay(schedule.startTime);
    final endTimeString = _formatTimeOfDay(schedule.endTime);

    await Future.wait([
      _prefs.setBool(BackgroundScheduleAudioServiceConstant.kScheduleEnabled, schedule.isScheduleEnabled),
      _prefs.setString(BackgroundScheduleAudioServiceConstant.kStartTime, startTimeString),
      _prefs.setString(BackgroundScheduleAudioServiceConstant.kEndTime, endTimeString),
      _prefs.setBool(BackgroundScheduleAudioServiceConstant.kRandomEnabled, schedule.isRandomEnabled),
      if (schedule.selectedReciter != null)
        _prefs.setString(BackgroundScheduleAudioServiceConstant.kSelectedReciter, schedule.selectedReciter!.name),
      if (schedule.selectedMoshaf != null)
        _prefs.setInt(BackgroundScheduleAudioServiceConstant.kSelectedMoshaf, schedule.selectedMoshaf!.id),
      if (schedule.selectedSurahId != null)
        _prefs.setInt(BackgroundScheduleAudioServiceConstant.kSelectedSurah, schedule.selectedSurahId!),
    ]);

    if (schedule.isRandomEnabled) {
      final randomUrls = await generateRandomUrls(schedule);
      await _prefs.setStringList(BackgroundScheduleAudioServiceConstant.kRandomUrls, randomUrls);
      await _prefs.remove(BackgroundScheduleAudioServiceConstant.kSelectedSurah);
      await _prefs.remove(BackgroundScheduleAudioServiceConstant.kSelectedSurahUrl);
    } else {
      await _prefs.remove(BackgroundScheduleAudioServiceConstant.kRandomUrls);
      if (schedule.selectedMoshaf != null) {
        await _prefs.setString(
          BackgroundScheduleAudioServiceConstant.kSelectedSurahUrl,
          schedule.selectedMoshaf!.server,
        );
      }
    }

    await _scheduleTask(schedule);
  }

  Future<void> _scheduleTask(ScheduleModel schedule) async {
    if (schedule.isScheduleEnabled) {
      final startMinutes = schedule.startTime.hour * 60 + schedule.startTime.minute;
      await Workmanager().registerPeriodicTask(
        'scheduleAudio',
        backgroundTaskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        inputData: {
          'startMinutes': startMinutes,
          'endMinutes': schedule.endTime.hour * 60 + schedule.endTime.minute,
          'isRandomEnabled': schedule.isRandomEnabled,
        },
      );
    } else {
      await Workmanager().cancelByUniqueName('scheduleAudio');
    }
  }

  @override
  Future<void> disableSchedule() async {
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

    await Workmanager().cancelByUniqueName('scheduleAudio');
  }

  @override
  Future<List<String>> generateRandomUrls(ScheduleModel schedule) async {
    final random = Random();
    final availableSurahs = schedule.selectedMoshaf!.surahList;
    final count = min(5, availableSurahs.length);

    return List.generate(count, (_) {
      final randomSurahId = availableSurahs[random.nextInt(availableSurahs.length)].toString().padLeft(3, '0');
      return '${schedule.selectedMoshaf!.server}$randomSurahId.mp3';
    });
  }

  @override
  Future<void> updateBackgroundService() async {
    await _prefs.reload();
    final schedule = await getSchedule();
    await _scheduleTask(schedule);
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<List<ReciterModel>> _getReciterList() async {
    try {
      final languageCode = _prefs.getString('language_code') ?? 'en';
      final mappedLanguage = LanguageHelper.mapLocaleWithQuran(languageCode);
      final reciters = await _reciteRepository.getAllReciters(language: mappedLanguage);
      return reciters;
    } catch (e) {
      return [];
    }
  }
}

final scheduleRepositoryProvider = FutureProvider<ScheduleRepository>((ref) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  final reciteRepository = await ref.read(reciteImplProvider.future);
  return ScheduleRepositoryImpl(prefs, reciteRepository);
});
