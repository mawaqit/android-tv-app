// quran_download_repository_impl.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/data/data_source/quran/download_quran_remote_data_source.dart';
import 'package:mawaqit/src/helpers/zip_extractor_helper.dart';

import 'package:mawaqit/src/data/data_source/quran/download_quran_local_data_source.dart';

import 'package:mawaqit/src/domain/repository/quran/quran_download_repository.dart';

class QuranDownloadRepositoryImpl implements QuranDownloadRepository {
  final DownloadQuranLocalDataSource localDataSource;
  final DownloadQuranRemoteDataSource remoteDataSource;

  QuranDownloadRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<String?> getLocalQuranVersion() async {
    try {
      final version = await remoteDataSource.getRemoteQuranVersion();
      return version;
    } catch (e) {
      throw Exception('Error occurred while fetching remote quran version: $e');
    }
  }

  @override
  Future<void> downloadQuran(String version, String? filePath, Function(double) onReceiveProgress) async {
    try {
      await remoteDataSource.downloadQuranWithProgress(
        versionName: version,
        applicationDirectoryPath: filePath,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      throw Exception('Error occurred while downloading quran: $e');
    }
  }

  @override
  Future<void> extractQuran(String zipFilePath, String destinationPath, Function(double) onExtractProgress) async {
    await ZipFileExtractorHelper.extractZipFile(
      zipFilePath: zipFilePath,
      destinationDirPath: destinationPath,
      changeProgress: (progress) {
        onExtractProgress(progress);
      },
    );
  }

  @override
  Future<void> deleteOldQuran() async {
    try {
      await localDataSource.deleteExistingSvgFiles();
    } catch (e) {
      throw Exception('Error occurred while deleting old quran: $e');
    }
  }

  @override
  Future<void> deleteZipFile(String zipFileName) async {
    try {
      await localDataSource.deleteZipFile(zipFileName);
    } catch (e) {
      throw Exception('Error occurred while deleting old zip file: $e');
    }
  }

  @override
  Future<String?> getRemoteQuranVersion() {
    try {
      return remoteDataSource.getRemoteQuranVersion();
    } catch (e) {
      throw Exception('Error occurred while fetching remote quran version: $e');
    }
  }
}

final quranDownloadRepositoryProvider = FutureProvider<QuranDownloadRepository>((ref) async {
  final localDataSource = await ref.read(downloadQuranLocalDataSourceProvider.future);
  final remoteDataSource = await ref.read(downloadQuranRemoteDataSourceProvider.future);
  return QuranDownloadRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
});
