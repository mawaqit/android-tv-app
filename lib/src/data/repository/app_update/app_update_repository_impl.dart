import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/data/data_source/app_update/github_update_data_source.dart';
import 'package:mawaqit/src/data/data_source/app_update/github_update_local_data_source.dart';
import 'package:mawaqit/src/data/data_source/app_update/store_update_local_data_source.dart';
import 'package:mawaqit/src/data/data_source/app_update/store_update_remote_data_source.dart';
import 'package:mawaqit/src/domain/model/app_update_info.dart';
import 'package:mawaqit/src/domain/model/download_progress.dart';
import 'package:mawaqit/src/domain/repository/app_update/app_update_repository.dart';

class AppUpdateRepositoryImpl implements AppUpdateRepository {
  final GitHubUpdateRemoteDataSource _githubDataSource;
  final StoreUpdateRemoteDataSource _storeDataSource;
  final GithubUpdateLocalDataSource _githubLocalDataSource;
  final StoreUpdateLocalDataSource _storeLocalDataSource;
  final bool _isRooted;

  AppUpdateRepositoryImpl({
    required GitHubUpdateRemoteDataSource githubDataSource,
    required StoreUpdateRemoteDataSource storeDataSource,
    required GithubUpdateLocalDataSource githubLocalDataSource,
    required StoreUpdateLocalDataSource storeLocalDataSource,
    required bool isRooted,
  })  : _githubDataSource = githubDataSource,
        _storeDataSource = storeDataSource,
        _githubLocalDataSource = githubLocalDataSource,
        _storeLocalDataSource = storeLocalDataSource,
        _isRooted = isRooted;

  @override
  Future<UpdateInfo> getLatestUpdate(String languageCode) async {
    try {
      return _isRooted ? await _githubDataSource.getLatestUpdate() : await _storeDataSource.getLatestUpdate();
    } catch (e) {
      throw Exception('Failed to get latest update: $e');
    }
  }

  @override
  Future<bool> isUpdateAvailable(String currentVersion, String languageCode) async {
    try {
      if (_isRooted) {
        final latestUpdate = await _githubDataSource.getLatestUpdate();
        return latestUpdate.version != currentVersion;
      } else {
        return await _storeDataSource.isUpdateAvailable();
      }
    } catch (e) {
      throw Exception('Failed to check update availability: $e');
    }
  }

  @override
  Future<String?> downloadUpdate(String url, void Function(DownloadProgress) onProgress) async {
    if (!_isRooted) return null;
    try {
      return await _githubDataSource.downloadUpdate(url, onProgress);
    } catch (e) {
      throw Exception('Failed to download update: $e');
    }
  }

  @override
  Future<void> openStore() async {
    if (!_isRooted) {
      await _storeDataSource.openStore();
    }
  }

  @override
  Future<void> cancelUpdate() async {
    // Only GitHub updates can be cancelled for rooted devices
    if (_isRooted) {
      // await _githubDataSource.cancelUpdate();
    }
  }

  @override
  Future<bool> isDismissed() async {
    try {
      return _isRooted
          ? (await _githubLocalDataSource.getLastUpdateCheck()) != null
          : await _storeLocalDataSource.isDismissed();
    } catch (e) {
      throw Exception('Failed to check dismiss status: $e');
    }
  }

  @override
  Future<void> setDismissed(bool value) async {
    try {
      if (_isRooted) {
        if (value) await _githubLocalDataSource.saveLastUpdateCheck(DateTime.now());
      } else {
        await _storeLocalDataSource.setDismissed(value);
      }
    } catch (e) {
      throw Exception('Failed to set dismiss status: $e');
    }
  }

  @override
  Future<bool> isAutoUpdateEnabled() async {
    try {
      return await _storeLocalDataSource.isAutoUpdateEnabled();
    } catch (e) {
      throw Exception('Failed to check auto update status: $e');
    }
  }

  @override
  Future<void> setAutoUpdateEnabled(bool value) async {
    try {
      await _storeLocalDataSource.setAutoUpdateEnabled(value);
    } catch (e) {
      throw Exception('Failed to set auto update status: $e');
    }
  }

  @override
  Future<String?> getDismissedVersion() async {
    try {
      return _isRooted
          ? await _githubLocalDataSource.getCurrentVersion()
          : await _storeLocalDataSource.getDismissedVersion();
    } catch (e) {
      throw Exception('Failed to get dismissed version: $e');
    }
  }

  @override
  Future<void> setDismissedVersion(String version) async {
    try {
      if (_isRooted) {
        await _githubLocalDataSource.saveCurrentVersion(version);
      } else {
        await _storeLocalDataSource.setDismissedVersion(version);
      }
    } catch (e) {
      throw Exception('Failed to set dismissed version: $e');
    }
  }

  @override
  Future<DateTime?> getLastUpdateCheck() async {
    try {
      return await _githubLocalDataSource.getLastUpdateCheck();
    } catch (e) {
      throw Exception('Failed to get last update check: $e');
    }
  }

  @override
  Future<void> saveLastUpdateCheck(DateTime timestamp) async {
    try {
      await _githubLocalDataSource.saveLastUpdateCheck(timestamp);
    } catch (e) {
      throw Exception('Failed to save last update check: $e');
    }
  }
}

class AppUpdateRepositoryParameters {
  final bool isRooted;
  final String languageCode;

  const AppUpdateRepositoryParameters({
    required this.isRooted,
    required this.languageCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUpdateRepositoryParameters &&
          runtimeType == other.runtimeType &&
          isRooted == other.isRooted &&
          languageCode == other.languageCode;

  @override
  int get hashCode => isRooted.hashCode ^ languageCode.hashCode;
}

final appUpdateRepositoryProvider = FutureProvider.family<AppUpdateRepository, AppUpdateRepositoryParameters>(
  (ref, params) async {
    final githubRemote = await ref.read(githubUpdateDataSourceProvider.future);
    final storeRemote = ref.read(storeUpdateRemoteDataSourceProvider(params.languageCode));
    final githubLocal = await ref.read(githubUpdateLocalDataSourceProvider.future);
    final storeLocal = await ref.read(storeUpdateLocalDataSourceProvider.future);

    return AppUpdateRepositoryImpl(
      githubDataSource: githubRemote,
      storeDataSource: storeRemote,
      githubLocalDataSource: githubLocal,
      storeLocalDataSource: storeLocal,
      isRooted: params.isRooted,
    );
  },
);
