import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:mawaqit/src/data/repository/quran/quran_download_impl.dart';
import 'package:mawaqit/src/domain/error/quran_exceptions.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';
import 'package:mawaqit/src/helpers/connectivity_provider.dart';
import 'package:mawaqit/src/helpers/quran_path_helper.dart';
import 'package:mawaqit/src/helpers/version_helper.dart';
import 'package:mawaqit/src/models/address_model.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/moshaf_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/moshaf_type_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_notifer.dart';
import 'package:path_provider/path_provider.dart';

class DownloadQuranNotifier extends AutoDisposeAsyncNotifier<DownloadQuranState> {
  bool _isCancelled = false;
  late CancelToken _cancelToken;

  @override
  FutureOr<DownloadQuranState> build() {
    _cancelToken = CancelToken();
    ref.onDispose(() {
      _cancelToken.cancel('Notifier disposed');
    });
    return checkDownloadedQuran();
  }

  Future<DownloadQuranState> checkDownloadedQuran() async {
    if (_isCancelled) {
      return const CancelDownload();
    }
    state = const AsyncData(CheckingDownloadedQuran());
    final moshafModel = await ref.read(moshafTypeNotifierProvider.future);

    if (moshafModel.isFirstTime) {
      return const NeededDownloadedQuran();
    }

    return moshafModel.selectedMoshaf.fold(
      () => _handleNoSelectedMoshaf(moshafModel),
      (moshafType) => _handleSelectedMoshaf(moshafType),
    );
  }

  Future<DownloadQuranState> _handleNoSelectedMoshaf(MoshafState moshafModel) async {
    if (moshafModel.hafsVersion.isSome() || moshafModel.warshVersion.isSome()) {
      return const CheckingDownloadedQuran();
    } else {
      return const NeededDownloadedQuran();
    }
  }

  Future<DownloadQuranState> _handleSelectedMoshaf(MoshafType moshafType) async {
    final isDownloaded = await checkDownloaded(moshafType);
    if (isDownloaded) {
      return checkForUpdate(moshafType);
    } else {
      return _downloadQuran(moshafType);
    }
  }

  Future<DownloadQuranState> checkForUpdate(MoshafType moshafType) async {
    state = const AsyncData(CheckingUpdate());
    try {
      final downloadQuranRepoImpl = await ref.read(
        quranDownloadRepositoryProvider(
          QuranDownloadRepositoryProviderParameter(
            moshafType: moshafType,
            cancelToken: _cancelToken,
          ),
        ).future,
      );
      final localVersionOption = await downloadQuranRepoImpl.getLocalQuranVersion(moshafType: moshafType);

      final connectivityState = ref.read(connectivityProvider);
      return connectivityState.maybeWhen(
        orElse: () async {
          final remoteVersion = await downloadQuranRepoImpl.getRemoteQuranVersion(moshafType: moshafType);
          return localVersionOption.fold(
            () => UpdateAvailable(remoteVersion),
            (localVersion) => _compareVersions(moshafType, localVersion, remoteVersion),
          );
        },
        data: (connectivity) async {
          if (connectivity == ConnectivityStatus.connected) {
            final remoteVersion = await downloadQuranRepoImpl.getRemoteQuranVersion(moshafType: moshafType);

            return localVersionOption.fold(
              () => UpdateAvailable(remoteVersion),
              (localVersion) => _compareVersions(moshafType, localVersion, remoteVersion),
            );
          } else {
            final savePath = await getApplicationSupportDirectory();
            final quranPathHelper = QuranPathHelper(
              applicationSupportDirectory: savePath,
              moshafType: moshafType,
            );
            return NoUpdate(
              moshafType: moshafType,
              version: '',
              svgFolderPath: quranPathHelper.quranDirectoryPath,
            );
          }
        },
      );
    } catch (e, s) {
      state = AsyncError(e, s);
      return Error(e, s);
    }
  }

  Future<DownloadQuranState> _compareVersions(MoshafType moshafType, String localVersion, String remoteVersion) async {
    if (VersionHelper.isNewer(remoteVersion, localVersion)) {
      return UpdateAvailable(remoteVersion);
    } else {
      final savePath = await getApplicationSupportDirectory();
      final quranPathHelper = QuranPathHelper(
        applicationSupportDirectory: savePath,
        moshafType: moshafType,
      );
      return NoUpdate(
        moshafType: moshafType,
        version: remoteVersion,
        svgFolderPath: quranPathHelper.quranDirectoryPath,
      );
    }
  }

  Future<void> downloadQuran(MoshafType moshafType) async {
    state = const AsyncLoading();
    try {
      final downloadState = await _downloadQuran(moshafType);
      if (downloadState is Success) {
        await ref.read(moshafTypeNotifierProvider.notifier).setNotFirstTime();
      }
      if (downloadState is! CancelDownload) {
        state = AsyncData(downloadState);
      }
    } catch (e, s) {
      if (e is CancelDownloadException) {
        return;
      }
      state = AsyncError(e, s);
    }
  }

  Future<DownloadQuranState> _downloadQuran(MoshafType moshafType) async {
    final downloadQuranRepoImpl = await ref.read(
      quranDownloadRepositoryProvider(
        QuranDownloadRepositoryProviderParameter(
          moshafType: moshafType,
          cancelToken: _cancelToken,
        ),
      ).future,
    );
    final remoteVersion = await downloadQuranRepoImpl.getRemoteQuranVersion(moshafType: moshafType);

    await downloadQuranRepoImpl.downloadQuran(
      version: remoteVersion,
      moshafType: moshafType,
      onReceiveProgress: (progress) {
        state = AsyncData(Downloading(progress));
      },
      onExtractProgress: (progress) {
        state = AsyncData(Extracting(progress));
      },
    );

    final savePath = await getApplicationSupportDirectory();
    final quranPathHelper = QuranPathHelper(
      applicationSupportDirectory: savePath,
      moshafType: moshafType,
    );

    await ref.read(moshafTypeNotifierProvider.notifier).setNotFirstTime();

    return Success(
      moshafType: moshafType,
      version: remoteVersion,
      svgFolderPath: quranPathHelper.quranDirectoryPath,
    );
  }

  Future<void> switchMoshaf() async {
    try {
      final moshafTypeNotifier = ref.read(moshafTypeNotifierProvider.notifier);
      final currentMoshafState = await ref.read(moshafTypeNotifierProvider.future);

      final currentMoshaf = currentMoshafState.selectedMoshaf.getOrElse(() => MoshafType.hafs);

      // switch the type of moshaf
      final targetMoshaf = currentMoshaf == MoshafType.hafs ? MoshafType.warsh : MoshafType.hafs;

      final isDownloaded = await checkDownloaded(targetMoshaf);

      if (isDownloaded) {
        final updateState = await checkForUpdate(targetMoshaf);
        if (updateState is NoUpdate || updateState is Success) {
          await moshafTypeNotifier.switchMoshafType();
          state = AsyncData(updateState);
          Future.microtask(() => ref.invalidate(quranReadingNotifierProvider));
        } else {
          state = AsyncData(updateState);
          Future.microtask(() => ref.invalidate(quranReadingNotifierProvider));
        }
      } else {
        // Switch the Moshaf type before downloading
        final downloadState = await _downloadQuran(targetMoshaf);
        await moshafTypeNotifier.switchMoshafType();
        state = AsyncData(downloadState);
      }
    } catch (e, s) {
      if (e is CancelDownloadException) {
        return;
      }
      state = AsyncError(e, s);
    }
  }

  Future<void> cancelDownload(MoshafType moshafType) async {
    try {
      final downloadQuranRepoImpl = await ref.read(
        quranDownloadRepositoryProvider(
          QuranDownloadRepositoryProviderParameter(
            moshafType: moshafType,
            cancelToken: _cancelToken,
          ),
        ).future,
      );
      downloadQuranRepoImpl.cancelDownload(_cancelToken);
      _isCancelled = true;
      state = const AsyncData(CancelDownload());
      _cancelToken = CancelToken();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<bool> checkDownloaded(MoshafType moshafType) async {
    final downloadQuranRepoImpl = await ref.read(
      quranDownloadRepositoryProvider(
        QuranDownloadRepositoryProviderParameter(
          moshafType: moshafType,
          cancelToken: _cancelToken,
        ),
      ).future,
    );
    return downloadQuranRepoImpl.isQuranDownloaded(moshafType);
  }
}

final downloadQuranNotifierProvider =
    AutoDisposeAsyncNotifierProvider<DownloadQuranNotifier, DownloadQuranState>(DownloadQuranNotifier.new);
