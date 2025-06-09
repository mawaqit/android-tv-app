import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/domain/error/live_stream_exceptions.dart';

import '../../services/stream_manager_service.dart';
import '../../services/stream_settings_service.dart';
import 'live_stream_state_v2.dart';

/// Simplified notifier for the livestream viewer feature
class LiveStreamNotifier extends AsyncNotifier<LiveStreamState> {
  final StreamManagerService _streamManager = StreamManagerService();
  final StreamSettingsService _settingsService = StreamSettingsService();
  
  Timer? _reconnectTimer;

  @override
  Future<LiveStreamState> build() async {
    dev.log('🏗️ [LIVE_STREAM_V2] Building LiveStream Notifier V2');

    // Setup cleanup when notifier is disposed
    ref.onDispose(() async {
      dev.log('🧹 [LIVE_STREAM_V2] Provider disposed, cleaning up');
      await _dispose();
    });

    return await _initializeFromSettings();
  }

  /// Initialize stream from saved settings
  Future<LiveStreamState> _initializeFromSettings() async {
    try {
      dev.log('⚙️ [LIVE_STREAM_V2] Initializing from settings');
      
      final settings = await _settingsService.getAllSettings();
      dev.log('📊 [LIVE_STREAM_V2] Loaded settings: $settings');

      if (!settings.isEnabled || settings.streamUrl == null || settings.streamUrl!.isEmpty) {
        dev.log('ℹ️ [LIVE_STREAM_V2] Stream not enabled or no URL, returning default state');
        return LiveStreamState(
          isEnabled: settings.isEnabled,
          streamUrl: settings.streamUrl,
          replaceWorkflow: settings.replaceWorkflow,
        );
      }

      // Setup stream manager listeners
      _streamManager.setupListeners(
        onError: _handleStreamError,
        onCompleted: _handleStreamEnded,
      );

      // Initialize stream
      final result = await _streamManager.initializeStream(settings.streamUrl!);
      
      if (result.isSuccess) {
        return LiveStreamState(
          isEnabled: settings.isEnabled,
          streamUrl: settings.streamUrl,
          streamType: result.streamType,
          streamWidget: result.widget,
          streamStatus: LiveStreamStatus.active,
          replaceWorkflow: settings.replaceWorkflow,
        );
      } else {
        return LiveStreamState(
          isEnabled: settings.isEnabled,
          streamUrl: settings.streamUrl,
          streamStatus: LiveStreamStatus.error,
          isInvalidUrl: true,
          errorMessage: result.error,
          replaceWorkflow: settings.replaceWorkflow,
        );
      }
    } catch (e) {
      dev.log('🚨 [LIVE_STREAM_V2] Error initializing from settings: $e');
      throw LiveStreamInitializationException(e.toString());
    }
  }

  /// Toggle stream enabled state
  Future<void> toggleEnabled(bool isEnabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      dev.log('🔌 [LIVE_STREAM_V2] Toggling stream enabled: $isEnabled');

      await _settingsService.setStreamEnabled(isEnabled);

      if (isEnabled) {
        // Try to initialize stream if URL exists
        final url = await _settingsService.getStreamUrl();
        if (url != null && url.isNotEmpty) {
          return await _initializeStream(url);
        }
      } else {
        await _dispose();
        await _settingsService.setReplaceWorkflowEnabled(false);
      }

      return state.value!.copyWith(isEnabled: isEnabled);
    });
  }

  /// Toggle replace workflow
  Future<void> toggleReplaceWorkflow(bool isEnabled) async {
    // Don't set loading state as it interferes with the settings UI
    // state = const AsyncValue.loading();
    
    try {
      dev.log('🔄 [LIVE_STREAM_V2] Toggling replace workflow: $isEnabled');

      await _settingsService.setReplaceWorkflowEnabled(isEnabled);

      if (!isEnabled) {
        _stopReconnectTimer();
      }

      // Update state directly without loading intermediate
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.copyWith(replaceWorkflow: isEnabled),
        );
      }
    } catch (e) {
      dev.log('🚨 [LIVE_STREAM_V2] Error toggling replace workflow: $e');
      // If we have a current state, keep it and just log the error
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.copyWith(errorMessage: e.toString()),
        );
      } else {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Update stream with new URL
  Future<void> updateStream(String url) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      dev.log('🔄 [LIVE_STREAM_V2] Updating stream: $url');

      if (url.isEmpty) {
        throw StreamUrlNotProvidedException();
      }

      await _settingsService.setStreamUrl(url.trim());
      return await _initializeStream(url.trim());
    });
  }

  /// Initialize stream with URL
  Future<LiveStreamState> _initializeStream(String url) async {
    dev.log('🎯 [LIVE_STREAM_V2] Initializing stream with URL: $url');

    // Update state to connecting - clear widget to prevent disposed controller usage
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.copyWith(
          streamStatus: LiveStreamStatus.connecting,
          streamWidget: null,
          errorMessage: null,
          isInvalidUrl: false,
        ),
      );
    }

    try {
      // Setup listeners
      _streamManager.setupListeners(
        onError: _handleStreamError,
        onCompleted: _handleStreamEnded,
      );

      // Initialize stream
      final result = await _streamManager.initializeStream(url);

      if (result.isSuccess) {
        // Wait a bit to ensure old widgets are properly disposed
        await Future.delayed(const Duration(milliseconds: 200));
        
        return state.value!.copyWith(
          isEnabled: true,
          streamUrl: url,
          streamType: result.streamType,
          streamWidget: result.widget,
          streamStatus: LiveStreamStatus.active,
          isInvalidUrl: false,
          errorMessage: null,
        );
      } else {
        return state.value!.copyWith(
          streamUrl: url,
          streamStatus: LiveStreamStatus.error,
          isInvalidUrl: true,
          errorMessage: result.error,
          streamWidget: null,
        );
      }
    } catch (e) {
      dev.log('🚨 [LIVE_STREAM_V2] Error in _initializeStream: $e');
      return state.value!.copyWith(
        streamUrl: url,
        streamStatus: LiveStreamStatus.error,
        isInvalidUrl: true,
        errorMessage: e.toString(),
        streamWidget: null,
      );
    }
  }

  /// Handle stream error
  void _handleStreamError(String error) {
    dev.log('⚠️ [LIVE_STREAM_V2] Stream error: $error');

    if (!state.hasValue) return;

    // Update state to connecting for reconnection attempt
    state = AsyncValue.data(
      state.value!.copyWith(
        streamStatus: LiveStreamStatus.connecting,
        errorMessage: error,
      ),
    );

    // Start reconnection if replace workflow is enabled
    if (state.value!.replaceWorkflow) {
      _startReconnectTimer();
    }

    // Disable replace workflow after timeout
    Timer(const Duration(minutes: 1), () {
      if (state.hasValue && state.value!.streamStatus == LiveStreamStatus.connecting) {
        toggleReplaceWorkflow(false);
      }
    });
  }

  /// Handle stream ended
  void _handleStreamEnded() {
    dev.log('🏁 [LIVE_STREAM_V2] Stream ended');

    if (!state.hasValue) return;

    final wasReplacingWorkflow = state.value!.replaceWorkflow;

    // Save workflow state for restoration
    if (wasReplacingWorkflow) {
      _settingsService.setPreviousWorkflowState(true);
    }

    // Update state
    state = AsyncValue.data(
      state.value!.copyWith(
        streamStatus: LiveStreamStatus.ended,
      ),
    );

    // Start reconnection and disable workflow replacement
    _startReconnectTimer();
    if (wasReplacingWorkflow) {
      toggleReplaceWorkflow(false);
    }
  }

  /// Start reconnection timer
  void _startReconnectTimer() {
    dev.log('⏱️ [LIVE_STREAM_V2] Starting reconnection timer');
    _stopReconnectTimer();
    
    _reconnectTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) => _attemptReconnection(),
    );
  }

  /// Stop reconnection timer
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    dev.log('⏱️ [LIVE_STREAM_V2] Reconnection timer stopped');
  }

  /// Attempt stream reconnection
  Future<void> _attemptReconnection() async {
    if (!state.hasValue || !state.value!.isEnabled) return;

    final url = state.value!.streamUrl;
    if (url == null || url.isEmpty) return;

    dev.log('🔄 [LIVE_STREAM_V2] Attempting reconnection');

    try {
      final newState = await _initializeStream(url);
      
      if (newState.streamStatus == LiveStreamStatus.active) {
        dev.log('✅ [LIVE_STREAM_V2] Reconnection successful');
        
        // Restore workflow replacement if needed
        final shouldRestore = await _settingsService.getPreviousWorkflowState();
        if (shouldRestore) {
          await _settingsService.clearPreviousWorkflowState();
          await toggleReplaceWorkflow(true);
        }
        
        _stopReconnectTimer();
        state = AsyncValue.data(newState);
      }
    } catch (e) {
      dev.log('⚠️ [LIVE_STREAM_V2] Reconnection failed: $e');
    }
  }

  /// Pause stream
  Future<void> pauseStream() async {
    dev.log('⏸️ [LIVE_STREAM_V2] Pausing stream');
    await _streamManager.pauseStream();
  }

  /// Resume stream
  Future<void> resumeStream() async {
    dev.log('▶️ [LIVE_STREAM_V2] Resuming stream');
    await _streamManager.resumeStream();
  }

  /// Check stream status
  Future<void> checkStreamStatus() async {
    if (!state.hasValue || !state.value!.isEnabled) return;

    final isActive = await _streamManager.isStreamActive();
    if (!isActive && state.value!.streamStatus == LiveStreamStatus.active) {
      _handleStreamError('Stream connection lost');
    }
  }

  /// Update stream status
  void updateStreamStatus(LiveStreamStatus status) {
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.copyWith(streamStatus: status),
      );
    }
  }

  /// Dispose all resources
  Future<void> _dispose() async {
    dev.log('🧹 [LIVE_STREAM_V2] Disposing resources');
    _stopReconnectTimer();
    await _streamManager.dispose();
  }
}

/// Provider for the livestream viewer feature (V2)
final liveStreamProviderV2 = AsyncNotifierProvider<LiveStreamNotifier, LiveStreamState>(() {
  return LiveStreamNotifier();
}); 