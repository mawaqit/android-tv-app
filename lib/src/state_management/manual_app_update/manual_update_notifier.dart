import 'package:dio/dio.dart';
import 'package:mawaqit/src/state_management/manual_app_update/manual_update_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:io';

final manualUpdateNotifierProvider =
    AsyncNotifierProvider<ManualUpdateNotifier, UpdateState>(() {
  return ManualUpdateNotifier();
});

class ManualUpdateNotifier extends AsyncNotifier<UpdateState> {
  static const platform = MethodChannel('nativeMethodsChannel');
  late final Dio _dio;
  CancelToken? _cancelToken;

  @override
  Future<UpdateState> build() async {
    _dio = Dio();
    return const UpdateState();
  }

  void cancelUpdate() {
    _cancelToken?.cancel('Update cancelled by user');
    _cancelToken = null;

    // Clean up downloaded file if it exists
    if (state.value?.filePath != null) {
      try {
        final file = File(state.value!.filePath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        print('Error cleaning up file: $e');
      }
    }

    state = const AsyncValue.data(UpdateState(
      status: UpdateStatus.cancelled,
      message: 'Update cancelled',
    ));
  }

  Future<void> checkForUpdates(String currentVersion) async {
    state = const AsyncValue.data(UpdateState(
        status: UpdateStatus.checking, message: 'Checking updates...'));

    try {
      final hasUpdate = await _isUpdateAvailable(currentVersion);
      if (hasUpdate) {
        final downloadUrl = await _getLatestReleaseUrl();
        state = AsyncValue.data(state.value!.copyWith(
          status: UpdateStatus.available,
          message: 'Update available',
          downloadUrl: downloadUrl,
        ));
      } else {
        state = const AsyncValue.data(UpdateState(
          status: UpdateStatus.notAvailable,
          message: 'You are using the latest version',
        ));
      }
    } catch (e, st) {
      state = AsyncValue.error('Failed to check updates: ${e.toString()}', st);
    }
  }

  Future<void> downloadAndInstallUpdate() async {
    if (state.value?.downloadUrl == null) return;

    try {
      _cancelToken = CancelToken();

      state = AsyncValue.data(state.value!.copyWith(
        status: UpdateStatus.downloading,
        message: 'Downloading update...',
      ));

      final filePath = await _downloadApk(state.value!.downloadUrl!);

      // Check if cancelled after download
      if (_cancelToken?.isCancelled ?? false) return;

      state = AsyncValue.data(state.value!.copyWith(
        status: UpdateStatus.installing,
        message: 'Installing update...',
        filePath: filePath,
      ));

      try {
        await _installApk(filePath);
        state = AsyncValue.data(state.value!.copyWith(
          status: UpdateStatus.completed,
          message: 'Update completed successfully',
        ));
      } catch (installError) {
        state = AsyncValue.data(state.value!.copyWith(
          status: UpdateStatus.error,
          message: 'Installation failed: ${installError.toString()}',
        ));
        // Clean up the downloaded file in case of installation failure
        try {
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (cleanupError) {
          print('Failed to clean up APK file: $cleanupError');
        }
      }
    } catch (e, st) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // Handle cancellation - state already updated in cancelUpdate()
        return;
      }
      state = AsyncValue.data(state.value!.copyWith(
        status: UpdateStatus.error,
        message: 'Update failed: ${e.toString()}',
      ));
    } finally {
      _cancelToken = null;
    }
  }

  Future<String> _getLatestReleaseUrl() async {
    try {
      final response = await _dio.get(
        'https://api.github.com/repos/mawaqit/android-tv-app/releases',
        options: Options(
          headers: {'Accept': 'application/vnd.github.v3+json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final releases = response.data as List;
        final latestRelease = releases.firstWhere(
          (release) => release['prerelease'] == false,
          orElse: () => throw Exception('No stable release found'),
        );

        final assets = latestRelease['assets'] as List;
        final apkAsset = assets.firstWhere(
          (asset) => asset['name'].toString().endsWith('.apk'),
          orElse: () => throw Exception('No APK found in latest release'),
        );

        return apkAsset['browser_download_url'];
      }
      throw Exception('Failed to fetch releases: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching latest release: $e');
    }
  }

  Future<String> _downloadApk(String url) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/update.apk';

      await _dio.download(
        url,
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            state = AsyncValue.data(state.value!.copyWith(progress: progress));
          }
        },
      );

      return filePath;
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        throw e; // Rethrow cancellation to be handled in downloadAndInstallUpdate
      }
      throw Exception('Error downloading APK: $e');
    }
  }

  Future<void> _installApk(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('APK file not found');
      }

      final result = await platform.invokeMethod('installApk', {
        'filePath': filePath,
      });

      await file.delete();

      if (result != true) {
        throw Exception('Installation failed');
      }
    } catch (e) {
      throw Exception('Error installing APK: $e');
    }
  }

  Future<bool> _isUpdateAvailable(String currentVersion) async {
    try {
      final response = await _dio.get(
        'https://api.github.com/repos/mawaqit/android-tv-app/releases',
        options: Options(
          headers: {'Accept': 'application/vnd.github.v3+json'},
        ),
      );

      if (response.statusCode == 200) {
        final releases = response.data as List;
        final latestRelease = releases.firstWhere(
          (release) => release['prerelease'] == false,
          orElse: () => throw Exception('No stable release found'),
        );

        final latestVersion = latestRelease['tag_name'].toString();
        return _compareVersions(latestVersion, currentVersion) > 0;
      }
      return false;
    } catch (e) {
      throw Exception('Error checking for updates: $e');
    }
  }

  int _compareVersions(String v1, String v2) {
    final version1 = v1.replaceAll('v', '').split('.');
    final version2 = v2.replaceAll('v', '').split('.');

    for (var i = 0; i < version1.length && i < version2.length; i++) {
      final num1 = int.parse(version1[i]);
      final num2 = int.parse(version2[i]);
      if (num1 != num2) {
        return num1 - num2;
      }
    }
    return version1.length - version2.length;
  }
}
