import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';

abstract class QuranDownloadRepository {
  Future<String?> getLocalQuranVersion({
    required MoshafType moshafType,
  });

  Future<String> getRemoteQuranVersion({
    required MoshafType moshafType,
  });

  Future<void> downloadQuran({
    required String version,
    required MoshafType moshafType,
    String? filePath,
    required dynamic Function(double) onReceiveProgress,
    required dynamic Function(double) onExtractProgress,
  });

  void cancelDownload();
}
