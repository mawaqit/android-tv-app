import 'package:just_audio/just_audio.dart';

abstract class AudioRepository {
  Future<void> initialize();
  Future<void> playAudio(dynamic surahSource, {bool createPlaylist = false});
  Future<void> stopPlayback();
  Future<void> pausePlayback();
  Future<void> resumePlayback();
  bool isPlaying();
  AudioPlayer? get player;
}
