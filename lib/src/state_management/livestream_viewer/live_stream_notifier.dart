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
class LiveStreamNotifier extends AutoDisposeAsyncNotifier<LiveStreamViewerState> {
  /// Helper for YouTube streams
  final _youtubeHelper = YouTubeStreamHelper();

  /// Helper for RTSP streams
  final _rtspHelper = RTSPStreamHelper();

  /// Timer for checking stream status
  Timer? _statusCheckTimer;

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
      _stopStatusCheckTimer();
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
        return await _handleYoutubeStream(isEnabled, url, replaceWorkflow ?? false);
      } else if (url.startsWith('rtsp://')) {
        dev.log('🎬 [LIVE_STREAM] Detected RTSP URL, handling RTSP stream');
        return await _handleRtspStream(isEnabled, url, replaceWorkflow ?? false);
      }

      dev.log('❌ [LIVE_STREAM] Invalid URL format: $url');
      throw InvalidStreamUrlException('Invalid URL format: $url');
    } catch (e) {
      dev.log('⚠️ [LIVE_STREAM] Error initializing from saved URL: $e');
      if (e is InvalidStreamUrlException) {
        return LiveStreamViewerState(
          isEnabled: isEnabled,
          streamUrl: url,
          isInvalidUrl: true,
          replaceWorkflow: replaceWorkflow ?? false,
        );
      }
      return LiveStreamViewerState(
        isEnabled: isEnabled,
        streamUrl: url,
        replaceWorkflow: replaceWorkflow ?? false,
      );
    }
  }

  /// Toggle livestream enabled state
  Future<void> toggleEnabled(bool isEnabled) async {
    try {
      dev.log('🔌 [LIVE_STREAM] Toggling livestream enabled state: $isEnabled');

      // First update the SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(LiveStreamConstants.prefKeyEnabled, isEnabled);
      dev.log('💾 [LIVE_STREAM] Updated SharedPreferences with enabled state');

      // Before making state changes, update state to loading to prevent UI from accessing controllers
      state = const AsyncValue.loading();
      dev.log('⏳ [LIVE_STREAM] Set state to loading');

      // Explicitly dispose controllers before state changes
      await _dispose();
      dev.log('🧹 [LIVE_STREAM] Disposed controllers');

      // Wait for disposal to complete
      await Future.delayed(const Duration(milliseconds: LiveStreamConstants.streamInitDelayMs));

      final currentState = state.value;
      if (currentState != null) {
        // Create a new state with the controllers cleared
        state = AsyncValue.data(
          currentState.copyWith(
            isEnabled: isEnabled,
            isInvalidUrl: false,
            // Explicitly set controllers to null to prevent old references
            youtubeController: null,
            videoController: null,
          ),
        );
        dev.log('🔄 [LIVE_STREAM] Updated state with new enabled value');

        // Only initialize streams if needed
        if (isEnabled && currentState.streamUrl != null && currentState.streamUrl!.isNotEmpty) {
          dev.log('🎥 [LIVE_STREAM] Reinitializing stream with URL: ${currentState.streamUrl}');
          // Use a slight delay to ensure UI has updated before creating new controllers
          await Future.delayed(const Duration(milliseconds: LiveStreamConstants.streamInitDelayMs));
          await updateStream(isEnabled: isEnabled, url: currentState.streamUrl ?? '');
        }

        // Start or stop status check timer based on enabled state
        if (isEnabled) {
          _startStatusCheckTimer();
        } else {
          _stopStatusCheckTimer();
        }
      }
    } catch (e, s) {
      dev.log('🚨 [LIVE_STREAM] Error toggling livestream enabled state: $e');
      state = AsyncValue.error(LiveStreamToggleException(e.toString()), s);
    }
  }

  /// Update stream with new URL and settings
  Future<void> updateStream({
    required bool isEnabled,
    required String url,
    bool replaceWorkflow = false,
  }) async {
    dev.log('🔄 [LIVE_STREAM] Updating stream - URL: $url, Enabled: $isEnabled, ReplaceWorkflow: $replaceWorkflow');

    // Store current state before going into loading
    final previousState = state.value;

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
      await prefs.setBool(LiveStreamConstants.prefKeyEnabled, isEnabled);
      await prefs.setString(LiveStreamConstants.prefKeyUrl, cleanUrl);
      await prefs.setBool(LiveStreamConstants.prefKeyReplaceWorkflow, replaceWorkflow);

      dev.log('💾 [LIVE_STREAM] Saved settings to SharedPreferences');
      dev.log('📊 [LIVE_STREAM] Stream settings - URL: $cleanUrl, ReplaceWorkflow: $replaceWorkflow');

      // Important: dispose controllers before updating state or creating new ones
      await _dispose();
      dev.log('🧹 [LIVE_STREAM] Disposed controllers before creating new ones');

      // Explicitly set status to active while initializing to prevent false detections
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.copyWith(
            streamStatus: LiveStreamStatus.active,
            // Clear controllers in state first to prevent UI from using old ones
            youtubeController: null,
            videoController: null,
          ),
        );
        dev.log('🔄 [LIVE_STREAM] Updated state with active status');
      }

      // Allow UI to update before creating new controllers
      await Future.delayed(Duration(milliseconds: 50));

      // Handle YouTube URLs
      if (LiveStreamConstants.youtubeUrlRegex.hasMatch(cleanUrl)) {
        dev.log('🎥 [LIVE_STREAM] Initializing YouTube player');
        final newState = await _handleYoutubeStream(isEnabled, cleanUrl, replaceWorkflow);

        if (state.hasValue) {
          // Ensure we're not keeping any references to old controllers
          state = AsyncValue.data(
            state.value!.copyWith(
              videoController: null,
              youtubeController: newState.youtubeController,
              streamType: LiveStreamType.youtubeLive,
              streamUrl: cleanUrl,
              isInvalidUrl: false,
              replaceWorkflow: replaceWorkflow,
              streamStatus: LiveStreamStatus.active, // Ensure status is active
            ),
          );
          dev.log('✅ [LIVE_STREAM] Updated state with YouTube player');
        } else {
          state = AsyncValue.data(newState.copyWith(replaceWorkflow: replaceWorkflow));
        }
        return;
      }
      // Handle RTSP URLs
      else if (cleanUrl.startsWith('rtsp://')) {
        dev.log('🎬 [LIVE_STREAM] Initializing RTSP player');
        final newState = await _handleRtspStream(isEnabled, cleanUrl, replaceWorkflow);

        if (state.hasValue) {
          // Ensure we're not keeping any references to old controllers
          state = AsyncValue.data(
            state.value!.copyWith(
              youtubeController: null,
              videoController: newState.videoController,
              streamType: LiveStreamType.rtsp,
              streamUrl: cleanUrl,
              isInvalidUrl: false,
              replaceWorkflow: replaceWorkflow,
              streamStatus: LiveStreamStatus.active, // Ensure status is active
            ),
          );
          dev.log('✅ [LIVE_STREAM] Updated state with RTSP player');
        } else {
          state = AsyncValue.data(newState.copyWith(replaceWorkflow: replaceWorkflow));
        }
        return;
      }

      dev.log('❌ [LIVE_STREAM] Invalid URL format: $cleanUrl');
      throw InvalidStreamUrlException('Invalid URL format: $cleanUrl');
    } catch (e, s) {
      // Clean up on error
      await _dispose();
      _stopStatusCheckTimer();
      dev.log('🚨 [LIVE_STREAM] Error updating stream: $e');

      if (e is InvalidStreamUrlException || e is StreamUrlNotProvidedException) {
        // Preserve replaceWorkflow when handling URL errors
        state = AsyncValue.data(
          LiveStreamViewerState(
            isEnabled: isEnabled,
            streamUrl: url,
            isInvalidUrl: true,
            videoController: null,
            youtubeController: null,
            replaceWorkflow: replaceWorkflow,
          ),
        );
        dev.log('⚠️ [LIVE_STREAM] Updated state for invalid URL');
      } else {
        state = AsyncValue.error(LiveStreamUpdateException(e.toString()), s);
      }
    }
  }

  /// Handle YouTube stream initialization
  Future<LiveStreamViewerState> _handleYoutubeStream(
    bool isEnabled,
    String url,
    bool replaceWorkflow,
  ) async {
    try {
      dev.log('🎥 [LIVE_STREAM] Handling YouTube stream for URL: $url');

      // Process YouTube URL and get video ID
      final videoId = await _youtubeHelper.processYouTubeUrl(url);

      // Initialize YouTube controller
      final controller = _youtubeHelper.initializeController(videoId);

      // Form standardized URL
      final standardUrl = 'https://www.youtube.com/watch?v=$videoId';

      return LiveStreamViewerState(
        isEnabled: isEnabled,
        streamUrl: standardUrl,
        isInvalidUrl: false,
        streamType: LiveStreamType.youtubeLive,
        youtubeController: controller,
        replaceWorkflow: replaceWorkflow,
        streamStatus: LiveStreamStatus.active,
      );
    } catch (e) {
      dev.log('🚨 [LIVE_STREAM] Error handling YouTube stream: $e');

      // Return a state indicating the stream isn't valid or live
      return LiveStreamViewerState(
        isEnabled: isEnabled,
        streamUrl: url,
        isInvalidUrl: true,
        streamStatus: LiveStreamStatus.error,
        replaceWorkflow: false, // Force replaceWorkflow to false for invalid streams
      );
    }
  }

  /// Handle RTSP stream initialization
  Future<LiveStreamViewerState> _handleRtspStream(
    bool isEnabled,
    String url,
    bool replaceWorkflow,
  ) async {
    try {
      dev.log('🎬 [LIVE_STREAM] Handling RTSP stream for URL: $url');

      // Initialize RTSP player
      final videoController = await _rtspHelper.initializePlayer(url);

      // Setup error and completion listeners
      _rtspHelper.setupListeners(
        onError: (error) => _handleStreamError(error),
        onCompleted: () => _handleStreamEnded(),
      );

      return LiveStreamViewerState(
        isEnabled: isEnabled,
        streamUrl: url,
        streamType: LiveStreamType.rtsp,
        isInvalidUrl: false,
        videoController: videoController,
        replaceWorkflow: replaceWorkflow,
        streamStatus: LiveStreamStatus.active,
      );
    } catch (e) {
      dev.log('🚨 [LIVE_STREAM] Error handling RTSP stream: $e');
      await _rtspHelper.dispose();
      throw LiveStreamUpdateException(e.toString());
    }
  }

  /// Start timer for checking stream status
  void _startStatusCheckTimer() {
    dev.log('⏱️ [LIVE_STREAM] Starting periodic stream status check');
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(
      const Duration(seconds: LiveStreamConstants.statusCheckIntervalSeconds),
      (timer) {
        dev.log('⏱️ [LIVE_STREAM] Starting periodic statusCheckIntervalSeconds');
        if (state.hasValue && state.value!.isEnabled) {
          checkStreamStatus();
        }
      },
    );
  }

  /// Stop timer for checking stream status
  void _stopStatusCheckTimer() {
    dev.log('⏱️ [LIVE_STREAM] Stopping periodic stream status check');
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
  }

  /// Start timer for stream reconnection attempts
  void _startReconnectTimer() {
    dev.log('⏱️ [LIVE_STREAM] Starting periodic reconnection attempts');
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(
      const Duration(seconds: LiveStreamConstants.streamReconnectIntervalSeconds),
      (timer) async {
        if (state.hasValue && state.value!.isEnabled &&
            (state.value!.streamStatus == LiveStreamStatus.ended ||
             state.value!.streamStatus == LiveStreamStatus.error)) {
          dev.log('🔄 [LIVE_STREAM] Attempting to reconnect to stream');
          await _attemptStreamReconnection();
        } else {
          _stopReconnectTimer();
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

  /// Attempt to reconnect to the stream
  Future<void> _attemptStreamReconnection() async {
    if (!state.hasValue || !state.value!.isEnabled) return;

    final currentState = state.value!;
    final url = currentState.streamUrl;

    if (url == null || url.isEmpty) return;

    dev.log('🔄 [LIVE_STREAM] Attempting reconnection to: $url');

    try {
      // Temporarily mark status as active to prevent recursive handling during reinitialization
      state = AsyncValue.data(
        currentState.copyWith(
          streamStatus: LiveStreamStatus.active,
        ),
      );

      // Reinitialize the stream with the same URL and settings
      await updateStream(
        isEnabled: true,
        url: url,
        replaceWorkflow: false, // Start without replacing workflow
      );

      dev.log('✅ [LIVE_STREAM] Successfully reconnected to stream');

      // Check if we need to restore workflow replacement
      final prefs = await SharedPreferences.getInstance();
      final shouldRestoreWorkflow = prefs.getBool(LiveStreamConstants.prefKeyPreviousWorkflowReplacement) ?? false;

      if (shouldRestoreWorkflow) {
        dev.log('🔄 [LIVE_STREAM] Restoring workflow replacement after successful reconnection');
        // Clear the preference so we don't restore again unnecessarily
        await prefs.setBool(LiveStreamConstants.prefKeyPreviousWorkflowReplacement, false);
        await toggleReplaceWorkflow(true);
      }
    } catch (e) {
      dev.log('⚠️ [LIVE_STREAM] Reconnection attempt failed: $e');
      // If reconnection fails, revert back to ended state but keep trying
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.copyWith(
            streamStatus: LiveStreamStatus.ended,
          ),
        );
      }
    }
  }

  /// Handle stream error
  Future<void> _handleStreamError(String error) async {
    dev.log('⚠️ [LIVE_STREAM] Stream error detected: $error');

    // Update state to reflect error
    if (state.hasValue) {
      // Check if we should disable workflow replacement
      final shouldDisableWorkflowReplacement = state.value!.replaceWorkflow;

      // Update state with error status
      state = AsyncValue.data(
        state.value!.copyWith(
          streamStatus: LiveStreamStatus.error,
        ),
      );
      dev.log('🔄 [LIVE_STREAM] Updated state for stream error');

      // Start reconnection attempts instead of immediately disabling workflow
      _startReconnectTimer();

      // Only disable workflow if the error is critical
      if (shouldDisableWorkflowReplacement) {
        dev.log('🔄 [LIVE_STREAM] Disabling workflow replacement due to stream error');
        await toggleReplaceWorkflow(false);
      }
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
    if (!state.hasValue || !state.value!.isEnabled) {
      dev.log('ℹ️ [LIVE_STREAM] Skipping stream status check - not enabled or no state');
      return;
    }

    final currentState = state.value!;

    // Check YouTube stream status
    if (currentState.streamType == LiveStreamType.youtubeLive && currentState.youtubeController != null) {
      try {
        final playerValue = currentState.youtubeController!.value;
        final playerState = playerValue.playerState;

        // Only consider stream ended if player is fully initialized AND ended state
        if (playerValue.metaData.videoId.isNotEmpty && playerValue.isReady && playerState == PlayerState.ended) {
          dev.log('🏁 [LIVE_STREAM] YouTube stream ended');
          await _handleStreamEnded();
        }
        // Handle errors with error code
        else if (playerValue.hasError || (playerValue.errorCode != 0)) {
          dev.log('⚠️ [LIVE_STREAM] YouTube error detected: ${playerValue.errorCode}');
          await _handleStreamError('YouTube error: ${playerValue.errorCode}');
        }
        // If the player is playing, update status to active
        else if (playerState == PlayerState.playing) {
          dev.log('▶️ [LIVE_STREAM] YouTube stream is playing');
          _updateStreamStatus(LiveStreamStatus.active);
        }
        // If the player is buffering for too long, consider it an error
        else if (playerState == PlayerState.buffering) {
          // Check if player has been buffering too long - we'll keep track with a timestamp
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          if (_bufferingStartTime == null) {
            _bufferingStartTime = timestamp;
            dev.log('⏳ [LIVE_STREAM] YouTube buffering started');
          } else if (timestamp - _bufferingStartTime! > LiveStreamConstants.bufferTimeoutMs) {
            dev.log('⚠️ [LIVE_STREAM] YouTube buffering timeout detected');
            await _handleStreamError('YouTube buffering timeout');
            _bufferingStartTime = null; // Reset after handling error
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
        // Treat exception as a stream error
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
        // If in workflow replacement mode, treat any exception as a critical error
        if (currentState.replaceWorkflow) {
          await _handleStreamError('RTSP status check error: $e');
        }
      }
    }
  }

  /// Toggle workflow replacement
  Future<void> toggleReplaceWorkflow(bool replaceWorkflow) async {
    try {
      dev.log('🔄 [LIVE_STREAM] Toggling workflow replacement: $replaceWorkflow');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(LiveStreamConstants.prefKeyReplaceWorkflow, replaceWorkflow);

      final currentState = state.value;
      if (currentState != null) {
        // Update the state with the new replaceWorkflow value
        state = AsyncValue.data(
          currentState.copyWith(
            replaceWorkflow: replaceWorkflow,
            // Reset the stream status to active if we're enabling replacement
            streamStatus: replaceWorkflow ? LiveStreamStatus.active : currentState.streamStatus,
          ),
        );
        dev.log('✅ [LIVE_STREAM] Updated state with new workflow replacement value');

        // If replacing workflow and we have a stream, make sure it's playing
        if (replaceWorkflow) {
          dev.log('▶️ [LIVE_STREAM] Resuming streams for workflow replacement');
          // Resume streams just in case
          await resumeStreams();

          // Force check the stream status
          await checkStreamStatus();
        }
      }
    } catch (e, s) {
      dev.log('🚨 [LIVE_STREAM] Error toggling workflow replacement: $e');
      state = AsyncValue.error(LiveStreamToggleException(e.toString()), s);
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
}

/// Provider for the livestream viewer feature
final liveStreamProvider = AutoDisposeAsyncNotifierProvider<LiveStreamNotifier, LiveStreamViewerState>(() {
  return LiveStreamNotifier();
});
