import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/state_management/manual_app_update/manual_update_state.dart';
import 'package:mawaqit/src/state_management/on_boarding/on_boarding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:upgrader/upgrader.dart';

final manualUpdateNotifierProvider = AsyncNotifierProvider<ManualUpdateNotifier, UpdateState>(() {
  return ManualUpdateNotifier();
});

class ManualUpdateNotifier extends AsyncNotifier<UpdateState> {
  static const platform = MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel);
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

    _cleanupDownloadedFile();

    state = const AsyncValue.data(UpdateState(
      status: UpdateStatus.cancelled,
      message: 'Update cancelled',
    ));
  }

  void _cleanupDownloadedFile() {
    final filePath = state.value?.filePath;
    if (filePath != null) {
      try {
        final file = File(filePath);
        if (file.existsSync()) file.deleteSync();
      } catch (e) {
        debugPrint('Error cleaning up file: $e');
      }
    }
  }

  Future<void> checkForUpdates(
    String currentVersion,
    String languageCode,
    bool isDeviceRooted,
  ) async {
    state = const AsyncLoading();
    try {
      final hasUpdate = isDeviceRooted
          ? await _isUpdateAvailableForRootedDevice(currentVersion)
          : await _isUpdateAvailableStandard(languageCode);

      if (hasUpdate) {
        final downloadUrl = await _getLatestReleaseUrl();
        final latestVersion = await _getLatestVersion();

        state = AsyncData(state.value!.copyWith(
          status: UpdateStatus.available,
          message: 'Update available',
          downloadUrl: downloadUrl,
          currentVersion: currentVersion,
          availableVersion: latestVersion,
        ));
      } else {
        state = AsyncData(UpdateState(
          status: UpdateStatus.notAvailable,
          message: 'You are using the latest version',
          currentVersion: currentVersion,
        ));
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<bool> _isUpdateAvailableStandard(String languageCode) async {
    final upgrader = Upgrader(
      messages: UpgraderMessages(code: languageCode),
    );
    await upgrader.initialize();
    return upgrader.isUpdateAvailable();
  }

  Future<bool> _isUpdateAvailableForRootedDevice(String currentVersion) async {
    final releases = await _fetchReleases();
    final latestRelease = releases.firstWhere(
      (release) => release['prerelease'] == false,
      orElse: () => throw Exception('No stable release found'),
    );
    final latestVersion = latestRelease['tag_name'].toString();
    return _compareVersions(latestVersion, currentVersion) > 0;
  }

  Future<List<dynamic>> _fetchReleases() async {
    final response = await _dio.get(
      ManualUpdateConstant.githubApiBaseUrl,
      options: Options(
        headers: {'Accept': ManualUpdateConstant.githubAcceptHeader},
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch releases: ${response.statusCode}');
    }

    return response.data as List;
  }

  Future<String> _getLatestVersion() async {
    final releases = await _fetchReleases();
    final latestRelease = releases.firstWhere(
      (release) => release['prerelease'] == false,
      orElse: () => throw Exception('No stable release found'),
    );
    return latestRelease['tag_name'].toString();
  }

  Future<void> downloadAndInstallUpdate() async {
    final downloadUrl = state.value?.downloadUrl;
    if (downloadUrl == null) return;

    try {
      _cancelToken = CancelToken();

      state = AsyncValue.data(state.value!.copyWith(
        status: UpdateStatus.downloading,
        message: 'Downloading update...',
      ));

      final filePath = await _downloadApk(downloadUrl);

      // Check if cancelled after download
      if (_cancelToken?.isCancelled ?? false) return;

      state = AsyncValue.data(state.value!.copyWith(
        status: UpdateStatus.installing,
        message: 'Installing update...',
        filePath: filePath,
      ));

      await _installApk(filePath);

      state = AsyncValue.data(state.value!.copyWith(
        status: UpdateStatus.completed,
        message: 'Update completed successfully',
      ));
    } catch (e, st) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return; // Already handled by cancelUpdate
      }

      _handleUpdateError(e, st);
    } finally {
      _cancelToken = null;
    }
  }

  void _handleUpdateError(Object e, StackTrace st) {
    _cleanupDownloadedFile();

    state = AsyncValue.data(state.value!.copyWith(
      status: UpdateStatus.error,
      message: 'Update failed: ${e.toString()}',
    ));
  }

  Future<String> _getLatestReleaseUrl() async {
    try {
      final response = await _dio.get(
        ManualUpdateConstant.githubApiBaseUrl,
        options: Options(
          headers: {'Accept': ManualUpdateConstant.githubAcceptHeader},
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
