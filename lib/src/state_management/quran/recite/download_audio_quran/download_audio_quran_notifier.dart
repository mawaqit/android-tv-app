import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mawaqit/src/state_management/quran/recite/download_audio_quran/download_audio_quran_state.dart';

class DownloadStateNotifier extends Notifier<DownloadAudioQuranState> {
  @override
  DownloadAudioQuranState build() {
    return DownloadAudioQuranState();
  }

  String _getKey(String reciterId, String riwayahId) {
    return "$reciterId:$riwayahId";
  }

  Future<void> updateDownloadProgress(
      String reciterId, String riwayahId, int surahId, double progress) async {
    final key = _getKey(reciterId, riwayahId);
    final currentProgress = state.downloadProgress[key] ?? {};
    state = state.copyWith(
      downloadProgress: {
        ...state.downloadProgress,
        key: {...currentProgress, surahId: progress},
      },
      currentDownloadingSurah: {
        ...state.currentDownloadingSurah,
        key: surahId,
      },
    );
  }

  Future<void> markAsDownloaded(
      String reciterId, String riwayahId, int surahId) async {
    final key = _getKey(reciterId, riwayahId);
    final currentDownloaded = state.downloadedSuwar[key] ?? {};
    final currentProgress = state.downloadProgress[key] ?? {};
    state = state.copyWith(
      downloadedSuwar: {
        ...state.downloadedSuwar,
        key: {...currentDownloaded, surahId},
      },
      downloadProgress: {
        ...state.downloadProgress,
        key: {...currentProgress}..remove(surahId),
      },
      currentDownloadingSurah: {
        ...state.currentDownloadingSurah,
        key: state.currentDownloadingSurah[key] == surahId
            ? null
            : state.currentDownloadingSurah[key],
      },
    );
  }

  Future<void> initializeDownloadedSuwar(
      String reciterId, String riwayahId, Set<int> downloadedSuwar) async {
    final key = _getKey(reciterId, riwayahId);
    state = state.copyWith(
      downloadedSuwar: {
        ...state.downloadedSuwar,
        key: downloadedSuwar,
      },
    );
  }

  void setDownloadStatus(DownloadStatus status) {
    state = state.copyWith(downloadStatus: status);
  }

  void resetDownloadStatus() {
    state = state.copyWith(downloadStatus: DownloadStatus.idle);
  }
}

final downloadStateProvider =
    NotifierProvider<DownloadStateNotifier, DownloadAudioQuranState>(
  DownloadStateNotifier.new,
);
