import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/src/data/data_source/quran/download_quran_remote_data_source.dart';
import 'package:mawaqit/src/helpers/quran_path_helper.dart';
import 'package:mawaqit/src/helpers/zip_extractor_helper.dart';

import 'package:mawaqit/src/data/data_source/quran/download_quran_local_data_source.dart';

import 'package:mawaqit/src/domain/repository/quran/quran_download_repository.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';
import 'package:mawaqit/src/module/shared_preference_module.dart';
import 'package:path_provider/path_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

class QuranDownloadRepositoryImpl implements QuranDownloadRepository {
  final DownloadQuranLocalDataSource localDataSource;
  final DownloadQuranRemoteDataSource remoteDataSource;
  final QuranPathHelper quranPathHelper;

  QuranDownloadRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.quranPathHelper,
  });

  /// [getLocalQuranVersion] fetches the local quran version
  @override
  Future<Option<String>> getLocalQuranVersion({
    required MoshafType moshafType,
  }) async {
    final version = localDataSource.getQuranVersion(moshafType);
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

    await localDataSource.setQuranVersion(version, moshafType);

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

  @override
  Future<bool> isQuranDownloaded(MoshafType moshafType) async {
    return localDataSource.isQuranDownloaded(moshafType);
  }

  /// [deleteZipFile] deletes the zip file
  Future<void> _deleteZipFile(String zipFileName) async {
    final zipFilePath = quranPathHelper.getQuranZipFilePath(zipFileName);
    await localDataSource.deleteZipFile(
      zipFileName,
      File(zipFilePath),
    );
  }
}

final quranDownloadRepositoryProvider = FutureProvider.family<QuranDownloadRepository, MoshafType>((ref, type) async {
  final localDataSource = await ref.read(downloadQuranLocalDataSourceProvider(type).future);
  final remoteDataSource = await ref.read(downloadQuranRemoteDataSourceProvider(type).future);
  final directory = await getApplicationSupportDirectory();
  final quranHelper = QuranPathHelper(applicationSupportDirectory: directory, moshafType: type);

  return QuranDownloadRepositoryImpl(
    localDataSource: localDataSource,
    quranPathHelper: quranHelper,
    remoteDataSource: remoteDataSource,
  );
});
