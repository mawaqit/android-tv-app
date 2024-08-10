import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

enum AudioPlayerState { playing, paused, stopped, seekNext, seekPrevious }

@immutable
class QuranAudioPlayerState extends Equatable {
  final AudioPlayer audioPlayer;
  final double volume;
  final Duration position;
  final String surahName;
  final AudioPlayerState playerState;
  final String reciterName;
  final bool isShuffled;
  final bool isVolumeOpened;
  final bool isRepeating;

  QuranAudioPlayerState({
    required this.audioPlayer,
    required this.position,
    required this.surahName,
    required this.playerState,
    required this.reciterName,
    this.isShuffled = false,
    this.isVolumeOpened = false,
    this.isRepeating = false,
    this.volume = 1.0,
  });

  QuranAudioPlayerState copyWith({
    AudioPlayer? audioPlayer,
    Duration? position,
    String? surahName,
    AudioPlayerState? playerState,
    String? reciterName,
    bool? isVolumeOpened,
    bool? isShuffled,
    bool? isRepeating,
    double? volume,
  }) {
    return QuranAudioPlayerState(
      reciterName: reciterName ?? this.reciterName,
      audioPlayer: audioPlayer ?? this.audioPlayer,
      position: position ?? this.position,
      isVolumeOpened: isVolumeOpened ?? this.isVolumeOpened,
      isShuffled: isShuffled ?? this.isShuffled,
      surahName: surahName ?? this.surahName,
      playerState: playerState ?? this.playerState,
      volume: volume ?? this.volume,
      isRepeating: isRepeating ?? this.isRepeating,
    );
  }

  @override
  String toString() {
    return 'QuranAudioPlayerState(audioPlayer: $audioPlayer, position: $position, surahName: $surahName, '
        'playerState: $playerState, reciterName: $reciterName, isShuffled: $isShuffled, isRepeating: $isRepeating'
        ', volume: $volume, isVolume: #isVolumeOpened: $isVolumeOpened'
        ')';
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
        isVolumeOpened,
        volume,
      ];
}
