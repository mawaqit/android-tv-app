import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:mawaqit/src/domain/repository/audio_repository.dart';

class AudioPlayerSingleton {
  // Private constructor
  AudioPlayerSingleton._();

  // Single instance of AudioPlayer
  static AudioPlayer? _instance;

  // Getter for the singleton instance with lazy initialization
  static AudioPlayer get instance {
    _instance ??= AudioPlayer();
    return _instance!;
  }

  // Method to reset the instance if needed
  static Future<void> reset() async {
    if (_instance != null) {
      await _instance!.dispose();
      _instance = null;
    }
  }
}

class AudioRepositoryImpl implements AudioRepository {
  bool _isSessionConfigured = false;
  final StreamController<bool> _playbackStateController = StreamController<bool>.broadcast();

  AudioRepositoryImpl() {
    // Setup player state listener
    AudioPlayerSingleton.instance.playerStateStream.listen((playerState) {
      _playbackStateController.add(playerState.playing);
    });
  }

  @override
  Future<void> initialize() async {
    if (!_isSessionConfigured) {
      await _configureAudioSession();
      _isSessionConfigured = true;
    }
  }

  @override
  Future<void> playAudio(dynamic surahSource, {bool createPlaylist = false}) async {
    try {
      final player = AudioPlayerSingleton.instance;

      // Setup the audio source first
      await _setupAudioSource(surahSource, createPlaylist);

      // Play immediately after source is set
      player.play().then((_) {
        _playbackStateController.add(true);
      }).catchError((error) {
        print('Error during playback: $error');
        _playbackStateController.add(false);
      });

    } catch (e) {
      print('Error setting up audio: $e');
      _playbackStateController.add(false);
      rethrow;
    }
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
      await session.setActive(true);
      await AudioPlayerSingleton.instance.setVolume(1.0);
    } catch (e) {
      print('Error configuring audio session: $e');
      rethrow;
    }
  }

  Future<void> _setupAudioSource(dynamic surahSource, bool createPlaylist) async {
    final player = AudioPlayerSingleton.instance;

    // Stop current playback if any
    if (player.playing) {
      await player.stop();
    }

    try {
      if (createPlaylist) {
        await _setupPlaylist(surahSource);
      } else {
        await _setupSingleAudio(surahSource);
      }
    } catch (e) {
      print('Error setting up audio source: $e');
      rethrow;
    }
  }


  Future<void> _setupPlaylist(dynamic surahSource) async {
    final playlist = ConcatenatingAudioSource(
      children: (surahSource as List).map((source) {
        if (source is String) {
          return AudioSource.uri(Uri.parse(source));
        } else if (source is AudioSource) {
          return source;
        }
        throw ArgumentError('Invalid source type: ${source.runtimeType}');
      }).toList(),
    );
    await AudioPlayerSingleton.instance.setAudioSource(playlist);
    await AudioPlayerSingleton.instance.setLoopMode(LoopMode.all);
  }

  Future<void> _setupSingleAudio(dynamic surahSource) async {
    final source = surahSource is String
        ? AudioSource.uri(Uri.parse(surahSource))
        : surahSource as AudioSource;
    await AudioPlayerSingleton.instance.setAudioSource(source);
    await AudioPlayerSingleton.instance.setLoopMode(LoopMode.one);
  }

  @override
  Future<void> stopPlayback() async {
    try {
      await AudioPlayerSingleton.instance.stop();
    } catch (e) {
      print('Error stopping playback: $e');
      rethrow;
    }
  }

  @override
  Future<void> pausePlayback() async {
    try {
      await AudioPlayerSingleton.instance.pause();
    } catch (e) {
      print('Error pausing playback: $e');
      rethrow;
    }
  }

  @override
  Future<void> resumePlayback() async {
    try {
      await AudioPlayerSingleton.instance.play();
    } catch (e) {
      print('Error resuming playback: $e');
      rethrow;
    }
  }

  @override
  bool isPlaying() => AudioPlayerSingleton.instance.playing;

  @override
  AudioPlayer get player => AudioPlayerSingleton.instance;

  // Clean up resources
  Future<void> dispose() async {
    _playbackStateController.close();
    await AudioPlayerSingleton.reset();
    _isSessionConfigured = false;
  }

  Stream<bool> get playbackStateStream => _playbackStateController.stream;
}

final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  return AudioRepositoryImpl();
});
