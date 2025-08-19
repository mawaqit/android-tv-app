import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Helper class to handle RTSP stream operations
class RTSPStreamHelper {
  Player? _player;
  VideoController? _videoController;
  Timer? _playbackCheckTimer;

  bool _isPlaying = false;
  bool _isCompleted = false;

  Function(String)? _onError;
  Function()? _onCompleted;

  /// Get the current active video controller
  VideoController? get videoController => _videoController;
  int? _bufferingStartTime;
  static const int _maxBufferingTimeMs = 30000; // 30 seconds max buffering
  /// Get the current active player
  Player? get player => _player;

  /// Initialize the RTSP player with the given URL
  Future<VideoController> initializePlayer(String url) async {
    dev.log('🎬 [RTSP_HELPER] Initializing player with URL: $url');

    await dispose();

    // Reset buffering tracking
    _bufferingStartTime = null;

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

    // Monitor buffering state changes
    _player!.stream.buffering.listen((buffering) {
      if (buffering && _bufferingStartTime == null) {
        _bufferingStartTime = DateTime.now().millisecondsSinceEpoch;
        dev.log('⏳ [RTSP_HELPER] Stream started buffering');
      } else if (!buffering && _bufferingStartTime != null) {
        dev.log('✅ [RTSP_HELPER] Stream stopped buffering');
        _bufferingStartTime = null;
      }
    });

    // Remove the periodic playback check timer - we'll rely on the main status checker
    _playbackCheckTimer?.cancel();
    _playbackCheckTimer = null;

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

  /// Setup error and completion listeners
  void setupListeners({
    required Function(String) onError,
    required Function() onCompleted,
  }) {
    _onError = onError;
    _onCompleted = onCompleted;
  }

  /// Check if the stream is currently active and healthy
  Future<bool> checkStreamActive() async {
    if (_player == null) {
      dev.log('❌ [RTSP_HELPER] No player instance');
      return false;
    }

    try {
      // Basic checks first
      if (_isCompleted) {
        dev.log('🎬 [RTSP_HELPER] Stream marked as completed');
        return false;
      }

      // Check player state
      final buffering = _player!.state.buffering;
      final position = _player!.state.position;

      // Handle buffering state with timeout
      if (buffering) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;

        if (_bufferingStartTime == null) {
          _bufferingStartTime = currentTime;
          dev.log('⏳ [RTSP_HELPER] Stream started buffering');
          return true; // Allow some buffering time
        } else {
          final bufferingDuration = currentTime - _bufferingStartTime!;
          if (bufferingDuration > _maxBufferingTimeMs) {
            dev.log('❌ [RTSP_HELPER] Stream buffering too long (${bufferingDuration}ms), considering inactive');
            _bufferingStartTime = null;
            return false;
          } else {
            dev.log('⏳ [RTSP_HELPER] Stream buffering for ${bufferingDuration}ms, still within limits');
            return true;
          }
        }
      } else {
        // Not buffering, reset the buffering timer
        if (_bufferingStartTime != null) {
          dev.log('✅ [RTSP_HELPER] Stream stopped buffering');
          _bufferingStartTime = null;
        }
      }

      // For live streams, we should be actively playing
      if (!_isPlaying) {
        dev.log('❌ [RTSP_HELPER] Stream not playing');
        return false;
      }

      // Additional check: For RTSP live streams, position should be reasonable
      // Live streams typically have very large position values or duration might be unknown
      dev.log('✅ [RTSP_HELPER] Stream is healthy - Playing: $_isPlaying, Position: $position, Buffering: $buffering');
      return true;
    } catch (e) {
      dev.log('🚨 [RTSP_HELPER] Error during stream health check: $e');
      return false;
    }
  }

  /// Pause the stream
  Future<void> pause() async {
    dev.log('⏸️ [RTSP_HELPER] Pausing stream');
    await _player?.pause();
  }

  /// Resume/play the stream
  Future<void> play() async {
    dev.log('▶️ [RTSP_HELPER] Playing stream');
    await _player?.play();
  }

  /// Dispose of all resources
  Future<void> dispose() async {
    dev.log('🧹 [RTSP_HELPER] Disposing resources');

    try {
      // Cancel timer first
      _playbackCheckTimer?.cancel();
      _playbackCheckTimer = null;

      // Clear buffering tracking
      _bufferingStartTime = null;

      // Clear controller reference before disposing player
      _videoController = null;
      _isPlaying = false;
      _isCompleted = false;

      // Small delay to allow any pending operations to complete
      await Future.delayed(const Duration(milliseconds: 50));

      // Dispose player last
      if (_player != null) {
        await _player!.dispose();
        _player = null;
      }

      dev.log('🧹 [RTSP_HELPER] Resources disposed successfully');
    } catch (e) {
      dev.log('🚨 [RTSP_HELPER] Error during disposal: $e');
      // Force cleanup even if dispose fails
      _playbackCheckTimer = null;
      _videoController = null;
      _player = null;
      _isPlaying = false;
      _isCompleted = false;
      _bufferingStartTime = null;
    }
  }

  /// Validate RTSP URL format
  bool isValidRtspUrl(String url) {
    return url.trim().startsWith('rtsp://');
  }

  /// Check if RTSP server is reachable
  /// Returns true if server responds, false otherwise
  Future<bool> checkRtspServerAvailability(String url) async {
    try {
      dev.log('🔍 [RTSP_HELPER] Checking server availability for: $url');

      if (!isValidRtspUrl(url)) {
        dev.log('❌ [RTSP_HELPER] Invalid RTSP URL format');
        return false;
      }

      // Parse URL to get host and port
      final uri = Uri.parse(url);
      final host = uri.host;
      final port = uri.port != 0 ? uri.port : 554; // Default RTSP port

      dev.log('🔍 [RTSP_HELPER] Testing connection to $host:$port');

      // Try to establish a basic TCP connection to the RTSP server
      Socket? socket;
      try {
        socket = await Socket.connect(
          host,
          port,
          timeout: const Duration(seconds: 5),
        );

        dev.log('✅ [RTSP_HELPER] Server is reachable at $host:$port');
        await socket.close();
        return true;
      } catch (e) {
        dev.log('❌ [RTSP_HELPER] Server unreachable at $host:$port - $e');
        return false;
      } finally {
        socket?.destroy();
      }
    } catch (e) {
      dev.log('🚨 [RTSP_HELPER] Error checking server availability: $e');
      return false;
    }
  }
}
