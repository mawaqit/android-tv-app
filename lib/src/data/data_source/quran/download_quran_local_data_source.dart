import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class DownloadQuranLocalDataSource {
  final Directory applicationSupportDirectory;

  DownloadQuranLocalDataSource(this.applicationSupportDirectory);

  Future<void> saveSvgFiles(List<File> svgFiles) async {
    final quranDirectory = Directory('${applicationSupportDirectory.path}/quran');
    log('quran: DownloadQuranLocalDataSource: saveSvgFiles - quranDirectory: ${quranDirectory.path}');
    await _createDirectoryIfNotExists(quranDirectory);
    for (final svgFile in svgFiles) {
      final fileName = svgFile.path.split('/').last;
      final destinationPath = '${quranDirectory.path}/$fileName';
      log('quran: DownloadQuranLocalDataSource: saveSvgFiles - destinationPath: $destinationPath || fileName: $fileName');
      await svgFile.copy(destinationPath);
      log('quran: DownloadQuranLocalDataSource: saveSvgFiles - copied ${svgFile.path} to $destinationPath');
    }
  }

  Future<void> deleteExistingSvgFiles() async {
    final quranDirectory = Directory('${applicationSupportDirectory.path}/quran');
    if (await quranDirectory.exists()) {
      log('quran: DownloadQuranLocalDataSource: deleteExistingSvgFiles - deleting ${quranDirectory.path}');
      await quranDirectory.delete(recursive: true);
    }
  }

  Future<void> deleteZipFile(String zipFileName) async {
    final zipFilePath = '${applicationSupportDirectory.path}/quran_zip/$zipFileName';
    final zipFile = File(zipFilePath);
    if (await zipFile.exists()) {
      log('quran: DownloadQuranLocalDataSource: deleteZipFile - deleting $zipFilePath');
      await zipFile.delete();
    }
  }

  Future<String> getQuranVersion({String? path}) async {
    path ??= applicationSupportDirectory.path;
    final quranDirectory = Directory('$path/quran_zip');
    if (!await quranDirectory.exists()) {
      return '';
    }

    final subFile = quranDirectory.listSync().first;
    log('quran: DownloadQuranLocalDataSource: getQuranVersion - subFile: $subFile');

    final version = subFile.path.split('/').last;
    log('quran: DownloadQuranLocalDataSource: getQuranVersion - version: ${version}');
    return version;
  }

  Future<void> _createDirectoryIfNotExists(Directory directory) async {
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }
}

final downloadQuranLocalDataSourceProvider = FutureProvider<DownloadQuranLocalDataSource>(
  (ref) async {
    final savePath = await getApplicationSupportDirectory();
    return DownloadQuranLocalDataSource(savePath);
  },
);
