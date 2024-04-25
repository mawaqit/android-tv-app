abstract class QuranDownloadRepository {
  Future<String?> getLocalQuranVersion();
  Future<String?> getRemoteQuranVersion();
  Future<void> downloadQuran(String version, String? filePath, Function(double) onReceiveProgress);
  Future<void> extractQuran(String zipFilePath, String destinationPath, Function(double) onExtractProgress);
  Future<void> deleteOldQuran();
  Future<void> deleteZipFile(String zipFileName);
}
