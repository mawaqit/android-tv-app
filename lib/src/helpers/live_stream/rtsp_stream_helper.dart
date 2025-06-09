import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/widgets.dart';
import 'package:mawaqit/src/domain/error/live_stream_exceptions.dart';
import 'package:mawaqit/src/domain/stream/stream_provider_interface.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Helper class to handle RTSP stream operations
class RTSPStreamHelper implements StreamProviderInterface {
  Player? _player;
  VideoController? _videoController;
  Timer? _playbackCheckTimer;

  bool _isPlaying = false;
  bool _isCompleted = false;

  Function(String)? _onError;
  Function()? _onCompleted;

  /// Get the current active video controller
  VideoController? get videoController => _videoController;

  /// Get the current active player
  Player? get player => _player;

  @override
  bool canHandle(String url) {
    return url.trim().startsWith('rtsp://');
  }

  @override
  Future<Widget> initializeStream(String url) async {
    final controller = await initializePlayer(url);
    return Video(controller: controller);
  }

  @override
  Future<bool> isActive() async {
    return await checkStreamActive();
  }

  @override
  Future<void> pause() async {
    dev.log('⏸️ [RTSP_HELPER] Pausing stream');
    await _player?.pause();
  }

  @override
  Future<void> play() async {
    dev.log('▶️ [RTSP_HELPER] Playing stream');
    await _player?.play();
  }

  @override
  Future<void> dispose() async {
    dev.log('🧹 [RTSP_HELPER] Disposing resources');
    _playbackCheckTimer?.cancel();
    _playbackCheckTimer = null;
    await _player?.dispose();
    _player = null;
    _videoController = null;
    _isPlaying = false;
    _isCompleted = false;
  }

  @override
  void setupListeners({
    required Function(String) onError,
    required Function() onCompleted,
  }) {
    _onError = onError;
    _onCompleted = onCompleted;
  }

  /// Initialize the RTSP player with the given URL
  Future<VideoController> initializePlayer(String url) async {
    dev.log('🎬 [RTSP_HELPER] Initializing player with URL: $url');

    await dispose();

    _player = Player();
    _videoController = VideoController(_player!);

    // Setup stream listeners
    _player!.stream.playing.listen((playing) {
      _isPlaying = playing;
      dev.log('🎬 [RTSP_HELPER] Playing status changed: $playing');
    });

    _player!.stream.completed.listen((completed) {
      _isCompleted = completed;
      if (completed) {
        dev.log('🎬 [RTSP_HELPER] Stream completed');
        _onCompleted?.call();
      }
    });

    // Start periodic playback check
    _playbackCheckTimer?.cancel();
    _playbackCheckTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (!_isPlaying && !_isCompleted) {
        dev.log('🎬 [RTSP_HELPER] Stream not playing, attempting reconnection');
        _onError?.call('Stream playback stopped');
      }
    });

    try {
      await _player!.open(Media(url));
      dev.log('🎬 [RTSP_HELPER] Successfully opened stream');
      return _videoController!;
    } catch (e) {
      dev.log('🚨 [RTSP_HELPER] Error initializing player: $e');
      _onError?.call('Failed to initialize stream: $e');
      rethrow;
    }
  }

  /// Check if the stream is currently active
  Future<bool> checkStreamActive() async {
    if (_player == null) return false;
    return _isPlaying || (!_isCompleted);
  }

  /// Validate RTSP URL format
  bool isValidRtspUrl(String url) {
    return url.trim().startsWith('rtsp://');
  }
}
