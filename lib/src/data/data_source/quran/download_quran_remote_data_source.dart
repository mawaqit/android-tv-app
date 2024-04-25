import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:path_provider/path_provider.dart';

class DownloadQuranRemoteDataSource {
  final Dio dio;
  final CancelToken? cancelToken;
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
      return version;
    } catch (e) {
      throw Exception('Error occurred while fetching remote quran version: $e');
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
          final progress = received / total;
          log('quran: DownloadQuranRemoteDataSource: downloadQuranWithProgress - progress: $progress');
          onReceiveProgress?.call(progress);
        },
        cancelToken: cancelToken,
      );
      log('quran: DownloadQuranRemoteDataSource: downloadQuranWithProgress - end');
    } catch (e) {
      throw Exception('Error occurred while downloading quran: $e');
    }
  }

  /// [cancelDownload] cancels the download
  void cancelDownload() {
    cancelToken?.cancel();
    log('quran: DownloadQuranRemoteDataSource: cancelDownload - download cancelled');
  }
}

final downloadQuranRemoteDataSourceProvider = FutureProvider<DownloadQuranRemoteDataSource>(
  (ref) async {
    final savePath = await getApplicationSupportDirectory();
    return DownloadQuranRemoteDataSource(
      applicationSupportDirectoryPath: savePath.path,
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
