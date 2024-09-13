import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mawaqit/src/helpers/quran_path_helper.dart';
import 'package:mawaqit/src/module/shared_preference_module.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';
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

  Future<List<SvgPicture>> loadAllSvgs(MoshafType moshafType) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final quranPathHelper = QuranPathHelper(
        applicationSupportDirectory: dir,
        moshafType: moshafType,
      );

      final directory = Directory(quranPathHelper.quranDirectoryPath);
      final files = directory.listSync().whereType<File>().toList();

      // Sort the files based on their numeric names
      files.sort((a, b) {
        final aNumber = int.tryParse(a.path.split('/').last.split('.').first) ?? 0;
        final bNumber = int.tryParse(b.path.split('/').last.split('.').first) ?? 0;
        return aNumber.compareTo(bNumber);
      });

      return files.map((file) => SvgPicture.file(File(file.path))).toList();
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
