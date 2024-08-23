import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/helpers/directory_helper.dart';
import 'package:mawaqit/src/helpers/quran_path_helper.dart';
import 'package:mawaqit/src/module/shared_preference_module.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadQuranLocalDataSource {
  final SharedPreferences sharedPreference;
  final QuranPathHelper quranPathHelper;

  DownloadQuranLocalDataSource({
    required this.sharedPreference,
    required this.quranPathHelper,
  });

  /// [saveSvgFiles] saves the zip file to the local storage
  Future<void> saveSvgFiles(List<File> svgFiles, MoshafType moshafType) async {
    final quranDirectory = quranPathHelper.quranDirectoryPath;
    log('quran: DownloadQuranLocalDataSource: saveSvgFiles - quranDirectory: $quranDirectory');
    for (final svgFile in svgFiles) {
      final fileName = svgFile.path.split('/').last;
      final destinationPath = '$quranDirectory/$fileName';
      log('quran: DownloadQuranLocalDataSource: saveSvgFiles - destinationPath: $destinationPath || fileName: $fileName');
      await svgFile.copy(destinationPath);
      log('quran: DownloadQuranLocalDataSource: saveSvgFiles - copied ${svgFile.path} to $destinationPath');
    }
  }

  /// [deleteZipFile] deletes the existing svg files
  Future<void> deleteZipFile(String zipFileName) async {
    final zipFilePath = quranPathHelper.getQuranZipFilePath(zipFileName);
    _setQuranVersion(zipFileName);
    final zipFile = File(zipFilePath);
    if (await zipFile.exists()) {
      log('quran: DownloadQuranLocalDataSource: deleteZipFile - deleting $zipFilePath');
      await zipFile.delete();
    }
  }

  /// [getQuranVersion] fetches the quran version
  String? getQuranVersion() {
    final version = sharedPreference.getString(QuranConstant.kQuranLocalVersion);
    if (version != null) {
      log('quran: DownloadQuranLocalDataSource: getQuranVersion - checkSVGs: $version');
      return version;
    } else {
      log('quran: DownloadQuranLocalDataSource: getQuranVersion - checkSVGs: $version');
      return null;
    }
  }

  /// [_setQuranVersion] sets the quran version
  void _setQuranVersion(String version) {
    sharedPreference.setString(QuranConstant.kQuranLocalVersion, version);
    log('quran: DownloadQuranLocalDataSource: setQuranVersion - version: $version');
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
    );
  },
);
