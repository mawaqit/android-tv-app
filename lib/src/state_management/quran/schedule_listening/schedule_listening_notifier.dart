import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/data/repository/quran/quran_impl.dart';
import 'package:mawaqit/src/data/repository/schedule_repository_impl.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/domain/model/schedule_model.dart';
import 'package:mawaqit/src/domain/repository/schedule_repository.dart';
import 'package:mawaqit/src/helpers/language_helper.dart';
import 'package:mawaqit/src/module/shared_preference_module.dart';

import 'audio_control_notifier.dart';

class ScheduleNotifier extends AsyncNotifier<ScheduleModel> {
  late final ScheduleRepository _repository;

  @override
  Future<ScheduleModel> build() async {
    _repository = await ref.read(scheduleRepositoryProvider.future);
    return _repository.getSchedule();
  }

  void setScheduleEnabled(bool enabled) {
    state = AsyncValue.data(state.value!.copyWith(isScheduleEnabled: enabled));
    _saveSchedule();
  }

  void setStartTime(TimeOfDay time) {
    state = AsyncValue.data(state.value!.copyWith(startTime: time));
    _saveSchedule();
  }

  void setEndTime(TimeOfDay time) {
    state = AsyncValue.data(state.value!.copyWith(endTime: time));
    _saveSchedule();
  }

  Future<void> setSelectedReciter(ReciterModel reciter) async {
    state = AsyncValue.data(state.value!.copyWith(
      selectedReciter: reciter,
      selectedMoshaf: reciter.moshaf.isNotEmpty ? reciter.moshaf.first : null,
      selectedSurahId: reciter.moshaf.isNotEmpty ? reciter.moshaf.first.surahList.first : null,
    ));
    print('selected reciter: ${reciter.name}');
    await _getSuwarByReciter(selectedMoshaf: reciter.moshaf.first);
    _saveSchedule();
  }

  Future<void> setSelectedMoshaf(MoshafModel moshaf) async {
    state = AsyncValue.data(state.value!.copyWith(
      selectedMoshaf: moshaf,
      selectedSurahId: moshaf.surahList.isNotEmpty ? moshaf.surahList.first : null,
    ));
    await _getSuwarByReciter(selectedMoshaf: moshaf);
    _saveSchedule();
  }

  void setSelectedSurah(int surahId) {
    state = AsyncValue.data(state.value!.copyWith(
      selectedSurahId: surahId,
      isRandomEnabled: false,
    ));
    _saveSchedule();
  }

  void setRandomEnabled(bool enabled) {
    state = AsyncValue.data(state.value!.copyWith(
      isRandomEnabled: enabled,
      selectedSurahId: enabled ? null : state.value!.selectedSurahId,
    ));
    _saveSchedule();
  }

  void updateReciterList(List<ReciterModel> reciterList) {
    state = AsyncValue.data(state.value!.copyWith(reciterList: reciterList));
    _saveSchedule();
  }

  Future<void> saveSchedule() async {
    await _repository.saveSchedule(state.value!);
    await _repository.updateBackgroundService();

    // Add immediate playback if within schedule time
    if (state.value!.isScheduleEnabled) {
      final now = DateTime.now();
      final currentMinutes = now.hour * 60 + now.minute;
      final startMinutes = state.value!.startTime.hour * 60 + state.value!.startTime.minute;
      final endMinutes = state.value!.endTime.hour * 60 + state.value!.endTime.minute;

      if (currentMinutes >= startMinutes && currentMinutes <= endMinutes) {
        final audioNotifier = ref.read(audioNotifierProvider.notifier);
        if (state.value!.isRandomEnabled) {
          final urls = await _repository.generateRandomUrls(state.value!);
          await audioNotifier.playAudio(urls.first, createPlaylist: true);
        } else if (state.value!.selectedMoshaf != null && state.value!.selectedSurahId != null) {
          final surahId = state.value!.selectedSurahId.toString().padLeft(3, '0');
          final surahUrl = '${state.value!.selectedMoshaf!.server}$surahId.mp3';
          await audioNotifier.playAudio(surahUrl);
        }
      }
    }
  }

  Future<void> _getSuwarByReciter({
    required MoshafModel selectedMoshaf,
  }) async {
    state = await AsyncValue.guard(() async {
      final quranRepository = await ref.read(quranRepositoryProvider.future);
      final sharedPreference = await ref.read(sharedPreferenceModule.future);
      final languageCode = sharedPreference.getString('language_code') ?? 'en';
      // return boolean if the languages has locale
      final mappedLanguage = LanguageHelper.mapLocaleWithQuran(languageCode);
      final suwar = await quranRepository.getSuwarByLanguage(languageCode: mappedLanguage);
      final filteredSuwar = suwar.where((element) => selectedMoshaf.surahList.contains(element.id)).toList();
      return state.value!.copyWith(selectedSurahList: filteredSuwar);
    });
  }


  void _saveSchedule() {
    Future.microtask(() async {
      await _repository.saveSchedule(state.value!);
      await _repository.updateBackgroundService();
    });
  }
}

final scheduleNotifierProvider = AsyncNotifierProvider<ScheduleNotifier, ScheduleModel>(() => ScheduleNotifier());
