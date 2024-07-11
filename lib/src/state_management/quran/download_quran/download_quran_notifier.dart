import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mawaqit/src/data/repository/quran/quran_download_impl.dart';
import 'package:mawaqit/src/domain/error/quran_exceptions.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';
import 'package:path_provider/path_provider.dart';

class DownloadQuranNotifier extends AsyncNotifier<DownloadQuranState> {
  @override
  FutureOr<DownloadQuranState> build() {
    return Initial();
  }

  /// [checkForUpdate] checks for the Quran update
  ///
  /// If the Quran is not downloaded or the remote version is different from the local version,
  Future<void> checkForUpdate() async {
    try {
      state = AsyncLoading();

      final downloadQuranRepoImpl = await ref.read(quranDownloadRepositoryProvider.future);
      final localVersion = await downloadQuranRepoImpl.getLocalQuranVersion();
      final remoteVersion = await downloadQuranRepoImpl.getRemoteQuranVersion();

      if (localVersion == null || remoteVersion != localVersion) {
        state = AsyncData(UpdateAvailable(remoteVersion));
      } else {
        final savePath = await getApplicationSupportDirectory();
        final svgFolderPath = '${savePath.path}/quran';
        state = AsyncData(
          NoUpdate(
            version: remoteVersion,
            svgFolderPath: svgFolderPath,
          ),
        );
      }
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  /// [download] downloads the Quran and extracts it
  Future<void> download() async {
    try {
      // Notify that the update check has started
      state = AsyncLoading();

      final downloadQuranRepoImpl = await ref.read(quranDownloadRepositoryProvider.future);
      final localVersion = await downloadQuranRepoImpl.getLocalQuranVersion();
      final remoteVersion = await downloadQuranRepoImpl.getRemoteQuranVersion();

      if (localVersion == null || remoteVersion != localVersion) {
        // Notify that the download has started
        state = AsyncData(Downloading(0));

        final cancelToken = CancelToken();
        // Download the Quran
        await downloadQuranRepoImpl.downloadQuran(
          version: remoteVersion,
          onReceiveProgress: (progress) {
            state = AsyncData(Downloading(progress));
          },
        );

        // Notify that the extraction has started
        state = AsyncData(Extracting(0));

        await downloadQuranRepoImpl.deleteOldQuran();

        final savePath = await getApplicationSupportDirectory();
        final filePath = '${savePath.path}/quran_zip/$remoteVersion';
        final destinationDir = Directory('${savePath.path}/quran');

        // Extract the Quran
        await downloadQuranRepoImpl.extractQuran(
          zipFilePath: filePath,
          destinationPath: destinationDir.path,
          onExtractProgress: (progress) {
            state = AsyncData(Extracting(progress));
          },
        );

        // Delete the old Quran files

        // Delete the downloaded ZIP file
        await downloadQuranRepoImpl.deleteZipFile(remoteVersion);

        // Notify the success state with the new version
        state = AsyncData(
          Success(
            version: remoteVersion,
            svgFolderPath: destinationDir.path,
          ),
        );
      } else {
        final savePath = await getApplicationSupportDirectory();
        final svgFolderPath = '${savePath.path}/quran';
        state = AsyncData(
          NoUpdate(
            version: remoteVersion,
            svgFolderPath: svgFolderPath,
          ),
        );
      }
    } on CancelDownloadException catch (e, s) {
      state = AsyncData(CancelDownload());
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  /// [cancelDownload] cancels the download
  Future<void> cancelDownload() async {
    try {
      state = AsyncLoading();
      final downloadQuranRepoImpl = await ref.read(quranDownloadRepositoryProvider.future);
      downloadQuranRepoImpl.cancelDownload();
      state = AsyncData(CancelDownload());
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}

final downloadQuranNotifierProvider =
    AsyncNotifierProvider<DownloadQuranNotifier, DownloadQuranState>(DownloadQuranNotifier.new);
