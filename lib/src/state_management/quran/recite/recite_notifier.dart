import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/data/repository/quran/recite_impl.dart';
import 'package:mawaqit/src/state_management/quran/recite/recite_state.dart';

import 'package:mawaqit/src/module/shared_preference_module.dart';

import 'package:mawaqit/src/helpers/language_helper.dart';

import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';

class ReciteNotifier extends AsyncNotifier<ReciteState> {
  @override
  build() {
    return ReciteState(
      reciters: [],
    );
  }

  Future<void> getRecitersBySurah({
    required int surahId,
    String? language,
  }) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final reciteImpl = await ref.read(reciteImplProvider.future);
      final sharedPreference = await ref.read(sharedPreferenceModule.future);
      final languageCode = sharedPreference.getString('language_code') ?? 'en';
      final mappedLanguage = LanguageHelper.mapLocaleWithQuran(languageCode);
      final reciters = await reciteImpl.getRecitersBySurah(
        surahId: surahId,
        language: language ?? mappedLanguage,
      );
      return state.value!.copyWith(
        reciters: reciters,
      );
    });
  }

  Future<void> getAllReciters() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final reciteImpl = await ref.read(reciteImplProvider.future);
      final sharedPreference = await ref.read(sharedPreferenceModule.future);
      final languageCode = sharedPreference.getString('language_code') ?? 'en';
      final mappedLanguage = LanguageHelper.mapLocaleWithQuran(languageCode);
      final reciters = await reciteImpl.getAllReciters(language: mappedLanguage);
      return state.value!.copyWith(
        reciters: reciters,
      );
    });
  }

  void setSelectedReciter({
    required ReciterModel reciterModel,
  }) {
    state = AsyncData(
      state.value!.copyWith(
        selectedReciter: reciterModel,
      ),
    );
  }

  void setSelectedMoshaf({
    required MoshafModel moshafModel,
  }) {
    state = AsyncData(
      state.value!.copyWith(
        selectedMoshaf: moshafModel,
      ),
    );
  }
}

final reciteNotifierProvider = AsyncNotifierProvider<ReciteNotifier, ReciteState>(ReciteNotifier.new);
