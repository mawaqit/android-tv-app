import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/usecase/random_hadith_usecase.dart';
import 'package:mawaqit/src/state_management/random_hadith/random_hadith_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mawaqit/src/data/repository/random_hadith_impl.dart';
import '../../services/mosque_manager.dart';

class RandomHadithNotifier extends AsyncNotifier<RandomHadithState> {
  @override
  FutureOr<RandomHadithState> build() {
    return RandomHadithState(hadith: '', language: '');
  }

  Future<void> getRandomHadith({
    String language = 'ar',
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final randomHadithUseCase = await ref.read(randomHadithUseCaseProvider.future);
      final hadith = await randomHadithUseCase.getRandomHadith(language: language);
      return RandomHadithState(hadith: hadith, language: language);
    });
  }

  Future<void> setHadithLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(RandomHadithConstant.kHadithLanguage, language);
    await getRandomHadith(language: language);
  }

  Future<void> fetchAndCacheHadith({
    String language = 'ar',
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final hadithRepository = await ref.read(randomHadithRepositoryProvider.future);
      await hadithRepository.fetchAndCacheHadith(language);
      return Future.value(state.value);
    });
  }

  Future<void> ensureHadithLanguage(MosqueManager mosqueManager) async {
    // Use proper fallback logic that considers both local settings and API configuration
    final language = await AppLanguage().getHadithLanguage(mosqueManager);
    // Ensure hadiths are cached during initialization
    final randomHadithRepository = await ref.read(randomHadithRepositoryProvider.future);
    await randomHadithRepository.ensureHadithsAreCached(language);
  }
}

final randomHadithNotifierProvider =
    AsyncNotifierProvider<RandomHadithNotifier, RandomHadithState>(RandomHadithNotifier.new);
