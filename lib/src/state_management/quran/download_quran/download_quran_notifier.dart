import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mawaqit/src/data/repository/quran/quran_download_impl.dart';
import 'package:mawaqit/src/domain/error/quran_exceptions.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';
import 'package:mawaqit/src/helpers/quran_path_helper.dart';
import 'package:mawaqit/src/helpers/version_helper.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/moshaf_type_notifier.dart';
import 'package:path_provider/path_provider.dart';

class DownloadQuranNotifier extends AutoDisposeAsyncNotifier<DownloadQuranState> {
  @override
  FutureOr<DownloadQuranState> build() async {
    return await checkDownloadedQuran();
  }

  Future<DownloadQuranState> checkDownloadedQuran() async {
    state = const AsyncData(CheckingDownloadedQuran());
    final mosqueModel = await ref.read(moshafTypeNotifierProvider.future);
    return mosqueModel.selectedMoshaf.fold(
      () => NeededDownloadedQuran(),
      (moshafType) async {
        final isDownloaded = await checkDownloaded(moshafType);
        if (isDownloaded) {
          final state = await checkForUpdate(moshafType);
          return state;
         } else {
          return NeededDownloadedQuran();
        }
      },
    );
  }

  Future<DownloadQuranState> checkForUpdate(MoshafType moshafType) async {
    state = const AsyncData(CheckingUpdate());
    try {
      final downloadQuranRepoImpl = await ref.read(quranDownloadRepositoryProvider(moshafType).future);
      final localVersion = await downloadQuranRepoImpl.getLocalQuranVersion(moshafType: moshafType);
      final remoteVersion = await downloadQuranRepoImpl.getRemoteQuranVersion(moshafType: moshafType);

      if (localVersion == null || VersionHelper.isNewer(remoteVersion, localVersion)) {
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
    } catch (e, s) {
      rethrow;
    }
  }

  Future<void> downloadQuran(MoshafType moshafType) async {
    state = const AsyncLoading();
    try {
      final downloadQuranRepoImpl = await ref.read(quranDownloadRepositoryProvider(moshafType).future);
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

      state = AsyncData(
        Success(
          moshafType: moshafType,
          version: remoteVersion,
          svgFolderPath: quranPathHelper.quranDirectoryPath,
        ),
      );
    } catch (e, s) {
      if (e is CancelDownloadException) {
        state = const AsyncData(CancelDownload());
      } else {
        state = AsyncError(e, s);
      }
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

// MoshafType
}

final downloadQuranNotifierProvider =
    AutoDisposeAsyncNotifierProvider<DownloadQuranNotifier, DownloadQuranState>(DownloadQuranNotifier.new);
