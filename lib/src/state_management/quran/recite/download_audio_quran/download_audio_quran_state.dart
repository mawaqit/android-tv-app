enum DownloadStatus { idle, downloading, completed, noNewDownloads }

class DownloadAudioQuranState {
  final Map<String, Map<int, double>> downloadProgress;
  final Map<String, Set<int>> downloadedSuwar;
  final Map<String, int?> currentDownloadingSurah;
  final DownloadStatus downloadStatus;

  DownloadAudioQuranState({
    this.downloadProgress = const {},
    this.downloadedSuwar = const {},
    this.currentDownloadingSurah = const {},
    this.downloadStatus = DownloadStatus.idle,
  });

  DownloadAudioQuranState copyWith({
    Map<String, Map<int, double>>? downloadProgress,
    Map<String, Set<int>>? downloadedSuwar,
    Map<String, int?>? currentDownloadingSurah,
    DownloadStatus? downloadStatus,
  }) {
    return DownloadAudioQuranState(
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadedSuwar: downloadedSuwar ?? this.downloadedSuwar,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      currentDownloadingSurah:
          currentDownloadingSurah ?? this.currentDownloadingSurah,
    );
  }
}
