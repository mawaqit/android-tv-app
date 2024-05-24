import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'quran_reading_state.dart';

class QuranReadingNotifier extends AsyncNotifier<QuranReadingState> {
  @override
  Future<QuranReadingState> build() async {
    _loadAllSvgs();

    return QuranReadingState(
      currentJuz: 1,
      currentSurah: 1,
      currentPage: 0,
      svgs: [],
      totalPages: 0,
    );
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
      return [];
    }
  }

  Future<void> _loadAllSvgs() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      // final svgs =  await Isolate.run(() async {
      //
      //   return svgs;
      // });
      final svgPaths = await _loadAllPages();
      final svgs = await Future.wait(svgPaths.map((path) => _loadSvg(path)));
      return state.value!.copyWith(
        svgs: svgs,
        totalPages: svgs.length,
      );
    });
  }

  Future<SvgPicture> _loadSvg(String path) async {
    try {
      final svgFile = File(path);
      log('quran: Loading SVG: $path');
      return SvgPicture.file(svgFile, color: Colors.black);
    } catch (e) {
      print('Error loading SVG: $e');
      // You could return a default or error SVG here if desired
      return SvgPicture.string('<svg></svg>');
    }
  }

  Future<void> nextPage() async {
    log('quran: Next page');
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final nextPage = currentState.currentPage + 1;
      if (nextPage < currentState.totalPages) {
        return currentState.copyWith(currentPage: nextPage);
      }
      return currentState;
    });
  }

  void previousPage() async {
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final previousPage = currentState.currentPage - 1;
      if (previousPage >= 0) {
        return currentState.copyWith(currentPage: previousPage);
      }
      return currentState;
    });
  }

  void updatePage(int page) async {
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      if (page >= 0 && page < currentState.totalPages) {
        return currentState.copyWith(currentPage: page);
      }
      return currentState;
    });
  }
}

final quranReadingNotifierProvider = AsyncNotifierProvider<QuranReadingNotifier, QuranReadingState>(
  QuranReadingNotifier.new,
);
