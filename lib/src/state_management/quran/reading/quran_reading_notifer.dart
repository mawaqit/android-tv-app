import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';
import 'package:mawaqit/src/data/repository/quran/quran_reading_impl.dart';

class QuranReadingNotifier extends AutoDisposeAsyncNotifier<QuranReadingState> {
  @override
  Future<QuranReadingState> build() async {
    return await init();
  }

  Future<List<String>> _loadAllPages() async {
    try {
      final savePath = await getApplicationSupportDirectory();
      final svgFolderPath = '${savePath.path}/quran';
      final dir = Directory(svgFolderPath);
      final files = dir.listSync().where((file) => file.path.endsWith('.svg')).toList();
      files.sort((a, b) => a.path.compareTo(b.path)); // Ensure sorted order
      return files.map((file) => file.path).toList();
    } catch (e) {
      log('Error loading pages: $e');
      return [];
    }
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

  Future<int> _getLastReadPage() async {
    try {
      final quranRepository = await ref.read(quranReadingRepositoryProvider.future);
      final lastReadPage = await quranRepository.getLastReadPage();
      log('quran: QuranReadingNotifier: Last read page: $lastReadPage');
      return lastReadPage;
    } catch (e, s) {
      log('quran: Error getting last read page: $e');
      return 0;
    }
  }

  Future<void> _loadAllSvgs() async {
    final initialState = state.value ?? QuranReadingState(
      currentJuz: 1,
      currentSurah: 1,
      currentPage: 0,
      svgs: [],
      isInitial: false,
      totalPages: 0,
    );

    state = await AsyncValue.guard(() async {
      final svgPaths = await _loadAllPages();
      final svgs = await Future.wait(svgPaths.map((path) => _loadSvg(path)));
      return initialState.copyWith(
        svgs: svgs,
        totalPages: svgs.length,
      );
    });
  }

  Future<SvgPicture> _loadSvg(String path) async {
    try {
      final svgFile = File(path);
      return SvgPicture.file(svgFile, color: Colors.black);
    } catch (e) {
      log('Error loading SVG: $e');
      return SvgPicture.string('<svg></svg>');
    }
  }

  Future<void> nextPage(int index) async {
    log('quran: QuranReadingNotifier: nextPage:');
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final nextPage = currentState.currentPage + 1;
      if (nextPage < currentState.totalPages) {
        _saveLastReadPage(index);
        return currentState.copyWith(
          currentPage: nextPage,
          isInitial: false,
        );
      }
      return currentState;
    });
  }

  void previousPage(int index) async {
    log('quran: QuranReadingNotifier: previousPage:');
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final previousPage = currentState.currentPage - 1;
      if (previousPage >= 0) {
        _saveLastReadPage(index);
        return currentState.copyWith(
          currentPage: previousPage,
          isInitial: false,
        );
      }
      _saveLastReadPage(index);
      return currentState;
    });
  }

  void updatePage(int page) async {
    log('quran: QuranReadingNotifier: updatePage: $page');
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      if (page >= 0 && page < currentState.totalPages) {
        _saveLastReadPage(page);
        return currentState.copyWith(
          currentPage: page,
          isInitial: false,
        );
      }
      return currentState;
    });
  }

  Future<QuranReadingState> init() async {
    state = AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await _loadAllSvgs();
      final lastReadPage = await _getLastReadPage();
      log('quran: QuranReadingNotifier: Initializing with last read page: $lastReadPage, total SVGs: ${state.value?.svgs.length ?? 0}');
      return QuranReadingState(
        currentJuz: 1,
        currentSurah: 1,
        currentPage: lastReadPage,
        svgs: state.value?.svgs ?? [],
        totalPages: state.value?.totalPages ?? 0,
        isInitial: true,
      );
    });
    return result.value!;
  }
}

final quranReadingNotifierProvider = AutoDisposeAsyncNotifierProvider<QuranReadingNotifier, QuranReadingState>(
  QuranReadingNotifier.new,
);
