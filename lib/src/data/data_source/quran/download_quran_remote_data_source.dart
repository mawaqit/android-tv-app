import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/error/quran_exceptions.dart';
import 'package:mawaqit/src/helpers/directory_helper.dart';
import 'package:path_provider/path_provider.dart';

class DownloadQuranRemoteDataSource {
  final Dio dio;
  CancelToken? cancelToken;
  final String applicationSupportDirectoryPath;

  DownloadQuranRemoteDataSource({
    required this.dio,
    required this.applicationSupportDirectoryPath,
    this.cancelToken,
  });

  /// [getRemoteQuranVersion] fetches the remote quran version
  Future<String> getRemoteQuranVersion({
    String url = "https://mawaqit.github.io/mawaqit-announcements/public/quran/config.json",
  }) async {
    try {
      log('quran: DownloadQuranRemoteDataSource: getRemoteQuranVersion - start');
      final version = await dio.get(url).then((value) {
        return value.data['fileName'];
      });
      log('quran: DownloadQuranRemoteDataSource: getRemoteQuranVersion - $version');
      return version as String;
    } catch (e) {
      throw FetchRemoteQuranVersionException(e.toString());
    }
  }

  /// [downloadQuranWithProgress] downloads the quran zip file
  Future<void> downloadQuranWithProgress({
    required String versionName,
    String? applicationDirectoryPath,
    String url = "https://mawaqit.github.io/mawaqit-announcements/public/quran/",
    Function(double)? onReceiveProgress,
  }) async {
    log('quran: DownloadQuranRemoteDataSource: downloadQuranWithProgress - start');
    applicationDirectoryPath ??= applicationSupportDirectoryPath;

    final filePath = '$applicationDirectoryPath/quran_zip/$versionName';
    log('quran: DownloadQuranRemoteDataSource: downloadQuranWithProgress - filePath: $filePath');

    try {
      await dio.download(
        '$url$versionName',
        filePath,
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
        await DirectoryHelper.deleteFileIfExists(filePath);
        await DirectoryHelper.deleteDirectories([
          '$applicationDirectoryPath/quran_zip',
          '$applicationDirectoryPath/quran',
        ]);
        throw CancelDownloadException();
      }
      throw Exception('Error occurred while downloading quran: $e');
    } catch (e) {
      await DirectoryHelper.deleteFileIfExists(filePath);
      await DirectoryHelper.deleteDirectories([
        '$applicationDirectoryPath/quran_zip',
        '$applicationDirectoryPath/quran',
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
}

final downloadQuranRemoteDataSourceProvider = FutureProvider<DownloadQuranRemoteDataSource>(
  (ref) async {
    final savePath = await getApplicationSupportDirectory();
    final cancelToken = CancelToken();
    return DownloadQuranRemoteDataSource(
      applicationSupportDirectoryPath: savePath.path,
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
