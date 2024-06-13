import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

enum AudioPlayerState { playing, paused, stopped, seekNext, seekPrevious }

enum DownloadState { downloading, downloaded, notDownloaded }

@immutable
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

  QuranAudioPlayerState({
    required this.audioPlayer,
    required this.position,
    required this.surahName,
    required this.playerState,
    required this.reciterName,
    this.downloadProgress = -1,
    this.isShuffled = false,
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
    DownloadState? downloadState,
  }) {
    return QuranAudioPlayerState(
      reciterName: reciterName ?? this.reciterName,
      audioPlayer: audioPlayer ?? this.audioPlayer,
      position: position ?? this.position,
      isShuffled: isShuffled ?? this.isShuffled,
      surahName: surahName ?? this.surahName,
      playerState: playerState ?? this.playerState,
      isRepeating: isRepeating ?? this.isRepeating,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadState: downloadState ?? this.downloadState,
    );
  }

  @override
  String toString() {
    return 'QuranAudioPlayerState(audioPlayer: $audioPlayer, position: $position, surahName: $surahName, '
        'playerState: $playerState, reciterName: $reciterName, isShuffled: $isShuffled, isRepeating: $isRepeating, '
        'downloadProgress: $downloadProgress, downloadState: $downloadState)';
  }

  @override
  List<Object?> get props => [
        audioPlayer,
        position,
        surahName,
        reciterName,
        playerState,
        isShuffled,
        isRepeating,
        downloadProgress,
        DownloadState
      ];
}
