import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/state_management/quran/recite/download_audio_quran/download_audio_quran_state.dart';

class DownloadStateNotifier extends FamilyNotifier<DownloadAudioQuranState, DownloadStateProviderParameter> {
  @override
  DownloadAudioQuranState build(DownloadStateProviderParameter arg) {
    return DownloadAudioQuranState(
      reciterId: arg.reciterId,
      moshafId: arg.moshafId,
    );
  }

  void setCurrentReciterMoshaf(String reciterId, String moshafId) {
    state = state.copyWith(
      reciterId: reciterId,
      moshafId: moshafId,
    );
  }

  Future<void> updateDownloadProgress(int surahId, double progress) async {
    final updatedDownloadingSuwar = List<SurahDownloadInfo>.from(state.downloadingSuwar);
    final index = updatedDownloadingSuwar.indexWhere((info) => info.surahId == surahId);
    if (index != -1) {
      updatedDownloadingSuwar[index] = SurahDownloadInfo(surahId: surahId, progress: progress);
    } else {
      updatedDownloadingSuwar.add(SurahDownloadInfo(surahId: surahId, progress: progress));
    }

    state = state.copyWith(
      downloadingSuwar: updatedDownloadingSuwar,
      currentDownloadingSurah: surahId,
    );
  }

  Future<void> markAsDownloaded(int surahId) async {
    final updatedDownloadedSuwar = Set<int>.from(state.downloadedSuwar)..add(surahId);
    final updatedDownloadingSuwar = state.downloadingSuwar.where((info) => info.surahId != surahId).toList();

    state = state.copyWith(
      downloadedSuwar: updatedDownloadedSuwar,
      downloadingSuwar: updatedDownloadingSuwar,
      currentDownloadingSurah: state.currentDownloadingSurah == surahId ? null : state.currentDownloadingSurah,
    );
  }

  Future<void> initializeDownloadedSuwar(Set<int> downloadedSuwar) async {
    state = state.copyWith(downloadedSuwar: downloadedSuwar);
  }

  void setDownloadStatus(DownloadStatus status) {
    state = state.copyWith(downloadStatus: status);
  }

  void resetDownloadStatus() {
    state = state.copyWith(downloadStatus: DownloadStatus.idle);
  }
}

class DownloadStateProviderParameter {
  final String reciterId;
  final String moshafId;

  DownloadStateProviderParameter({
    required this.reciterId,
    required this.moshafId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadStateProviderParameter &&
          runtimeType == other.runtimeType &&
          reciterId == other.reciterId &&
          moshafId == other.moshafId;

  @override
  int get hashCode => reciterId.hashCode ^ moshafId.hashCode;
}

final downloadStateProvider =
    NotifierProviderFamily<DownloadStateNotifier, DownloadAudioQuranState, DownloadStateProviderParameter>(
  DownloadStateNotifier.new,
);
