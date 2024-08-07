import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/data/data_source/quran/download_quran_remote_data_source.dart';
import 'package:mawaqit/src/helpers/directory_helper.dart';
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

  /// [getLocalQuranVersion] fetches the local quran version
  @override
  Future<String?> getLocalQuranVersion() async {
    final version = localDataSource.getQuranVersion();
    return version;
  }

  /// [downloadQuran] downloads the quran zip file
  @override
  Future<void> downloadQuran({
    required String version,
    String? filePath,
    required Function(double) onReceiveProgress,
  }) async {
    await remoteDataSource.downloadQuranWithProgress(
      versionName: version,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// [extractQuran] extracts the quran zip file
  @override
  Future<void> extractQuran({
    required String zipFilePath,
    required String destinationPath,
    required Function(double) onExtractProgress,
  }) async {
    await ZipFileExtractorHelper.extractZipFile(
      zipFilePath: zipFilePath,
      destinationDirPath: destinationPath,
      changeProgress: (progress) {
        onExtractProgress(progress);
      },
    );
  }

  /// [deleteOldQuran] deletes the old quran
  @override
  Future<void> deleteOldQuran({
    String? path,
  }) async {
    final quranPath = path ?? localDataSource.applicationSupportDirectory.path;
    final deletePath = '$quranPath/quran';
    await DirectoryHelper.deleteExistingSvgFiles(path: deletePath);
  }

  /// [deleteZipFile] deletes the zip file
  @override
  Future<void> deleteZipFile(String zipFileName) async {
    await localDataSource.deleteZipFile(zipFileName);
  }

  /// [getRemoteQuranVersion] fetches the remote quran version
  @override
  Future<String> getRemoteQuranVersion() {
    return remoteDataSource.getRemoteQuranVersion();
  }

  /// [cancelDownload] cancels the download
  @override
  Future<void> cancelDownload() async {
    remoteDataSource.cancelDownload();
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
