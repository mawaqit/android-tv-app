import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:developer' as dev;

import '../helpers/live_stream/youtube_stream_helper.dart';
import '../helpers/live_stream/rtsp_stream_helper.dart';
import '../domain/error/live_stream_exceptions.dart';
import '../const/constants.dart';
import '../state_management/livestream_viewer/live_stream_state_v2.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Service for managing different stream providers
class StreamManagerService {
  final YouTubeStreamHelper _youtubeHelper = YouTubeStreamHelper();
  final RTSPStreamHelper _rtspHelper = RTSPStreamHelper();

  LiveStreamType? _currentStreamType;
  Timer? _statusCheckTimer;

  Function(String error)? _onError;
  Function()? _onCompleted;

  /// Initialize stream with given URL
  Future<StreamResult> initializeStream(String url) async {
    try {
      dev.log('🎯 [STREAM_MANAGER] Initializing stream with URL: $url');

      // Dispose current stream
      await dispose();

      Widget streamWidget;
      LiveStreamType streamType;

      // Determine stream type and initialize accordingly
      if (LiveStreamConstants.youtubeUrlRegex.hasMatch(url)) {
        dev.log('🎥 [STREAM_MANAGER] Detected YouTube URL');
        
        // Setup listeners
        _youtubeHelper.controller?.addListener(() {
          final playerState = _youtubeHelper.controller!.value.playerState;
          if (playerState == PlayerState.ended) {
            _onCompleted?.call();
          } else if (playerState == PlayerState.unknown) {
            _onError?.call('YouTube player in unknown state');
          }
        });
        
        final videoId = await _youtubeHelper.processYouTubeUrl(url);
        final controller = _youtubeHelper.initializeController(videoId);
        
        streamWidget = YoutubePlayer(
          controller: controller,
          onEnded: (_) => _onCompleted?.call(),
        );
        streamType = LiveStreamType.youtubeLive;
        
      } else if (url.startsWith('rtsp://')) {
        dev.log('🎬 [STREAM_MANAGER] Detected RTSP URL');
        
        final videoController = await _rtspHelper.initializePlayer(url);
        _rtspHelper.setupListeners(
          onError: (error) => _onError?.call(error),
          onCompleted: () => _onCompleted?.call(),
        );
        
        streamWidget = Video(
          controller: videoController,
          controls: null,
        );
        streamType = LiveStreamType.rtsp;
        
      } else {
        throw InvalidStreamUrlException('Unsupported URL format: $url');
      }

      _currentStreamType = streamType;
      _startStatusMonitoring();

      dev.log('✅ [STREAM_MANAGER] Stream initialized successfully');

      return StreamResult(
        widget: streamWidget,
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
    if (_currentStreamType == null) return false;
    
    try {
      if (_currentStreamType == LiveStreamType.youtubeLive) {
        final controller = _youtubeHelper.controller;
        if (controller == null) return false;
        final playerState = controller.value.playerState;
        return playerState == PlayerState.playing || 
               playerState == PlayerState.buffering ||
               playerState == PlayerState.paused;
      } else if (_currentStreamType == LiveStreamType.rtsp) {
        return await _rtspHelper.checkStreamActive();
      }
      return false;
    } catch (e) {
      dev.log('⚠️ [STREAM_MANAGER] Error checking stream status: $e');
      return false;
    }
  }

  /// Pause current stream
  Future<void> pauseStream() async {
    if (_currentStreamType == null) return;
    
    try {
      if (_currentStreamType == LiveStreamType.youtubeLive) {
        _youtubeHelper.controller?.pause();
      } else if (_currentStreamType == LiveStreamType.rtsp) {
        await _rtspHelper.pause();
      }
      dev.log('⏸️ [STREAM_MANAGER] Stream paused');
    } catch (e) {
      dev.log('⚠️ [STREAM_MANAGER] Error pausing stream: $e');
    }
  }

  /// Resume current stream
  Future<void> resumeStream() async {
    if (_currentStreamType == null) return;
    
    try {
      if (_currentStreamType == LiveStreamType.youtubeLive) {
        _youtubeHelper.controller?.play();
      } else if (_currentStreamType == LiveStreamType.rtsp) {
        await _rtspHelper.play();
      }
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
    await _youtubeHelper.dispose();
    await _rtspHelper.dispose();
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