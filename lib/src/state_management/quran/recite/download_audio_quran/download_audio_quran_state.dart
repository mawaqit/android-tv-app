enum DownloadStatus { idle, downloading, completed, noNewDownloads }

class SurahDownloadInfo {
  final int surahId;
  final double progress;

  SurahDownloadInfo({required this.surahId, required this.progress});

  @override
  String toString() => 'SurahDownloadInfo(surahId: $surahId, progress: $progress)';
}

class DownloadAudioQuranState {
  final String reciterId;
  final String moshafId;
  final List<SurahDownloadInfo> downloadingSuwar;
  final Set<int> downloadedSuwar;
  final int? currentDownloadingSurah;
  final DownloadStatus downloadStatus;

  DownloadAudioQuranState({
    this.reciterId = '',
    this.moshafId = '',
    this.downloadingSuwar = const [],
    this.downloadedSuwar = const {},
    this.currentDownloadingSurah,
    this.downloadStatus = DownloadStatus.idle,
  });

  DownloadAudioQuranState copyWith({
    String? reciterId,
    String? moshafId,
    List<SurahDownloadInfo>? downloadingSuwar,
    Set<int>? downloadedSuwar,
    int? currentDownloadingSurah,
    DownloadStatus? downloadStatus,
  }) {
    return DownloadAudioQuranState(
      reciterId: reciterId ?? this.reciterId,
      moshafId: moshafId ?? this.moshafId,
      downloadingSuwar: downloadingSuwar ?? this.downloadingSuwar,
      downloadedSuwar: downloadedSuwar ?? this.downloadedSuwar,
      currentDownloadingSurah: currentDownloadingSurah ?? this.currentDownloadingSurah,
      downloadStatus: downloadStatus ?? this.downloadStatus,
    );
  }

  @override
  String toString() => 'DownloadAudioQuranState(reciterId: $reciterId, '
      'moshafId: $moshafId, '
      'downloadingSuwar: $downloadingSuwar, downloadedSuwar: $downloadedSuwar, '
      'currentDownloadingSurah: $currentDownloadingSurah, downloadStatus: $downloadStatus)';
}
