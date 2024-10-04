import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/error/quran_exceptions.dart';
import 'package:mawaqit/src/helpers/directory_helper.dart';
import 'package:mawaqit/src/helpers/version_helper.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mawaqit/src/helpers/quran_path_helper.dart';

class DownloadQuranRemoteDataSource {
  final Dio dio;
  final QuranPathHelper quranPathHelper;

  DownloadQuranRemoteDataSource({
    required this.dio,
    required this.quranPathHelper,
  });

  /// [getRemoteQuranVersion] fetches the remote quran version
  Future<String> getRemoteQuranVersion({
    required MoshafType moshafType,
  }) async {
    try {
      log('quran: DownloadQuranRemoteDataSource: getRemoteQuranVersion - start');
      final parameterName = _getConfigurationParameters(moshafType);
      log('quran: DownloadQuranRemoteDataSource: getRemoteQuranVersion - parameterName $parameterName');
      final version = await dio.get(QuranConstant.quranMoshafConfigJsonUrl).then((value) {
        // log('quran: DownloadQuranRemoteDataSource: getRemoteQuranVersion - $value');
        return value.data[parameterName];
      });
      log('quran: DownloadQuranRemoteDataSource: getRemoteQuranVersion - version $version');
      return VersionHelper.extractVersion(version);
    } catch (e) {
      throw FetchRemoteQuranVersionException(e.toString());
    }
  }

  /// [downloadQuranWithProgress] downloads the quran zip file
  Future<void> downloadQuranWithProgress({
    required String version,
    required MoshafType moshafType,
    required Function(double) onReceiveProgress,
    required CancelToken cancelToken,
  }) async {
    try {
      final url = _getUrlByMoshafType(moshafType, version);
      await dio.download(
        url,
        quranPathHelper.getQuranZipFilePath(version),
        deleteOnError: true,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total) * 100;
            onReceiveProgress(progress);
          }
        },
        cancelToken: cancelToken,
      );
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        await DirectoryHelper.deleteDirectories([
          quranPathHelper.quranZipDirectoryPath,
          quranPathHelper.quranDirectoryPath,
        ]);
      }
      rethrow;
    }
  }


  void cancelDownload(CancelToken cancelToken) {
    cancelToken.cancel();
    log('quran: checkDownloaded: cancelDownload  ${cancelToken.hashCode}');
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

class DownloadQuranRemoteDataSourceProviderParameter extends Equatable {
  final MoshafType moshafType;
  final CancelToken cancelToken;

  DownloadQuranRemoteDataSourceProviderParameter({
    required this.moshafType,
    required this.cancelToken,
  });

  @override
  List<Object> get props => [moshafType, cancelToken];
}

final downloadQuranRemoteDataSourceProvider =
    FutureProvider.family<DownloadQuranRemoteDataSource, DownloadQuranRemoteDataSourceProviderParameter>(
  (ref, para) async {
    final quranPathHelper = QuranPathHelper(
      applicationSupportDirectory: await getApplicationSupportDirectory(),
      moshafType: para.moshafType,
    );
    return DownloadQuranRemoteDataSource(
      quranPathHelper: quranPathHelper,
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
