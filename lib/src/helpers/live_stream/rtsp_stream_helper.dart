import 'dart:async';
import 'dart:developer' as dev;

import 'package:mawaqit/src/domain/error/live_stream_exceptions.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Helper class to handle RTSP stream operations
class RTSPStreamHelper {
  Player? _player;
  VideoController? _videoController;

  /// Get the current active video controller
  VideoController? get videoController => _videoController;

  /// Get the current active player
  Player? get player => _player;

  /// Clean up resources
  Future<void> dispose() async {
    if (_player != null) {
      try {
        await _player!.pause();
        await _player!.dispose();
        dev.log('🎬 [RTSP_HELPER] Disposed media player');
      } catch (e) {
        dev.log('⚠️ [RTSP_HELPER] Error disposing media player: $e');
      }
      _player = null;
    }

    if (_videoController != null) {
      try {
        // The player disposal should already handle this, but let's be safe
        await _videoController!.player.dispose();
        dev.log('🎬 [RTSP_HELPER] Disposed video controller');
      } catch (e) {
        dev.log('⚠️ [RTSP_HELPER] Error disposing video controller: $e');
      }
      _videoController = null;
    }
  }

  /// Initialize RTSP player with the given URL
  Future<VideoController> initializePlayer(String url) async {
    // Dispose existing player if any
    await dispose();

    try {
      // Create new player and controller
      _player = Player();
      _videoController = VideoController(_player!);

      // Open media with the RTSP URL
      await _player!.open(Media(url));
      dev.log('✅ [RTSP_HELPER] Created and opened RTSP player for URL: $url');

      return _videoController!;
    } catch (e) {
      dev.log('🚨 [RTSP_HELPER] Error initializing RTSP player: $e');
      await dispose();
      throw LiveStreamInitializationException('Failed to initialize RTSP player: $e');
    }
  }

  /// Setup error and completion listeners
  void setupListeners({
    required Function(String) onError,
    required Function() onCompleted,
  }) {
    if (_player == null) {
      dev.log('⚠️ [RTSP_HELPER] Cannot setup listeners, player is null');
      return;
    }

    // Listen for errors
    _player!.stream.error.listen((error) {
      if (error.isNotEmpty) {
        dev.log('⚠️ [RTSP_HELPER] RTSP stream error: $error');
        onError(error);
      }
    });

    // Listen for completion
    _player!.stream.completed.listen((completed) {
      if (completed) {
        dev.log('🏁 [RTSP_HELPER] RTSP stream completed');
        onCompleted();
      }
    });
  }

  /// Check if the stream is still active
  /// Returns true if active, false otherwise
  Future<bool> checkStreamActive() async {
    if (_player == null || _videoController == null) {
      return false;
    }

    try {
      // Check if there are any errors
      final hasError = await _player!.stream.error.first.timeout(
        const Duration(seconds: 2),
        onTimeout: () => '',
      );

      if (hasError.isNotEmpty) {
        dev.log('⚠️ [RTSP_HELPER] RTSP stream error detected during check: $hasError');
        return false;
      }

      // Check if player is playing
      final isPlaying = _player!.state.playing;
      if (!isPlaying) {
        // Check if stream is just paused or truly ended
        final isEnded = await _player!.stream.completed.first.timeout(
          const Duration(seconds: 2),
          onTimeout: () => false,
        );

        if (isEnded) {
          dev.log('🏁 [RTSP_HELPER] RTSP stream ended during check');
          return false;
        }
      }

      return true;
    } catch (e) {
      dev.log('⚠️ [RTSP_HELPER] Error checking RTSP stream status: $e');
      return false;
    }
  }

  /// Play the stream
  Future<void> play() async {
    if (_player != null) {
      try {
        await _player!.play();
        dev.log('▶️ [RTSP_HELPER] Playing RTSP stream');
      } catch (e) {
        dev.log('⚠️ [RTSP_HELPER] Error playing RTSP stream: $e');
      }
    }
  }

  /// Pause the stream
  Future<void> pause() async {
    if (_player != null) {
      try {
        await _player!.pause();
        dev.log('⏸️ [RTSP_HELPER] Paused RTSP stream');
      } catch (e) {
        dev.log('⚠️ [RTSP_HELPER] Error pausing RTSP stream: $e');
      }
    }
  }

  /// Validate RTSP URL format
  bool isValidRtspUrl(String url) {
    return url.trim().startsWith('rtsp://');
  }
}
