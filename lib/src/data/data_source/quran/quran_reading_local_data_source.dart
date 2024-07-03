import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mawaqit/src/module/shared_preference_module.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mawaqit/src/const/constants.dart';

class QuranReadingLocalDataSource {
  final SharedPreferences sharedPreferences;

  const QuranReadingLocalDataSource({
    required this.sharedPreferences,
  });

  Future<int> getLastReadPage() async {
    return sharedPreferences.getInt(QuranConstant.kSavedCurrentPage) ?? 0;
  }

  Future<void> saveLastReadPage(int lastReadingPage) async {
    await sharedPreferences.setInt(QuranConstant.kSavedCurrentPage, lastReadingPage);
  }

  Future<List<SvgPicture>> loadAllSvgs() async {
    try {
      final mainDir = await getApplicationSupportDirectory();
      final mainPath = mainDir.path;
      final dir = Directory('$mainPath/quran');
      final files = dir.listSync().where((file) => file.path.endsWith('.svg')).toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      final svgList = await Future.wait(files.map((file) => _loadSvg(file.path)));

      return svgList;
    } catch (e) {
      log('Error loading SVGs: $e');
      return [];
    }
  }

  Future<SvgPicture> _loadSvg(String path) async {
    try {
      return SvgPicture.file(File(path), color: Colors.black);
    } catch (e) {
      log('Error loading SVG: $e');
      return SvgPicture.string('<svg></svg>'); // Return an empty SVG as fallback
    }
  }
}

final quranReadingLocalDataSourceProvider = FutureProvider<QuranReadingLocalDataSource>((ref) async {
  final sharedPreferences = await ref.read(sharedPreferenceModule.future);
  return QuranReadingLocalDataSource(
    sharedPreferences: sharedPreferences,
  );
});
