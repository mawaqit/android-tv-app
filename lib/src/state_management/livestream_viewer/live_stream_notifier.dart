import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/error/live_stream_exceptions.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../helpers/live_stream/rtsp_stream_helper.dart';
import '../../helpers/live_stream/youtube_stream_helper.dart';
import 'live_stream_state.dart';

/// Notifier for the livestream viewer feature
class LiveStreamNotifier extends AsyncNotifier<LiveStreamViewerState> {
  /// Helper for YouTube streams
  final _youtubeHelper = YouTubeStreamHelper();

  /// Helper for RTSP streams
  final _rtspHelper = RTSPStreamHelper();

  /// Timer for stream reconnection attempts
  Timer? _reconnectTimer;

  /// Timestamp for buffering start time
  int? _bufferingStartTime;

  @override
  Future<LiveStreamViewerState> build() async {
    dev.log('🏗️ [LIVE_STREAM] Building LiveStream Notifier');

    // Setup cleanup when notifier is disposed
    ref.onDispose(() async {
      dev.log('🧹 [LIVE_STREAM] Provider disposed, cleaning up');
      _stopReconnectTimer();
      await _dispose();
    });

    return await _initializeSettings();
  }

  /// Dispose all resources
  Future<void> _dispose() async {
    try {
      dev.log('🧹 [LIVE_STREAM] Starting disposal of controllers');

      // Dispose YouTube helper
      await _youtubeHelper.dispose();

      // Dispose RTSP helper
      await _rtspHelper.dispose();

      // Make sure to update state with null controllers
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.copyWith(
            youtubeController: null,
            videoController: null,
          ),
        );
        dev.log('🔄 [LIVE_STREAM] Updated state with null controllers');
      }
    } catch (e) {
      dev.log('🚨 [LIVE_STREAM] Error in controller disposal: $e');
    }
  }

  /// Initialize settings from SharedPreferences
  Future<LiveStreamViewerState> _initializeSettings() async {
    try {
      dev.log('⚙️ [LIVE_STREAM] Initializing settings from SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(LiveStreamConstants.prefKeyEnabled) ?? false;
      final savedUrl = prefs.getString(LiveStreamConstants.prefKeyUrl);
      final replaceWorkflow = prefs.getBool(LiveStreamConstants.prefKeyReplaceWorkflow) ?? false;

      dev.log(
          '📊 [LIVE_STREAM] Loaded settings - Enabled: $isEnabled, URL: $savedUrl, ReplaceWorkflow: $replaceWorkflow');

      if (!isEnabled || savedUrl == null || savedUrl.isEmpty) {
        dev.log('ℹ️ [LIVE_STREAM] No saved settings found, returning default state');
        return LiveStreamViewerState(
          isEnabled: isEnabled,
          streamUrl: savedUrl,
          isInvalidUrl: false,
          replaceWorkflow: replaceWorkflow,
        );
      }

      return await _initializeFromSavedUrl(
        isEnabled: isEnabled,
        url: savedUrl,
        replaceWorkflow: replaceWorkflow,
      );
    } catch (e) {
      dev.log('🚨 [LIVE_STREAM] Error initializing settings: $e');
      throw LiveStreamInitializationException(e.toString());
    }
  }

  /// Initialize from saved URL
  Future<LiveStreamViewerState> _initializeFromSavedUrl({
    required bool isEnabled,
    required String url,
    bool? replaceWorkflow,
  }) async {
    try {
      dev.log('🔄 [LIVE_STREAM] Initializing from saved URL: $url');
      await _dispose();
      // Determine the stream type and initialize accordingly
      if (LiveStreamConstants.youtubeUrlRegex.hasMatch(url)) {
        dev.log('🎥 [LIVE_STREAM] Detected YouTube URL, handling YouTube stream');
        final videoWithString = await _handleYoutubeStream(url);

        return LiveStreamViewerState(
          isEnabled: isEnabled,
          streamUrl: videoWithString.$2,
          streamStatus: LiveStreamStatus.active,
          streamType: LiveStreamType.youtubeLive,
          videoController: null,
          youtubeController: videoWithString.$1,
          isInvalidUrl: false,
          replaceWorkflow: replaceWorkflow ?? false,
        );
      } else if (url.startsWith('rtsp://')) {
        dev.log('🎬 [LIVE_STREAM] Detected RTSP URL, handling RTSP stream');
        final controller = await _handleRtspStream(url);
        return LiveStreamViewerState(
          isEnabled: isEnabled,
          streamUrl: url,
          streamStatus: LiveStreamStatus.active,
          streamType: LiveStreamType.rtsp,
          videoController: controller,
          youtubeController: null,
          isInvalidUrl: false,
          replaceWorkflow: replaceWorkflow ?? false,
        );
      } else {
        dev.log('🚨 [LIVE_STREAM] Invalid URL format: $url');
        throw InvalidStreamUrlException('Invalid URL format: $url');
      }
    } catch (e) {
      dev.log('⚠️ [LIVE_STREAM] Error initializing from saved URL: $e');
      if (e is InvalidStreamUrlException) {
        return state.value!.copyWith(
          isEnabled: isEnabled,
          streamUrl: url,
          isInvalidUrl: true,
          replaceWorkflow: replaceWorkflow ?? false,
        );
      }
      return state.value!.copyWith(
        isEnabled: isEnabled,
        streamUrl: url,
        replaceWorkflow: replaceWorkflow ?? false,
      );
    }
  }

  /// Toggle livestream enabled state
  Future<void> toggleEnabled(bool isEnabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        dev.log('🔌 [LIVE_STREAM] Toggling livestream enabled state: $isEnabled');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(LiveStreamConstants.prefKeyEnabled, isEnabled);

        // get the value and check the replace if it is active
        if (isEnabled) {
          final replaceWorkflow = prefs.getBool(LiveStreamConstants.prefKeyReplaceWorkflow) ?? false;
          if (replaceWorkflow) {
            dev.log('🔄 [LIVE_STREAM] Replacing workflow due to enabled state');
            await toggleReplaceWorkflow(true);
          }
        }

        if (!isEnabled) {
          await _dispose();
          await toggleReplaceWorkflow(false);
        } else {
          // If the stream is enabled, we need to check if the URL is valid
          final savedUrl = prefs.getString(LiveStreamConstants.prefKeyUrl);
          if (savedUrl != null && savedUrl.isNotEmpty) {
            await _initializeFromSavedUrl(
              isEnabled: isEnabled,
              url: savedUrl,
            );
          } else {
            dev.log('ℹ️ [LIVE_STREAM] No saved URL found, returning default state');
            return LiveStreamViewerState(
              isEnabled: isEnabled,
              streamUrl: savedUrl,
              isInvalidUrl: false,
            );
          }
        }

        await Future.delayed(const Duration(milliseconds: LiveStreamConstants.streamInitDelayMs));

        return state.value!.copyWith(
          isEnabled: isEnabled,
        );
      },
    );
  }

  /// toggle replace workflow
  Future<void> toggleReplaceWorkflow(bool isEnabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        dev.log('🔌 [LIVE_STREAM] Toggling livestream enabled state: $isEnabled');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(LiveStreamConstants.prefKeyReplaceWorkflow, isEnabled);

        if (!isEnabled) {
          _stopReconnectTimer();
        }

        await Future.delayed(const Duration(milliseconds: LiveStreamConstants.streamInitDelayMs));

        return state.value!.copyWith(
          replaceWorkflow: isEnabled,
        );
      },
    );
  }

  /// Update stream with new URL and settings
  Future<void> updateStream({
    required String url,
  }) async {
    // Set state to loading
    state = const AsyncValue.loading();
    dev.log('⏳ [LIVE_STREAM] Set state to loading');

    // IMPORTANT: Small delay to allow any UI components to detach from the controllers
    await Future.delayed(const Duration(milliseconds: LiveStreamConstants.streamInitDelayMs));

    try {
      if (url.isEmpty) {
        dev.log('❌ [LIVE_STREAM] Empty URL provided');
        throw StreamUrlNotProvidedException();
      }

      dev.log('🔍 [LIVE_STREAM] Processing URL: $url');

      // Try to cleanup URL - sometimes there are extra parameters or spaces
      String cleanUrl = url.trim();

      // Save settings to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LiveStreamConstants.prefKeyUrl, cleanUrl);

      dev.log('🧹 [LIVE_STREAM] Disposed controllers before creating new ones');

      // Explicitly set status to active while initializing to prevent false detections
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.copyWith(
            streamStatus: LiveStreamStatus.connecting,
            // Clear controllers in state first to prevent UI from using old ones
            youtubeController: null,
            videoController: null,
          ),
        );
      }

      // Allow UI to update before creating new controllers
      await Future.delayed(Duration(milliseconds: 50));

      // Handle YouTube URLs
      if (LiveStreamConstants.youtubeUrlRegex.hasMatch(cleanUrl)) {
        dev.log('🎥 [LIVE_STREAM] Initializing YouTube player');
        _handleYoutubeStream(cleanUrl);
        final videoWithString = await _handleYoutubeStream(cleanUrl);
        state = AsyncValue.data(
          state.value!.copyWith(
            streamStatus: LiveStreamStatus.active,
            youtubeController: videoWithString.$1,
            streamUrl: videoWithString.$2,
            streamType: LiveStreamType.youtubeLive,
          ),
        );
      }
      // Handle RTSP URLs
      else if (cleanUrl.startsWith('rtsp://')) {
        dev.log('🎬 [LIVE_STREAM] Initializing RTSP player');
        final controller = await _handleRtspStream(cleanUrl);
        state = AsyncValue.data(
          state.value!.copyWith(
            streamStatus: LiveStreamStatus.active,
            videoController: controller,
            streamUrl: cleanUrl,
            streamType: LiveStreamType.rtsp,
          ),
        );
      } else {
        throw InvalidStreamUrlException('Invalid URL format: $cleanUrl');
      }
    } catch (e, s) {
      // Clean up on error
      await _dispose();

      dev.log('🚨 [LIVE_STREAM] Error updating stream: $e');

      if (e is InvalidStreamUrlException || e is StreamUrlNotProvidedException) {
        // Preserve replaceWorkflow when handling URL errors
        state = AsyncValue.data(
          state.value!.copyWith(
            isEnabled: false,
            streamUrl: url,
            isInvalidUrl: true,
            streamStatus: LiveStreamStatus.error,
          ),
        );
        dev.log('⚠️ [LIVE_STREAM] Updated state for invalid URL');
      } else {
        state = AsyncValue.error(LiveStreamUpdateException(e.toString()), s);
      }
    }
  }

  /// Handle YouTube stream initialization
  Future<(YoutubePlayerController, String)> _handleYoutubeStream(
    String url,
  ) async {
    try {
      dev.log('🎥 [LIVE_STREAM] Handling YouTube stream for URL: $url');

      // Process YouTube URL and get video ID
      final videoId = await _youtubeHelper.processYouTubeUrl(url);

      // Initialize YouTube controller
      final controller = _youtubeHelper.initializeController(videoId);

      // Form standardized URL
      final standardUrl = 'https://www.youtube.com/watch?v=$videoId';

      return (controller, standardUrl);
    } catch (e) {
      dev.log('🚨 [LIVE_STREAM] Error handling YouTube stream: $e');

      throw LiveStreamUpdateException(e.toString());
    }
  }

  /// Handle RTSP stream initialization
  Future<VideoController> _handleRtspStream(String url) async {
    try {
      dev.log('🎬 [LIVE_STREAM] Handling RTSP stream for URL: $url');

      // Initialize RTSP player
      final videoController = await _rtspHelper.initializePlayer(url);

      // Setup error and completion listeners
      _rtspHelper.setupListeners(
        onError: (error) => _handleStreamError(error),
        onCompleted: () => _handleStreamEnded(),
      );

      return videoController;
    } catch (e) {
      dev.log('🚨 [LIVE_STREAM] Error handling RTSP stream: $e');
      await _rtspHelper.dispose();
      throw LiveStreamUpdateException(e.toString());
    }
  }

  /// Start timer for stream reconnection attempts
  void _startReconnectTimer() {
    dev.log('⏱️ [LIVE_STREAM] Starting stream reconnection timer');
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(
      const Duration(seconds: LiveStreamConstants.streamReconnectIntervalSeconds),
      (timer) async {
        if (state.hasValue && state.value!.isEnabled) {
          await _attemptStreamReconnection();
        }
      },
    );
  }

  /// Stop timer for stream reconnection attempts
  void _stopReconnectTimer() {
    dev.log('⏱️ [LIVE_STREAM] Stopping reconnection timer');
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Handle stream error
  Future<void> _handleStreamError(String error) async {
    dev.log('⚠️ [LIVE_STREAM] Stream error detected: $error');

    // Update state to reflect error
    if (state.hasValue) {
      final currentState = state.value!;

      // Set status to connecting and start reconnection timer
      state = AsyncValue.data(
        currentState.copyWith(
          streamStatus: LiveStreamStatus.connecting,
        ),
      );
      dev.log('🔄 [LIVE_STREAM] Updated state to connecting');

      // Start reconnection timer with 1 minute interval if the replace workflow is enabled
      if (currentState.replaceWorkflow) {
        _startReconnectTimer();
      } else {
        dev.log('🔄 [LIVE_STREAM] Starting reconnection timer without workflow replacement');
      }

      // If still not connected after 1 minute, disable workflow replacement
      Future.delayed(const Duration(minutes: 1), () async {
        if (state.hasValue && state.value!.streamStatus == LiveStreamStatus.connecting) {
          dev.log('⚠️ [LIVE_STREAM] Reconnection timeout after 1 minute');
          await toggleReplaceWorkflow(false);
        }
      });
    }
  }

  /// Handle stream ended
  Future<void> _handleStreamEnded() async {
    dev.log('🏁 [LIVE_STREAM] Stream ended detected');

    // Update state to reflect ended stream
    if (state.hasValue) {
      final currentState = state.value!;
      final wasReplacingWorkflow = currentState.replaceWorkflow;

      // Store the previous workflow state in SharedPreferences for restoration after reconnection
      if (wasReplacingWorkflow) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(LiveStreamConstants.prefKeyPreviousWorkflowReplacement, true);
        dev.log('💾 [LIVE_STREAM] Saved previous workflow replacement state for restoration');
      }

      // Update state with ended status
      state = AsyncValue.data(
        currentState.copyWith(
          streamStatus: LiveStreamStatus.ended,
        ),
      );
      dev.log('🔄 [LIVE_STREAM] Updated state for stream ended');

      // Start reconnection attempts
      _startReconnectTimer();

      // If we're in workflow replacement mode, we should handle differently
      if (currentState.replaceWorkflow) {
        dev.log('🔄 [LIVE_STREAM] Disabling workflow replacement due to stream ended');
        await toggleReplaceWorkflow(false);
      }
    }
  }

  /// Update stream status
  void _updateStreamStatus(LiveStreamStatus status) {
    if (state.hasValue && state.value!.streamStatus != status) {
      dev.log('🔄 [LIVE_STREAM] Updating stream status to: $status');
      state = AsyncValue.data(
        state.value!.copyWith(
          streamStatus: status,
        ),
      );
    }
  }

  /// Public method to update stream status from outside components
  void updateStreamStatus(LiveStreamStatus status) {
    dev.log('🔄 [LIVE_STREAM] Public update of stream status to: $status');
    _updateStreamStatus(status);
  }

  /// Check stream status and update if needed
  Future<void> checkStreamStatus() async {
    if (!state.hasValue || !state.value!.isEnabled) return;

    final currentState = state.value!;

    // Check YouTube stream status
    if (currentState.streamType == LiveStreamType.youtubeLive && currentState.youtubeController != null) {
      try {
        final playerState = currentState.youtubeController!.value.playerState;

        if (playerState == PlayerState.ended) {
          await _handleStreamEnded();
        } else if (playerState == PlayerState.buffering) {
          // Check if player has been buffering too long
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          if (_bufferingStartTime == null) {
            _bufferingStartTime = timestamp;
            dev.log('⏳ [LIVE_STREAM] YouTube buffering started');
          } else if (timestamp - _bufferingStartTime! > LiveStreamConstants.bufferTimeoutMs) {
            dev.log('⚠️ [LIVE_STREAM] YouTube buffering timeout detected');
            // Set status to unreliable instead of error
            state = AsyncValue.data(
              currentState.copyWith(
                streamStatus: LiveStreamStatus.unreliable,
              ),
            );
            _bufferingStartTime = null;
          }
        } else {
          // Reset buffering timestamp if we're not buffering
          if (_bufferingStartTime != null) {
            dev.log('🔄 [LIVE_STREAM] YouTube buffering ended, resetting timestamp');
            _bufferingStartTime = null;
          }
        }
      } catch (e) {
        dev.log('⚠️ [LIVE_STREAM] Error checking YouTube stream status: $e');
        await _handleStreamError('YouTube status check error: $e');
      }
    }
    // Check RTSP stream status
    else if (currentState.streamType == LiveStreamType.rtsp && currentState.videoController != null) {
      try {
        final isActive = await _rtspHelper.checkStreamActive();

        if (!isActive && currentState.streamStatus == LiveStreamStatus.active) {
          dev.log('⚠️ [LIVE_STREAM] RTSP stream is no longer active');
          await _handleStreamEnded();
        }
      } catch (e) {
        dev.log('⚠️ [LIVE_STREAM] Error checking RTSP stream status: $e');
        await _handleStreamError('RTSP status check error: $e');
      }
    }
  }

  /// Pause all streams
  Future<void> pauseStreams() async {
    dev.log('⏸️ [LIVE_STREAM] Pausing all streams');

    // Pause YouTube stream
    _youtubeHelper.controller?.pause();

    // Pause RTSP stream
    await _rtspHelper.pause();
  }

  /// Resume all streams
  Future<void> resumeStreams() async {
    dev.log('▶️ [LIVE_STREAM] Resuming all streams');

    // Resume YouTube stream
    _youtubeHelper.controller?.play();

    // Resume RTSP stream
    await _rtspHelper.play();
  }

  /// Attempt to reconnect to the stream
  Future<void> _attemptStreamReconnection() async {
    if (!state.hasValue || !state.value!.isEnabled) return;

    final currentState = state.value!;
    final url = currentState.streamUrl;

    if (url == null || url.isEmpty) return;

    dev.log('🔄 [LIVE_STREAM] Attempting reconnection to: $url');

    try {
      // Set status to connecting
      state = AsyncValue.data(
        currentState.copyWith(
          streamStatus: LiveStreamStatus.connecting,
        ),
      );

      // Reinitialize the stream
      await updateStream(
        url: url,
      );

      // If successful, set status back to active
      if (state.hasValue && state.value!.streamStatus == LiveStreamStatus.active) {
        dev.log('✅ [LIVE_STREAM] Successfully reconnected to stream');

        // Restore workflow replacement if it was previously enabled
        final prefs = await SharedPreferences.getInstance();
        final shouldRestoreWorkflow = prefs.getBool(LiveStreamConstants.prefKeyPreviousWorkflowReplacement) ?? false;

        if (shouldRestoreWorkflow) {
          dev.log('🔄 [LIVE_STREAM] Restoring workflow replacement');
          await prefs.setBool(LiveStreamConstants.prefKeyPreviousWorkflowReplacement, false);
          await toggleReplaceWorkflow(true);
        }
      }
    } catch (e) {
      dev.log('⚠️ [LIVE_STREAM] Reconnection attempt failed: $e');
      // Keep trying to reconnect
    }
  }
}

/// Provider for the livestream viewer feature
final liveStreamProvider = AsyncNotifierProvider<LiveStreamNotifier, LiveStreamViewerState>(() {
  return LiveStreamNotifier();
});
