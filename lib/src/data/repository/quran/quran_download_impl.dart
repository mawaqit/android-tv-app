import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/data/data_source/quran/download_quran_remote_data_source.dart';
import 'package:mawaqit/src/helpers/directory_helper.dart';
import 'package:mawaqit/src/helpers/zip_extractor_helper.dart';

import 'package:mawaqit/src/data/data_source/quran/download_quran_local_data_source.dart';

import 'package:mawaqit/src/domain/repository/quran/quran_download_repository.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';

class QuranDownloadRepositoryImpl implements QuranDownloadRepository {
  final DownloadQuranLocalDataSource localDataSource;
  final DownloadQuranRemoteDataSource remoteDataSource;

  QuranDownloadRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  /// [getLocalQuranVersion] fetches the local quran version
  @override
  Future<String?> getLocalQuranVersion({
    required MoshafType moshafType,
  }) async {
    final version = localDataSource.getQuranVersion();
    return version;
  }

  /// [downloadQuran] downloads the quran zip file
  @override
  Future<void> downloadQuran({
    required String version,
    required MoshafType moshafType,
    String? filePath,
    required Function(double) onReceiveProgress,
    required Function(double) onExtractProgress,
  }) async {
    await remoteDataSource.downloadQuranWithProgress(
      version: version,
      moshafType: moshafType,
      onReceiveProgress: onReceiveProgress,
    );

    await ZipFileExtractorHelper.extractZipFile(
      zipFilePath: remoteDataSource.quranPathHelper.getQuranZipFilePath(version),
      destinationDirPath: localDataSource.quranPathHelper.quranDirectoryPath,
      changeProgress: onExtractProgress,
    );

    await _deleteZipFile(version);
  }

  /// [getRemoteQuranVersion] fetches the remote quran version
  @override
  Future<String> getRemoteQuranVersion({
    required MoshafType moshafType,
  }) {
    return remoteDataSource.getRemoteQuranVersion(
      moshafType: moshafType,
    );
  }

  /// [cancelDownload] cancels the download
  @override
  Future<void> cancelDownload() async {
    remoteDataSource.cancelDownload();
  }

  /// [deleteZipFile] deletes the zip file
  Future<void> _deleteZipFile(String zipFileName) async {
    await localDataSource.deleteZipFile(zipFileName);
  }
}

final quranDownloadRepositoryProvider = FutureProvider.family<QuranDownloadRepository, MoshafType>((ref, type) async {
  final localDataSource = await ref.read(downloadQuranLocalDataSourceProvider(type).future);
  final remoteDataSource = await ref.read(downloadQuranRemoteDataSourceProvider(type).future);
  return QuranDownloadRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
});
