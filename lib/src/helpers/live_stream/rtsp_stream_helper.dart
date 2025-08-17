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

  /// Get the current active player
  Player? get player => _player;

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
    _playbackCheckTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!_isPlaying && !_isCompleted) {
        dev.log('❌ [RTSP_HELPER] Stream not playing, calling error handler');
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
    if (_player == null) return false;
    
    try {
      // Basic checks first
      if (_isCompleted) {
        dev.log('🎬 [RTSP_HELPER] Stream marked as completed');
        return false;
      }
      
      // For live streams, we must be actively playing
      if (!_isPlaying) {
        dev.log('❌ [RTSP_HELPER] Stream not playing');
        return false;
      }
      
      // Check if player is buffering for too long
      final buffering = _player!.state.buffering;
      if (buffering) {
        dev.log('⚠️ [RTSP_HELPER] Stream is buffering');
        return false;
      }
      
      dev.log('✅ [RTSP_HELPER] Stream health check passed');
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
