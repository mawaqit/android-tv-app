import 'dart:developer';
import 'dart:io';

class DirectoryHelper {
  /// [deleteDirectories] deletes the directories
  static Future<void> deleteDirectories(List<String> directories) async {
    for (final directory in directories) {
      final dir = Directory(directory);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
        log('DirectoryHelper: deleteDirectories - directory deleted: $directory');
      }
    }
  }

  /// [deleteFileIfExists] deletes the file if it exists
  static Future<void> deleteFileIfExists(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      log('DirectoryHelper: deleteFileIfExists - file deleted: $filePath');
    }
  }

  /// [createDirectoryIfNotExists] creates the directory if it doesn't exist
  static Future<void> createDirectoryIfNotExists(Directory directory) async {
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  /// [deleteExistingSvgFiles] deletes the existing svg files
  static Future<void> deleteExistingSvgFiles({
    required String path,
  }) async {
    final directory = Directory(path);
    if (await directory.exists()) {
      log('DirectoryHelper: deleteExistingSvgFiles - deleting $path');
      await directory.delete(recursive: true);
    }
  }
}
