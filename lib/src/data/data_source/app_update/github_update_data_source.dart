import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/app_update_info.dart';
import 'package:mawaqit/src/domain/model/download_progress.dart';
import 'package:mawaqit/src/module/dio_module.dart';
import 'package:path_provider/path_provider.dart';

class GitHubUpdateRemoteDataSource {
  final Dio _dio;
  final CancelToken? _cancelToken;

  GitHubUpdateRemoteDataSource({
    Dio? dio,
    CancelToken? cancelToken,
  })  : _dio = dio ?? Dio(),
        _cancelToken = cancelToken;

  Future<UpdateInfo> getLatestUpdate() async {
    try {
      final response = await _dio.get(
        AppUpdateConstant.kGitHubRepoEndpoint,
        options: Options(
            headers: {AppUpdateConstant.kAcceptHeader: AppUpdateConstant.kGitHubApiAcceptHeader}
        ),
        cancelToken: _cancelToken,
      );

      if (response.statusCode == 200) {
        final releases = response.data as List;
        final latestRelease = releases.firstWhere(
          (release) => release['prerelease'] == false,
          orElse: () => throw Exception('No stable release found'),
        );

        return UpdateInfo.fromJson(latestRelease);
      }
      throw Exception('Failed to fetch releases: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching latest release: $e');
    }
  }

  Future<String> downloadUpdate(
    String url,
    void Function(DownloadProgress) onProgress,
  ) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${AppUpdateConstant.kUpdateFileName}';

      await _dio.download(
        url,
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(DownloadProgress(
              progress: received / total,
              downloaded: received,
              total: total,
            ));
          }
        },
      );

      return filePath;
    } catch (e) {
      throw Exception('Error downloading APK: $e');
    }
  }
}

final githubUpdateDataSourceProvider = FutureProvider<GitHubUpdateRemoteDataSource>((ref) async {
  // final dio = ref.read(dioProvider(
  //   DioProviderParameter(baseUrl: 'https://api.github.com/'),
  // ));
  return GitHubUpdateRemoteDataSource(cancelToken: CancelToken(), dio: Dio());
});
