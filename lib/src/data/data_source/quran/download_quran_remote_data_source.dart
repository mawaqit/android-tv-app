import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/error/quran_exceptions.dart';
import 'package:mawaqit/src/helpers/directory_helper.dart';
import 'package:mawaqit/src/helpers/version_helper.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mawaqit/src/helpers/quran_path_helper.dart';

class DownloadQuranRemoteDataSource {
  final Dio dio;
  final QuranPathHelper quranPathHelper;
  CancelToken? cancelToken;

  DownloadQuranRemoteDataSource({
    required this.dio,
    required this.quranPathHelper,
    this.cancelToken,
  });

  /// [getRemoteQuranVersion] fetches the remote quran version
  Future<String> getRemoteQuranVersion({
    required MoshafType moshafType,
  }) async {
    try {
      log('quran: DownloadQuranRemoteDataSource: getRemoteQuranVersion - start');
      final parameterName = _getConfigurationParameters(moshafType);
      log('quran: DownloadQuranRemoteDataSource: getRemoteQuranVersion - $parameterName');
      final version = await dio.get(QuranConstant.quranMoshafConfigJsonUrl).then((value) {
        log('quran: DownloadQuranRemoteDataSource: getRemoteQuranVersion - $value');
        return value.data[parameterName];
      });
      log('quran: DownloadQuranRemoteDataSource: getRemoteQuranVersion - $version');
      return VersionHelper.extractVersion(version);
    } catch (e) {
      throw FetchRemoteQuranVersionException(e.toString());
    }
  }

  /// [downloadQuranWithProgress] downloads the quran zip file
  Future<void> downloadQuranWithProgress({
    required String version,
    required MoshafType moshafType,
    Function(double)? onReceiveProgress,
  }) async {
    log('quran: DownloadQuranRemoteDataSource: downloadQuranWithProgress - filePath: ${quranPathHelper.quranDirectoryPath}');

    try {
      final url = _getUrlByMoshafType(moshafType, version);
      log('downloadQuranWithProgress: url: ${url}');
      await dio.download(
        url,
        quranPathHelper.getQuranZipFilePath(version),
        onReceiveProgress: (received, total) {
          final progress = (received / total) * 100;
          // log('quran: DownloadQuranRemoteDataSource: downloadQuranWithProgress - progress: $progress');
          onReceiveProgress?.call(progress);
        },
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        log('quran: DownloadQuranRemoteDataSource: downloadQuranWithProgress - download cancelled');
        await DirectoryHelper.deleteDirectories([
          quranPathHelper.quranZipDirectoryPath,
          quranPathHelper.quranDirectoryPath,
        ]);
        throw CancelDownloadException();
      }
      throw Exception('Error occurred while downloading quran: $e');
    } catch (e) {
      await DirectoryHelper.deleteDirectories([
        quranPathHelper.quranZipDirectoryPath,
        quranPathHelper.quranDirectoryPath,
      ]);
      throw UnknownException(e.toString());
    }
  }

  /// [cancelDownload] cancels the download
  void cancelDownload() {
    cancelToken?.cancel();
    cancelToken = CancelToken();
    log('quran: DownloadQuranRemoteDataSource: cancelDownload - download cancelled');
  }

  String _getUrlByMoshafType(MoshafType moshafType, String version) {
    log('type before: $moshafType and url: $version');
    switch (moshafType) {
      case MoshafType.warsh:
        return '${QuranConstant.kQuranZipBaseUrl}warsh-v$version.zip';
      case MoshafType.hafs:
        String url = '${QuranConstant.kQuranZipBaseUrl}hafs-v$version.zip';
        log('type: $moshafType and url: $url');
        return url;
    }
  }

  String _getConfigurationParameters(MoshafType moshafType) {
    switch (moshafType) {
      case MoshafType.warsh:
        return 'warshFileName';
      case MoshafType.hafs:
        return 'hafsfileName';
    }
  }
}

final downloadQuranRemoteDataSourceProvider = FutureProvider.family<DownloadQuranRemoteDataSource, MoshafType>(
  (ref, type) async {
    final quranPathHelper = QuranPathHelper(
      applicationSupportDirectory: await getApplicationSupportDirectory(),
      moshafType: type,
    );
    final cancelToken = CancelToken();
    return DownloadQuranRemoteDataSource(
      quranPathHelper: quranPathHelper,
      cancelToken: cancelToken,
      dio: ref.read(dioProvider),
    );
  },
);

final dioProvider = Provider(
  (ref) => Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      headers: {
        'Api-Access-Token': kApiToken,
        'accept': 'application/json',
        'mawaqit-device': 'android-tv',
      },
    ),
  ),
);
