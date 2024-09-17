import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/helpers/quran_path_helper.dart';
import 'package:mawaqit/src/module/shared_preference_module.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadQuranLocalDataSource {
  final SharedPreferences sharedPreference;
  final QuranPathHelper quranPathHelper;
  final MoshafType moshafType;

  DownloadQuranLocalDataSource(
      {required this.sharedPreference, required this.quranPathHelper, required this.moshafType});

  /// [saveSvgFiles] saves the zip file to the local storage
  Future<void> saveSvgFiles(List<File> svgFiles, MoshafType moshafType) async {
    final quranDirectory = quranPathHelper.quranDirectoryPath;
    log('quran: DownloadQuranLocalDataSource: saveSvgFiles - quranDirectory: $quranDirectory');

    if (svgFiles.isEmpty) {
      log('quran: DownloadQuranLocalDataSource: saveSvgFiles - No files to save');
      return;
    }

    for (final svgFile in svgFiles) {
      final fileName = svgFile.path.split('/').last;
      final destinationPath = '$quranDirectory/$fileName';
      log('quran: DownloadQuranLocalDataSource: saveSvgFiles - destinationPath: $destinationPath || fileName: $fileName');

      try {
        await svgFile.copy(destinationPath);
        log('quran: DownloadQuranLocalDataSource: saveSvgFiles - copied ${svgFile.path} to $destinationPath');
      } catch (e) {
        log('quran: DownloadQuranLocalDataSource: saveSvgFiles - Error copying file: $e');
        rethrow;
      }
    }
  }

  /// [deleteZipFile] deletes the existing svg files
  Future<void> deleteZipFile(String zipFileName, File zipFile) async {
    _setQuranVersion(zipFileName);
    final isExist = await zipFile.exists();
    if (isExist) {
      await zipFile.delete();
    }
  }

  /// [getQuranVersion] fetches the quran version
  String? getQuranVersion(MoshafType moshafType) {
    final version = sharedPreference.getString(_getConstantByMoshafType());
    if (version != null) {
      log('quran: DownloadQuranLocalDataSource: getQuranVersion - checkSVGs: $version');
      return version;
    } else {
      log('quran: DownloadQuranLocalDataSource: getQuranVersion - checkSVGs: $version');
      return null;
    }
  }

  Future<bool> isQuranDownloaded(MoshafType moshafType) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final quranPathHelper = QuranPathHelper(
        applicationSupportDirectory: dir,
        moshafType: moshafType,
      );

      final directory = Directory(quranPathHelper.quranDirectoryPath);
      return directory.existsSync();
    } catch (e) {
      rethrow;
    }
  }

  /// [_setQuranVersion] sets the quran version
  void _setQuranVersion(String version) {
    sharedPreference.setString(_getConstantByMoshafType(), version);
    log('quran: DownloadQuranLocalDataSource: setQuranVersion - version: $version');
  }

  String _getConstantByMoshafType() {
    return switch (moshafType) {
      MoshafType.warsh => QuranConstant.kWarshQuranLocalVersion,
      MoshafType.hafs => QuranConstant.kHafsQuranLocalVersion,
    };
  }
}

final downloadQuranLocalDataSourceProvider = FutureProvider.family<DownloadQuranLocalDataSource, MoshafType>(
  (ref, type) async {
    final savePath = await getApplicationSupportDirectory();
    final sharedPref = await ref.read(sharedPreferenceModule.future);
    final quranPathHelper = QuranPathHelper(
      applicationSupportDirectory: savePath,
      moshafType: type,
    );
    return DownloadQuranLocalDataSource(
      quranPathHelper: quranPathHelper,
      sharedPreference: sharedPref,
      moshafType: type,
    );
  },
);
