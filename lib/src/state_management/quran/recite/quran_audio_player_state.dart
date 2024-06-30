import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';

enum AudioPlayerState { playing, paused, stopped, seekNext, seekPrevious }

class QuranAudioPlayerState extends Equatable {
  final AudioPlayer audioPlayer;
  final Duration position;
  final String surahName;
  final AudioPlayerState playerState;
  final String reciterName;
  final bool isShuffled;
  final bool isRepeating;

  QuranAudioPlayerState({
    required this.audioPlayer,
    required this.position,
    required this.surahName,
    required this.playerState,
    required this.reciterName,
    this.isShuffled = false,
    this.isRepeating = false,
  });

  QuranAudioPlayerState copyWith({
    AudioPlayer? audioPlayer,
    Duration? position,
    String? surahName,
    AudioPlayerState? playerState,
    String? reciterName,
    bool? isShuffled,
    bool? isRepeating,
  }) {
    return QuranAudioPlayerState(
      audioPlayer: audioPlayer ?? this.audioPlayer,
      position: position ?? this.position,
      surahName: surahName ?? this.surahName,
      playerState: playerState ?? this.playerState,
      reciterName: reciterName ?? this.reciterName,
      isShuffled: isShuffled ?? this.isShuffled,
      isRepeating: isRepeating ?? this.isRepeating,
    );
  }

  @override
  String toString() {
    return 'QuranAudioPlayerState(audioPlayer: $audioPlayer, position: $position, surahName: $surahName, '
        'playerState: $playerState, reciterName: $reciterName, isShuffled: $isShuffled, isRepeating: $isRepeating)';
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
  ];
}
