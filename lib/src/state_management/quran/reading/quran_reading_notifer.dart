import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';
import 'package:mawaqit/src/domain/repository/quran/quran_reading_repository.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/src/module/shared_preference_module.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/moshaf_type_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';
import 'package:mawaqit/src/data/repository/quran/quran_reading_impl.dart';

class QuranReadingNotifier extends AutoDisposeAsyncNotifier<QuranReadingState> {
  @override
  Future<QuranReadingState> build() async {
    final link = ref.keepAlive();

    try {
      final repository = await ref.read(quranReadingRepositoryProvider.future);

      ref.onDispose(() {
        if (state.hasValue) {
          state.value!.pageController.dispose();
        }
      });

      final result = await _initState(repository);
      link.close();
      return result;
    } catch (e) {
      link.close();
      rethrow;
    }
  }

  void nextPage({bool isPortrait = false}) async {
    log('quran: QuranReadingNotifier: nextPage:');
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final currentPage = currentState.currentPage;
      final nextPage = isPortrait ? currentPage + 1 : currentPage + 2;
      if (nextPage < currentState.totalPages) {
        await _saveLastReadPage(nextPage);

        currentState.pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        final newSurahName = _getCurrentSurahName(nextPage, currentState.suwar);
        return currentState.copyWith(currentPage: nextPage, currentSurahName: newSurahName);
      }
      return currentState;
    });
  }

  void previousPage({bool isPortrait = false}) async {
    log('quran: QuranReadingNotifier: nextPage:');
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final previousPage = isPortrait ? currentState.currentPage : currentState.currentPage - 2;
      if (previousPage >= 0) {
        await _saveLastReadPage(previousPage);
        currentState.pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        final newSurahName = _getCurrentSurahName(previousPage, currentState.suwar);
        return currentState.copyWith(currentPage: previousPage, currentSurahName: newSurahName);
      }
      return currentState;
    });
  }

  Future<void> updatePage(int page, {bool isPortairt = false}) async {
    log('quran: QuranReadingNotifier: updatePage: $page');

    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      if (page >= 0 && page < currentState.totalPages) {
        await _saveLastReadPage(page);

        if (currentState.pageController.hasClients) {
          !isPortairt
              ? currentState.pageController.jumpToPage((page / 2).floor())
              : currentState.pageController.jumpToPage(page);
        }

        final newSurahName = _getCurrentSurahName(page, currentState.suwar);

        return currentState.copyWith(
          currentPage: page,
          isInitial: false,
          currentSurahName: newSurahName,
        );
      }
      return currentState;
    });
  }

  Future<void> getAllSuwarPage() async {
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final sharedPref = await ref.read(sharedPreferenceModule.future);
      final language = sharedPref.getString(SettingsConstant.kLanguageCode) ?? 'en';
      await ref.read(quranNotifierProvider.notifier).getSuwarByLanguage(languageCode: language);
      return ref.read(quranNotifierProvider).maybeWhen(
        orElse: () {
          return state.value!;
        },
        data: (quranState) {
          final suwar = quranState.suwar;
          return state.value!.copyWith(suwar: suwar);
        },
      );
    });
  }

  Future<List<SurahModel>> getAllSuwar() async {
    final sharedPref = await ref.read(sharedPreferenceModule.future);
    final language = sharedPref.getString(SettingsConstant.kLanguageCode) ?? 'en';
    await ref.read(quranNotifierProvider.notifier).getSuwarByLanguage(languageCode: language);
    return ref.read(quranNotifierProvider).maybeWhen(
          orElse: () => [],
          data: (quranState) => quranState.suwar,
        );
  }

  Future<QuranReadingState> _initState(QuranReadingRepository repository) async {
    final mosqueModel = await ref.read(moshafTypeNotifierProvider.future);

    try {
      // Get moshaf type or set default
      final moshafType = mosqueModel.selectedMoshaf.getOrElse(() => MoshafType.hafs);

      // Set moshaf type if none selected
      if (mosqueModel.selectedMoshaf.isNone()) {
        await ref.read(moshafTypeNotifierProvider.notifier).selectMoshafType(moshafType);
      }

      state = AsyncLoading();
      final svgs = await _loadSvgs(moshafType: moshafType);

      if (svgs.isEmpty) {
        throw Exception('No SVGs found for moshaf type: ${moshafType.name}');
      }

      final lastReadPage = await repository.getLastReadPage();
      final pageController = PageController(initialPage: (lastReadPage / 2).floor());
      final suwar = await getAllSuwar();

      return QuranReadingState(
        currentJuz: 1,
        currentSurah: 1,
        suwar: suwar,
        currentPage: lastReadPage,
        svgs: svgs,
        pageController: pageController,
        currentSurahName: _getCurrentSurahName(lastReadPage, suwar),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveLastReadPage(int index) async {
    try {
      final quranRepository = await ref.read(quranReadingRepositoryProvider.future);
      await quranRepository.saveLastReadPage(index);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  String _getCurrentSurahName(int currentPage, List<SurahModel> suwar) {
    int left = 0;
    int right = suwar.length - 1;

    while (left <= right) {
      int mid = left + (right - left) ~/ 2;

      if (currentPage + 1 >= suwar[mid].startPage &&
          (mid == suwar.length - 1 || currentPage + 1 < suwar[mid + 1].startPage)) {
        return suwar[mid].name;
      }

      if (currentPage + 1 < suwar[mid].startPage) {
        right = mid - 1;
      } else {
        left = mid + 1;
      }
    }

    return "";
  }

  Future<void> toggleRotation() async {
    state = await AsyncValue.guard(() async {
      return state.value!.copyWith(
        isRotated: !state.value!.isRotated,
      );
    });
  }

  Future<List<SvgPicture>> _loadSvgs({required MoshafType moshafType}) async {
    final repository = await ref.read(quranReadingRepositoryProvider.future);
    return repository.loadAllSvgs(moshafType);
  }
}

final quranReadingNotifierProvider = AutoDisposeAsyncNotifierProvider<QuranReadingNotifier, QuranReadingState>(
  QuranReadingNotifier.new,
);
