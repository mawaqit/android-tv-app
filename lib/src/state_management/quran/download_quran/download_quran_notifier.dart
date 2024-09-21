import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:mawaqit/src/data/repository/quran/quran_download_impl.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';
import 'package:mawaqit/src/helpers/quran_path_helper.dart';
import 'package:mawaqit/src/helpers/version_helper.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/moshaf_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/moshaf_type_notifier.dart';
import 'package:path_provider/path_provider.dart';

class DownloadQuranNotifier extends AutoDisposeAsyncNotifier<DownloadQuranState> {
  @override
  FutureOr<DownloadQuranState> build() => checkDownloadedQuran();

  Future<DownloadQuranState> checkDownloadedQuran() async {
    state = const AsyncData(CheckingDownloadedQuran());
    final moshafModel = await ref.read(moshafTypeNotifierProvider.future);

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
      final downloadQuranRepoImpl = await ref.read(quranDownloadRepositoryProvider(moshafType).future);
      final localVersionOption = await downloadQuranRepoImpl.getLocalQuranVersion(moshafType: moshafType);
      final remoteVersion = await downloadQuranRepoImpl.getRemoteQuranVersion(moshafType: moshafType);

      return localVersionOption.fold(
        () => UpdateAvailable(remoteVersion),
        (localVersion) => _compareVersions(moshafType, localVersion, remoteVersion),
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
      state = AsyncData(downloadState);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<DownloadQuranState> _downloadQuran(MoshafType moshafType) async {
    final downloadQuranRepoImpl = await ref.read(quranDownloadRepositoryProvider(moshafType).future);
    final remoteVersion = await downloadQuranRepoImpl.getRemoteQuranVersion(moshafType: moshafType);

    await downloadQuranRepoImpl.downloadQuran(
      version: remoteVersion,
      moshafType: moshafType,
      onReceiveProgress: (progress) => state = AsyncData(Downloading(progress)),
      onExtractProgress: (progress) => state = AsyncData(Extracting(progress)),
    );

    final savePath = await getApplicationSupportDirectory();
    final quranPathHelper = QuranPathHelper(
      applicationSupportDirectory: savePath,
      moshafType: moshafType,
    );

    return Success(
      moshafType: moshafType,
      version: remoteVersion,
      svgFolderPath: quranPathHelper.quranDirectoryPath,
    );
  }

  Future<void> switchMoshaf() async {
    await ref.read(moshafTypeNotifierProvider.notifier).switchMoshafType();
    final moshafTypeState = ref.read(moshafTypeNotifierProvider);

    moshafTypeState.whenOrNull(
      data: (moshafType) => moshafType.selectedMoshaf.fold(
        () => state = const AsyncData(NeededDownloadedQuran()),
        (moshaf) => _handleMoshafSwitch(moshaf),
      ),
    );
  }

  Future<void> _handleMoshafSwitch(MoshafType moshaf) async {
    final isDownloaded = await checkDownloaded(moshaf);

    if (isDownloaded) {
      final updateState = await checkForUpdate(moshaf);
      state = AsyncData(updateState is NoUpdate
          ? Success(
              moshafType: moshaf,
              version: updateState.version,
              svgFolderPath: updateState.svgFolderPath,
            )
          : updateState);
    } else {
      await downloadQuran(moshaf);
    }
  }

  Future<void> cancelDownload(MoshafType moshafType) async {
    try {
      final downloadQuranRepoImpl = await ref.read(quranDownloadRepositoryProvider(moshafType).future);
      downloadQuranRepoImpl.cancelDownload();
      state = const AsyncData(CancelDownload());
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<bool> checkDownloaded(MoshafType moshafType) async {
    final downloadQuranRepoImpl = await ref.read(quranDownloadRepositoryProvider(moshafType).future);
    return downloadQuranRepoImpl.isQuranDownloaded(moshafType);
  }
}

final downloadQuranNotifierProvider =
    AutoDisposeAsyncNotifierProvider<DownloadQuranNotifier, DownloadQuranState>(DownloadQuranNotifier.new);
