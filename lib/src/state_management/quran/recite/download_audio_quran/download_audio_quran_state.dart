class DownloadAudioQuranState {
  final Map<String, Map<int, double>> downloadProgress;
  final Map<String, Set<int>> downloadedSuwar;
  final Map<String, int?> currentDownloadingSurah;

  DownloadAudioQuranState({
    this.downloadProgress = const {},
    this.downloadedSuwar = const {},
    this.currentDownloadingSurah = const {},
  });

  DownloadAudioQuranState copyWith({
    Map<String, Map<int, double>>? downloadProgress,
    Map<String, Set<int>>? downloadedSuwar,
    Map<String, int?>? currentDownloadingSurah,
  }) {
    return DownloadAudioQuranState(
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadedSuwar: downloadedSuwar ?? this.downloadedSuwar,
      currentDownloadingSurah: currentDownloadingSurah ?? this.currentDownloadingSurah,
    );
  }
}
