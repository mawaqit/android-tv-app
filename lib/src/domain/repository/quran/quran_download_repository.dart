abstract class QuranDownloadRepository {
  Future<String?> getLocalQuranVersion();

  Future<String> getRemoteQuranVersion();

  Future<void> downloadQuran({
    required String version,
    String? filePath,
    required dynamic Function(double) onReceiveProgress,
  });

  Future<void> extractQuran({
    required String zipFilePath,
    required String destinationPath,
    required Function(double) onExtractProgress,
  });

  Future<void> deleteOldQuran({
    String? path,
  });

  Future<void> deleteZipFile(String zipFileName);

  void cancelDownload();
}
