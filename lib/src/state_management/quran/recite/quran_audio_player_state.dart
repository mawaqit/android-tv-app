import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';

enum AudioPlayerState { playing, paused, stopped, seekNext, seekPrevious }

enum DownloadState { downloading, downloaded, notDownloaded }

class QuranAudioPlayerState extends Equatable {
  final AudioPlayer audioPlayer;
  final Duration position;
  final String surahName;
  final AudioPlayerState playerState;
  final String reciterName;
  final bool isShuffled;
  final bool isRepeating;
  final int downloadProgress;
  final DownloadState downloadState;
  final int downloadedIndex;
  final List<File> downloadedAudio;
  final int currentDownloadAudio;

  QuranAudioPlayerState({
    required this.audioPlayer,
    required this.position,
    required this.surahName,
    required this.playerState,
    required this.reciterName,
    required this.currentDownloadAudio,
    this.downloadedAudio = const <File>[],
    this.downloadProgress = -1,
    this.isShuffled = false,
    this.downloadedIndex = 0,
    this.isRepeating = false,
    this.downloadState = DownloadState.notDownloaded,
  });

  QuranAudioPlayerState copyWith({
    AudioPlayer? audioPlayer,
    Duration? position,
    String? surahName,
    AudioPlayerState? playerState,
    String? reciterName,
    bool? isShuffled,
    bool? isRepeating,
    int? downloadProgress,
    int? downloadedIndex,
    DownloadState? downloadState,
    int? currentDownloadAudio,
    List<File>? downloadedAudio,
  }) {
    return QuranAudioPlayerState(
      reciterName: reciterName ?? this.reciterName,
      audioPlayer: audioPlayer ?? this.audioPlayer,
      position: position ?? this.position,
      downloadedIndex: downloadedIndex ?? this.downloadedIndex,
      isShuffled: isShuffled ?? this.isShuffled,
      surahName: surahName ?? this.surahName,
      playerState: playerState ?? this.playerState,
      isRepeating: isRepeating ?? this.isRepeating,
      currentDownloadAudio: currentDownloadAudio ?? this.currentDownloadAudio,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadState: downloadState ?? this.downloadState,
      downloadedAudio: downloadedAudio ?? this.downloadedAudio,
    );
  }

  @override
  String toString() {
    return 'QuranAudioPlayerState(audioPlayer: $audioPlayer, position: $position, surahName: $surahName, '
        'playerState: $playerState, reciterName: $reciterName, isShuffled: $isShuffled, isRepeating: $isRepeating, '
        'downloadProgress: $downloadProgress, downloadState: $downloadState, '
        'currentDownloadAudio: $currentDownloadAudio)';
  }

  @override
  List<Object?> get props => [
        audioPlayer,
        position,
        surahName,
        reciterName,
        playerState,
        isShuffled,
        downloadedIndex,
        isRepeating,
        downloadProgress,
        DownloadState,
        downloadedAudio,
        currentDownloadAudio
      ];
}
