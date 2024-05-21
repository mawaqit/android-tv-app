import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/helpers/directory_helper.dart';
import 'package:mawaqit/src/module/shared_preference_module.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadQuranLocalDataSource {
  final Directory applicationSupportDirectory;
  final SharedPreferences sharedPreference;

  DownloadQuranLocalDataSource({required this.applicationSupportDirectory, required this.sharedPreference});

  /// [saveSvgFiles] saves the zip file to the local storage
  Future<void> saveSvgFiles(List<File> svgFiles) async {
    final quranDirectory = Directory('${applicationSupportDirectory.path}/quran');
    log('quran: DownloadQuranLocalDataSource: saveSvgFiles - quranDirectory: ${quranDirectory.path}');
    await DirectoryHelper.createDirectoryIfNotExists(quranDirectory);
    for (final svgFile in svgFiles) {
      final fileName = svgFile.path.split('/').last;
      final destinationPath = '${quranDirectory.path}/$fileName';
      log('quran: DownloadQuranLocalDataSource: saveSvgFiles - destinationPath: $destinationPath || fileName: $fileName');
      await svgFile.copy(destinationPath);
      log('quran: DownloadQuranLocalDataSource: saveSvgFiles - copied ${svgFile.path} to $destinationPath');
    }
  }

  /// [deleteZipFile] deletes the existing svg files
  Future<void> deleteZipFile(String zipFileName) async {
    final zipFilePath = '${applicationSupportDirectory.path}/quran_zip/$zipFileName';
    _setQuranVersion(zipFileName);
    final zipFile = File(zipFilePath);
    if (await zipFile.exists()) {
      log('quran: DownloadQuranLocalDataSource: deleteZipFile - deleting $zipFilePath');
      await zipFile.delete();
    }
  }

  /// [getQuranVersion] fetches the quran version
  String getQuranVersion() {
    final version = sharedPreference.getString(QuranConstant.kQuranLocalVersion) ?? '';
    final checkSVGs = Directory('${applicationSupportDirectory.path}/quran');
    if (checkSVGs.existsSync() && checkSVGs.listSync().isNotEmpty) {
      log('quran: DownloadQuranLocalDataSource: getQuranVersion - checkSVGs: $version');
      return version;
    } else {
      log('quran: DownloadQuranLocalDataSource: getQuranVersion - checkSVGs: $version');
      return '';
    }
  }

  /// [_setQuranVersion] sets the quran version
  void _setQuranVersion(String version) {
    sharedPreference.setString(QuranConstant.kQuranLocalVersion, version);
    log('quran: DownloadQuranLocalDataSource: setQuranVersion - version: $version');
  }
}

final downloadQuranLocalDataSourceProvider = FutureProvider<DownloadQuranLocalDataSource>(
  (ref) async {
    final savePath = await getApplicationSupportDirectory();
    final sharedPref = await ref.read(sharedPreferenceModule.future);

    return DownloadQuranLocalDataSource(
      applicationSupportDirectory: savePath,
      sharedPreference: sharedPref,
    );
  },
);
