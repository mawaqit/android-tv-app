import 'dart:io';

import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';

class QuranPathHelper {
  final Directory applicationSupportDirectory;
  final MoshafType moshafType;

  QuranPathHelper({
    required this.applicationSupportDirectory,
    required this.moshafType,
  });

  /// Gets the path to the Quran directory
  String get quranDirectoryPath => '${applicationSupportDirectory.path}/${moshafType.name}/quran';

  /// Gets the path to the Quran zip directory
  String get quranZipDirectoryPath => '${applicationSupportDirectory.path}/${moshafType.name}/quran_zip';

  /// Constructs the full path for a Quran zip file
  String getQuranZipFilePath(String versionName) => '$quranZipDirectoryPath/$versionName';

  /// Constructs the full path for a Quran file
  String getQuranFilePath(String fileName) => '$quranDirectoryPath/$fileName';

  /// Ensures the Quran directory exists, creating it if necessary
  Future<void> ensureQuranDirectoryExists() async {
    final quranDirectory = Directory(quranDirectoryPath);
    if (!await quranDirectory.exists()) {
      await quranDirectory.create(recursive: true);
    }
  }

  /// Ensures the Quran zip directory exists, creating it if necessary
  Future<void> ensureQuranZipDirectoryExists() async {
    final quranZipDirectory = Directory(quranZipDirectoryPath);
    if (!await quranZipDirectory.exists()) {
      await quranZipDirectory.create(recursive: true);
    }
  }

  /// Deletes the Quran directory for the current mosuf type
  Future<void> deleteQuranDirectory() async {
    await _deleteDirectories([quranDirectoryPath]);
  }

  /// Deletes the Quran zip directory for the current mosuf type
  Future<void> deleteQuranZipDirectory() async {
    await _deleteDirectories([quranZipDirectoryPath]);
  }

  /// Deletes both Quran and Quran zip directories for the current mosuf type
  Future<void> deleteAllQuranDirectories() async {
    await _deleteDirectories([quranDirectoryPath, quranZipDirectoryPath]);
  }

  /// Deletes directories if they exist
  Future<void> _deleteDirectories(List<String> directoryPaths) async {
    for (final path in directoryPaths) {
      final directory = Directory(path);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  }
}
