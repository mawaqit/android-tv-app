import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';

import 'package:mawaqit/src/data/repository/quran/quran_download_impl.dart';
import 'package:mawaqit/src/domain/error/quran_exceptions.dart';
import 'package:mawaqit/src/helpers/quran_path_helper.dart';
import 'package:mawaqit/src/helpers/version_helper.dart';
import 'package:mawaqit/src/module/shared_preference_module.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';
import 'package:path_provider/path_provider.dart';

class DownloadQuranNotifier extends AsyncNotifier<DownloadQuranState> {
  @override
  FutureOr<DownloadQuranState> build() {
    return Initial();
  }

  /// [checkForUpdate] checks for the Quran update
  ///
  /// If the Quran is not downloaded or the remote version is different from the local version,
  Future<void> checkForUpdate(MoshafType moshafType) async {
    try {
      state = AsyncLoading();

      final downloadQuranRepoImpl = await ref.read(quranDownloadRepositoryProvider(moshafType).future);
      final localVersion = await downloadQuranRepoImpl.getLocalQuranVersion(moshafType: moshafType);
      final remoteVersion = await downloadQuranRepoImpl.getRemoteQuranVersion(moshafType: moshafType);
      if (localVersion == null || VersionHelper.isNewer(remoteVersion, localVersion)) {
        state = AsyncData(UpdateAvailable(remoteVersion));
      } else {
        final savePath = await getApplicationSupportDirectory();
        final quranPathHelper = QuranPathHelper(
          applicationSupportDirectory: savePath,
          moshafType: MoshafType.warsh,
        );
        state = AsyncData(
          NoUpdate(
            version: remoteVersion,
            svgFolderPath: quranPathHelper.quranDirectoryPath,
          ),
        );
      }
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  /// [download] downloads the Quran and extracts it
  Future<void> download(MoshafType moshafType) async {
    try {
      // Notify that the update check has started
      state = AsyncLoading();

      final downloadQuranRepoImpl = await ref.read(quranDownloadRepositoryProvider(moshafType).future);
      final localVersion = await downloadQuranRepoImpl.getLocalQuranVersion(moshafType: moshafType);
      final remoteVersion = await downloadQuranRepoImpl.getRemoteQuranVersion(moshafType: moshafType);

      _saveSelectedMoshaf(moshafType);

      if (localVersion == null || remoteVersion != localVersion) {
        // Notify that the download has started
        state = AsyncData(Downloading(0));

        // Download the Quran
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
        // Notify the success state with the new version
        state = AsyncData(
          Success(
            version: remoteVersion,
            svgFolderPath: quranPathHelper.quranDirectoryPath,
          ),
        );
      } else {
        final dir = await getApplicationSupportDirectory();
        final quranPathHelper = QuranPathHelper(
          applicationSupportDirectory: dir,
          moshafType: moshafType,
        );
        state = AsyncData(
          NoUpdate(
            version: remoteVersion,
            svgFolderPath: quranPathHelper.quranDirectoryPath,
          ),
        );
      }
    } on CancelDownloadException catch (e, s) {
      state = AsyncData(CancelDownload());
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  /// using shared preference
  /// to save the selected moshaf
  Future<void> _saveSelectedMoshaf(MoshafType moshafType) async {
    final sharedPreference = await ref.read(sharedPreferenceModule.future);
    final success = await sharedPreference.setString(CacheKey.kSelectedMoshaf, moshafType.name.toString());
    if(!success) {
      throw Exception('Failed to save selected moshaf');
    }
  }

  Future<MoshafType> getSelectedMoshaf() async {
    final sharedPreference = await ref.read(sharedPreferenceModule.future);
    final moshaf = sharedPreference.getString(CacheKey.kSelectedMoshaf) ?? MoshafType.warsh.name.toString();
    MoshafType moshafType = MoshafType.fromString(moshaf);
    return moshafType;
  }

  /// [cancelDownload] cancels the download
  Future<void> cancelDownload() async {
    try {
      state = AsyncLoading();
      final downloadQuranRepoImpl = await ref.read(quranDownloadRepositoryProvider(MoshafType.warsh).future);
      downloadQuranRepoImpl.cancelDownload();
      state = AsyncData(CancelDownload());
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}

final downloadQuranNotifierProvider =
    AsyncNotifierProvider<DownloadQuranNotifier, DownloadQuranState>(DownloadQuranNotifier.new);
