import 'dart:io';

import 'package:flutter_archive/flutter_archive.dart';
import 'package:mawaqit/src/domain/error/quran_exceptions.dart';

class ZipFileExtractorHelper {
  static Future<void> extractZipFile({
    required String zipFilePath,
    required String destinationDirPath,
    required Function(double) changeProgress,
  }) async {
    final zipFile = File(zipFilePath);
    final destinationDir = Directory(destinationDirPath);

    if (!destinationDir.existsSync()) {
      destinationDir.createSync(recursive: true);
    }

    destinationDir.createSync();

    try {
      await ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: destinationDir,
        onExtracting: (zipEntry, progress) {
          changeProgress(progress);
          return ZipFileOperation.includeItem;
        },
      );
    } catch (e) {
      throw ExtractZipFileException(e.toString());
    }
  }
}
