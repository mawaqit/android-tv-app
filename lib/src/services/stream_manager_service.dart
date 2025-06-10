import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:developer' as dev;

import '../domain/stream/stream_provider_interface.dart';
import '../helpers/live_stream/youtube_stream_helper.dart';
import '../helpers/live_stream/rtsp_stream_helper.dart';
import '../domain/error/live_stream_exceptions.dart';
import '../const/constants.dart';
import '../state_management/livestream_viewer/live_stream_state_v2.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Service for managing different stream providers
class StreamManagerService {
  // List of available stream providers
  final List<StreamProviderInterface> _providers = [
    YouTubeStreamHelper(),
    RTSPStreamHelper(),
  ];

  StreamProviderInterface? _currentProvider;
  LiveStreamType? _currentStreamType;
  Timer? _statusCheckTimer;

  Function(String error)? _onError;
  Function()? _onCompleted;

  /// Initialize stream with given URL
  Future<StreamResult> initializeStream(String url) async {
    try {
      dev.log('🎯 [STREAM_MANAGER] Initializing stream with URL: $url');

      // Dispose current stream and wait for cleanup
      await dispose();
      
      // Additional delay to ensure complete disposal
      await Future.delayed(const Duration(milliseconds: 100));

      // Find a provider that can handle this URL
      StreamProviderInterface? provider;
      for (final p in _providers) {
        if (p.canHandle(url)) {
          provider = p;
          break;
        }
      }

      if (provider == null) {
        throw InvalidStreamUrlException('No provider found for URL: $url');
      }

      // Setup listeners for the provider
      provider.setupListeners(
        onError: (error) => _onError?.call(error),
        onCompleted: () => _onCompleted?.call(),
      );

      // Initialize the stream
      final widget = await provider.initializeStream(url);

      // Verify widget was created successfully
      if (widget == null) {
        throw LiveStreamInitializationException('Failed to create stream widget');
      }

      // Determine stream type based on provider
      LiveStreamType streamType;
      if (provider is YouTubeStreamHelper) {
        streamType = LiveStreamType.youtubeLive;
        dev.log('🎥 [STREAM_MANAGER] Detected YouTube URL');
      } else if (provider is RTSPStreamHelper) {
        streamType = LiveStreamType.rtsp;
        dev.log('🎬 [STREAM_MANAGER] Detected RTSP URL');
      } else {
        streamType = LiveStreamType.youtubeLive; // Default fallback
      }

      _currentProvider = provider;
      _currentStreamType = streamType;
      _startStatusMonitoring();

      dev.log('✅ [STREAM_MANAGER] Stream initialized successfully');

      return StreamResult(
        widget: widget,
        streamType: streamType,
        isSuccess: true,
      );
    } catch (e) {
      dev.log('🚨 [STREAM_MANAGER] Error initializing stream: $e');
      return StreamResult(
        widget: null,
        streamType: null,
        isSuccess: false,
        error: e.toString(),
      );
    }
  }

  /// Check if stream is currently active
  Future<bool> isStreamActive() async {
    if (_currentProvider == null) return false;
    
    try {
      return await _currentProvider!.isActive();
    } catch (e) {
      dev.log('⚠️ [STREAM_MANAGER] Error checking stream status: $e');
      return false;
    }
  }

  /// Pause current stream
  Future<void> pauseStream() async {
    if (_currentProvider == null) return;
    
    try {
      await _currentProvider!.pause();
      dev.log('⏸️ [STREAM_MANAGER] Stream paused');
    } catch (e) {
      dev.log('⚠️ [STREAM_MANAGER] Error pausing stream: $e');
    }
  }

  /// Resume current stream
  Future<void> resumeStream() async {
    if (_currentProvider == null) return;
    
    try {
      await _currentProvider!.play();
      dev.log('▶️ [STREAM_MANAGER] Stream resumed');
    } catch (e) {
      dev.log('⚠️ [STREAM_MANAGER] Error resuming stream: $e');
    }
  }

  /// Setup event listeners
  void setupListeners({
    required Function(String error) onError,
    required Function() onCompleted,
  }) {
    _onError = onError;
    _onCompleted = onCompleted;
  }

  /// Dispose all resources
  Future<void> dispose() async {
    dev.log('🧹 [STREAM_MANAGER] Disposing stream manager');
    _stopStatusMonitoring();
    
    if (_currentProvider != null) {
      await _currentProvider!.dispose();
      _currentProvider = null;
    }
    
    _currentStreamType = null;
    dev.log('🧹 [STREAM_MANAGER] Stream helpers disposed');
  }

  /// Start status monitoring timer
  void _startStatusMonitoring() {
    _stopStatusMonitoring();
    _statusCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) async {
        final isActive = await isStreamActive();
        if (!isActive) {
          dev.log('⚠️ [STREAM_MANAGER] Stream no longer active');
          _onError?.call('Stream connection lost');
        }
      },
    );
    dev.log('⏱️ [STREAM_MANAGER] Status monitoring started');
  }

  /// Stop status monitoring timer
  void _stopStatusMonitoring() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
    dev.log('⏱️ [STREAM_MANAGER] Status monitoring stopped');
  }

  /// Get current stream type
  LiveStreamType? get currentStreamType => _currentStreamType;

  /// Get current provider
  StreamProviderInterface? get currentProvider => _currentProvider;
}

/// Result of stream initialization
class StreamResult {
  final Widget? widget;
  final LiveStreamType? streamType;
  final bool isSuccess;
  final String? error;

  const StreamResult({
    this.widget,
    this.streamType,
    required this.isSuccess,
    this.error,
  });
} 