import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/data/repository/quran/quran_download_impl.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';
import 'package:mawaqit/src/domain/repository/quran/quran_reading_repository.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/src/module/shared_preference_module.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/moshaf_type_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';
import 'package:mawaqit/src/data/repository/quran/quran_reading_impl.dart';

class QuranReadingNotifier extends AutoDisposeAsyncNotifier<QuranReadingState> {
  @override
  Future<QuranReadingState> build() async {
    final repository = ref.read(quranReadingRepositoryProvider.future);
    ref.onDispose(() {
      if (state.hasValue) {
        state.value!.pageController.dispose();
      }
    });
    return _initState(repository);
  }

  Future<void> _saveLastReadPage(int index) async {
    try {
      final quranRepository = await ref.read(quranReadingRepositoryProvider.future);
      await quranRepository.saveLastReadPage(index);
      log('quran: QuranReadingNotifier: Saved last read page: ${index}');
    } catch (e, s) {
      state = AsyncError(e, s);
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
        return currentState.copyWith(currentPage: nextPage);
      }
      return currentState;
    });
  }

  void previousPage({bool isPortrait = false}) async {
    log('quran: QuranReadingNotifier: nextPage:');
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final previousPage = isPortrait ? currentState.currentPage : currentState.currentPage - 2;
      final nextPage = isPortrait ? previousPage - 1 : previousPage - 2;
      if (nextPage >= 0) {
        await _saveLastReadPage(nextPage);
        currentState.pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        return currentState.copyWith(currentPage: previousPage);
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
        !isPortairt
            ? currentState.pageController.jumpToPage((page / 2).floor())
            : currentState.pageController.jumpToPage(page); // Jump to the selected page
        return currentState.copyWith(
          currentPage: page,
          isInitial: false,
        );
      }
      return currentState;
    });
  }

  Future<QuranReadingState> _initState(Future<QuranReadingRepository> repository) async {
    final quranReadingRepository = await repository;
    final mosqueModel = await ref.read(moshafTypeNotifierProvider.future);
    return mosqueModel.selectedMoshaf.fold(
      () {
        throw Exception('No MoshafType');
      },
      (moshaf) async {
        final svgs = await _loadSvgs(moshafType: moshaf);
        final lastReadPage = await quranReadingRepository.getLastReadPage();
        final pageController = PageController(initialPage: (lastReadPage / 2).floor());
        return QuranReadingState(
          currentJuz: 1,
          currentSurah: 1,
          currentPage: lastReadPage,
          svgs: svgs,
          pageController: pageController,
        );
      },
    );
  }

  Future<List<SvgPicture>> _loadSvgs({required MoshafType moshafType}) async {
    final repository = await ref.read(quranReadingRepositoryProvider.future);
    return repository.loadAllSvgs(moshafType);
  }
}

final quranReadingNotifierProvider = AutoDisposeAsyncNotifierProvider<QuranReadingNotifier, QuranReadingState>(
  QuranReadingNotifier.new,
);
