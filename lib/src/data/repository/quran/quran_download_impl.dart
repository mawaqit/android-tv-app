import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/src/data/data_source/quran/download_quran_remote_data_source.dart';
import 'package:mawaqit/src/helpers/directory_helper.dart';
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
  final CancelToken cancelToken;

  QuranDownloadRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.quranPathHelper,
    required this.cancelToken
  });

  /// [getLocalQuranVersion] fetches the local quran version
  @override
  Future<Option<String>> getLocalQuranVersion({
    required MoshafType moshafType,
  }) async {
    final version = localDataSource.getQuranVersion(moshafType);
    return version;
  }

  @override
  Future<void> downloadQuran({
    required String version,
    required MoshafType moshafType,
    required Function(double) onReceiveProgress,
    required Function(double) onExtractProgress,
    String? filePath,
  }) async {
    try {
      await remoteDataSource.downloadQuranWithProgress(
        version: version,
        moshafType: moshafType,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      if (cancelToken.isCancelled) return;

      await ZipFileExtractorHelper.extractZipFile(
        zipFilePath: remoteDataSource.quranPathHelper.getQuranZipFilePath(version),
        destinationDirPath: localDataSource.quranPathHelper.quranDirectoryPath,
        changeProgress: onExtractProgress,
      );

      if (cancelToken.isCancelled) return;

      await localDataSource.setQuranVersion(version, moshafType);
      await _deleteZipFile(version);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        await _cleanupAfterCancellation(version);
      }
      rethrow;
    }
  }

  Future<void> _cleanupAfterCancellation(String version) async {
    await DirectoryHelper.deleteDirectories([
      quranPathHelper.quranZipDirectoryPath,
      quranPathHelper.quranDirectoryPath,
    ]);
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
  Future<void> cancelDownload(CancelToken cancelToken) async {
    remoteDataSource.cancelDownload(cancelToken);
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

class QuranDownloadRepositoryProviderParameter extends Equatable {
  final MoshafType moshafType;
  final CancelToken cancelToken;

  QuranDownloadRepositoryProviderParameter({
    required this.moshafType,
    required this.cancelToken,
  });

  @override
  List<Object> get props => [moshafType, cancelToken];
}

final quranDownloadRepositoryProvider =
    FutureProvider.family<QuranDownloadRepository, QuranDownloadRepositoryProviderParameter>((ref, para) async {
  final localDataSource = await ref.read(downloadQuranLocalDataSourceProvider(para.moshafType).future);
  final remoteDataSource = await ref.read(
    downloadQuranRemoteDataSourceProvider(
      DownloadQuranRemoteDataSourceProviderParameter(
        moshafType: para.moshafType,
        cancelToken: para.cancelToken,
      ),
    ).future,
  );
  final directory = await getApplicationSupportDirectory();
  final quranHelper = QuranPathHelper(applicationSupportDirectory: directory, moshafType: para.moshafType);

  return QuranDownloadRepositoryImpl(
    localDataSource: localDataSource,
    quranPathHelper: quranHelper,
    cancelToken: para.cancelToken,
    remoteDataSource: remoteDataSource,
  );
});
