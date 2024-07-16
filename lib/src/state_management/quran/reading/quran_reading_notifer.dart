import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/domain/repository/quran/quran_reading_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  void nextPage() async {
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final nextPage = currentState.currentPage + 2;
      if (nextPage < currentState.totalPages) {
        await _saveLastReadPage(nextPage);
        currentState.pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        return currentState.copyWith(currentPage: nextPage);
      }
      return currentState;
    });
  }

  void previousPage() async {
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final previousPage = currentState.currentPage - 2;
      if (previousPage >= 0) {
        await _saveLastReadPage(previousPage);
        currentState.pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        return currentState.copyWith(currentPage: previousPage);
      }
      return currentState;
    });
  }

  void updatePage(int page) async {
    log('quran: QuranReadingNotifier: updatePage: $page');
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      if (page >= 0 && page < currentState.totalPages) {
        await _saveLastReadPage(page);
        currentState.pageController.jumpToPage((page / 2).floor());
        return currentState.copyWith(currentPage: page);
      }
      return currentState;
    });
  }

  Future<List<SvgPicture>> _loadSvgs() async {
    final repository = await ref.read(quranReadingRepositoryProvider.future);
    return repository.loadAllSvgs();
  }

  Future<QuranReadingState> _initState(Future<QuranReadingRepository> repository) async {
    final quranReadingRepository = await repository;
    final svgs = await _loadSvgs();
    final lastReadPage = await quranReadingRepository.getLastReadPage();
    log('riverpod get last page: $lastReadPage');
    final pageController = PageController(initialPage: (lastReadPage / 2).floor());
    return QuranReadingState(
      currentJuz: 1,
      currentSurah: 1,
      currentPage: lastReadPage,
      svgs: svgs,
      pageController: pageController,
    );
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
}

final quranReadingNotifierProvider = AutoDisposeAsyncNotifierProvider<QuranReadingNotifier, QuranReadingState>(
  QuranReadingNotifier.new,
);
