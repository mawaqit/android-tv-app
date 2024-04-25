// download_quran_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mawaqit/src/data/repository/quran/quran_download_impl.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';

class DownloadQuranNotifier extends AsyncNotifier<DownloadQuranState> {
  @override
  build() {
    return Initial();
  }

  Future<void> download(String url, String filePath) async {
    try {
      // Notify that the update check has started
      state = AsyncLoading();

      final downloadQuranRepoImpl = await ref.read(quranDownloadRepositoryProvider.future);
      final localVersion = await downloadQuranRepoImpl.getLocalQuranVersion();
      final remoteVersion = await downloadQuranRepoImpl.getRemoteQuranVersion();

      if (localVersion == null || remoteVersion != localVersion) {
        // Notify that the download has started
        state = AsyncData(Downloading(0));

        // Download the Quran
        await downloadQuranRepoImpl.downloadQuran(url, filePath, (progress) {
          state = AsyncData(Downloading(progress));
        });

        // Notify that the extraction has started
        state = AsyncData(Extracting(0));

        // Extract the Quran
        await downloadQuranRepoImpl.extractQuran(filePath, 'path/to/quran', (progress) {
          state = AsyncData(Extracting(progress));
        });

        // Delete the old Quran files
        await downloadQuranRepoImpl.deleteOldQuran();

        // Delete the downloaded ZIP file
        await downloadQuranRepoImpl.deleteZipFile(localVersion!);

        // Notify the success state with the new version
        state = AsyncData(Success(localVersion!));
      } else {
        // Notify that the Quran is already up to date
        state = AsyncData(Cancel());
      }
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}
