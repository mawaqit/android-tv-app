import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/error/rtsp_expceptions.dart';
import 'package:mawaqit/src/services/stream_monitor.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/camera_stream_overlay_notifier.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/camera_stream_overlay_state.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_state.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

enum StreamType { rtsp, youtubeLive }

class RTSPCameraSettingsNotifier
    extends AutoDisposeAsyncNotifier<RTSPCameraSettingsState> {
  YoutubePlayerController? _youtubeController;
  Player? _player;
  VideoController? _videoController;
  StreamMonitorService? _streamMonitor;

  Future<void> dispose() async {
    try {
      // Stop monitoring
      _streamMonitor?.stopMonitoring();

      // Existing disposal code...
      if (_youtubeController != null) {
        _youtubeController!.dispose();
        _youtubeController = null;
      }

      if (_player != null) {
        await _player!.pause();
        await _player!.dispose();
        _player = null;
      }

      if (_videoController != null) {
        await _videoController!.player.dispose();
        _videoController = null;
      }
    } catch (e) {
      log('Error disposing controllers: $e');
    }
  }

  @override
  Future<RTSPCameraSettingsState> build() async {
    ref.onDispose(() async {
      await dispose();
    });
    _initializeStreamMonitor();
    // Add a listener for the overlay settings
    ref.listen(streamOverlaySettingsProvider, (previous, current) {
      // Handle auto-overlay setting changes
      if (previous?.autoOverlayEnabled != current.autoOverlayEnabled) {
        if (current.autoOverlayEnabled) {
          // Auto-overlay was enabled - check if stream is already live
          if (_streamMonitor != null && state.hasValue && state.value != null) {
            // Don't automatically show overlay - let the monitor check first
            _startMonitoring();
            // Call checkAndNotifyNow, which will update the overlay if stream is live
            _streamMonitor!.checkAndNotify();
          }
        } else {
          // Auto-overlay was disabled - don't automatically hide if manually shown
          // This is handled by the toggleAutoOverlay method now
        }
      }
    });
    return await initializeSettings();
  }

  void _initializeStreamMonitor() {
    _streamMonitor = StreamMonitorService(
      onStreamStatusChanged: (isLive) async {
        if (state.hasValue && state.value != null) {
          final overlaySettings = ref.read(streamOverlaySettingsProvider);

          if (isLive && state.value!.isRTSPEnabled) {
            // Only start the stream if it's live and enabled
            await _startStream();

            // Activate overlay only if auto-overlay is enabled AND stream is confirmed live
            // AND stream controller is properly initialized
            if (overlaySettings.autoOverlayEnabled &&
                (_player?.state.playing == true ||
                    _youtubeController?.value.isPlaying == true)) {
              ref
                  .read(streamOverlaySettingsProvider.notifier)
                  .setOverlayActive(true);
            }
          } else {
            // Pause stream if not live
            await pauseStreams();

            // Deactivate overlay when stream ends (but only if auto-overlay is enabled)
            // This ensures manual overlay usage isn't affected
            if (overlaySettings.autoOverlayEnabled &&
                overlaySettings.isOverlayActive) {
              ref
                  .read(streamOverlaySettingsProvider.notifier)
                  .setOverlayActive(false);
            }
          }
        }
      },
    );
  }

  Future<void> _startMonitoring() async {
    if (_streamMonitor != null && state.hasValue && state.value != null) {
      final currentState = state.value!;
      if (currentState.streamUrl != null &&
          currentState.streamUrl!.isNotEmpty) {
        // Stop any existing monitoring first
        _streamMonitor!.stopMonitoring();

        // Start monitoring with the current URL and stream type
        _streamMonitor!.startMonitoring(
          currentState.streamUrl!,
          currentState.streamType!,
        );

        // Log monitoring start
        debugPrint('Started monitoring stream: ${currentState.streamUrl}');
      }
    }
  }

  Future<void> _startStream() async {
    if (state.value?.streamUrl == null) return;

    try {
      if (state.value!.streamType == StreamType.youtubeLive) {
        await _handleYoutubeStream(true, state.value!.streamUrl!);
      } else if (state.value!.streamType == StreamType.rtsp) {
        await _handleRTSPStream(true, state.value!.streamUrl!);
      }
    } catch (e) {
      debugPrint('Error starting stream: $e');
    }
  }

  Future<RTSPCameraSettingsState> initializeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled =
          prefs.getBool(RtspCameraStreamConstant.prefKeyEnabled) ?? false;
      final savedUrl = prefs.getString(RtspCameraStreamConstant.prefKeyUrl);

      if (!isEnabled || savedUrl == null || savedUrl.isEmpty) {
        return RTSPCameraSettingsState(
          isRTSPEnabled: isEnabled,
          streamUrl: savedUrl,
          isInvalidUrl: false,
        );
      }

      final initialState =
          await _initializeFromSavedUrl(isEnabled: isEnabled, url: savedUrl);

      // Start monitoring if enabled
      if (isEnabled) {
        // Delay the monitoring start until after state is set
        Future.microtask(() => _startMonitoring());
      }

      return initialState;
    } catch (e, s) {
      throw RTSPInitializationException(e.toString());
    }
  }

  Future<RTSPCameraSettingsState> _initializeFromSavedUrl({
    required bool isEnabled,
    required String url,
  }) async {
    try {
      await dispose();
      if (RtspCameraStreamConstant.youtubeUrlRegex.hasMatch(url)) {

        return await _handleYoutubeStream(isEnabled, url);
      } else if (url.startsWith('rtsp://')) {
        return await _handleRTSPStream(isEnabled, url);
      }

      throw InvalidRTSPURLException('Invalid URL format: $url');

    } catch (e) {
      if (e is InvalidRTSPURLException) {
        return RTSPCameraSettingsState(
          isRTSPEnabled: isEnabled,
          streamUrl: url,
          isInvalidUrl: true,
        );
      }
      return RTSPCameraSettingsState(
        isRTSPEnabled: isEnabled,
        streamUrl: url,
      );
    }
  }

  // Modified toggleEnabled method
  Future<void> toggleEnabled(bool isEnabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(RtspCameraStreamConstant.prefKeyEnabled, isEnabled);

      final currentState = state.value;
      if (currentState != null) {
        if (!isEnabled) {
          await pauseStreams();
          _streamMonitor?.stopMonitoring();
        }

        state = AsyncValue.data(
          currentState.copyWith(
            isRTSPEnabled: isEnabled,
            isInvalidUrl: false,
          ),
        );

        if (isEnabled && currentState.streamUrl != null) {
          // Don't immediately start the stream, but start monitoring
          await _startMonitoring();
        }
      }
    } catch (e, s) {
      state = AsyncValue.error(RTSPToggleException(e.toString()), s);
    }
  }

  Future<void> updateStream({
    required bool isEnabled,
    required String url,
  }) async {
    state = const AsyncValue.loading();
    try {
      if (url.isEmpty) {
        throw URLNotProvidedRTSPURLException(url);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(RtspCameraStreamConstant.prefKeyEnabled, isEnabled);
      await prefs.setString(RtspCameraStreamConstant.prefKeyUrl, url);

      // Dispose of existing controllers before creating new ones
      await dispose();

      // Handle YouTube URLs (including live streams)
      if (RtspCameraStreamConstant.youtubeUrlRegex.hasMatch(url)) {
        final newState = await _handleYoutubeStream(isEnabled, url);
        if (state.hasValue) {
          // Ensure we're not keeping any references to old controllers
          state = AsyncValue.data(
            state.value!.copyWith(
              videoController: null,
              youtubeController: newState.youtubeController,
              streamType: StreamType.youtubeLive,
              streamUrl: url,
              isInvalidUrl: false,
            ),
          );
        } else {
          state = AsyncValue.data(newState);
        }
        return;
      }
      // Handle RTSP URLs
      else if (url.startsWith('rtsp://')) {
        final newState = await _handleRTSPStream(isEnabled, url);
        if (state.hasValue) {
          // Ensure we're not keeping any references to old controllers
          state = AsyncValue.data(
            state.value!.copyWith(
              youtubeController: null,
              videoController: newState.videoController,
              streamType: StreamType.rtsp,
              streamUrl: url,
              isInvalidUrl: false,
            ),
          );
        } else {
          state = AsyncValue.data(newState);
        }
        return;
      }
      if (isEnabled) {
        // Don't automatically start the stream - let the monitor determine if it's live
        await _startMonitoring();
      }
      throw InvalidRTSPURLException('Invalid URL format: $url');
    } catch (e, s) {
      // Clean up on error
      await dispose();

      if (e is InvalidRTSPURLException || e is URLNotProvidedRTSPURLException) {
        state = AsyncValue.data(
          state.value!.copyWith(
            isInvalidUrl: true,
            videoController: null,
            youtubeController: null,
          ),
        );
      } else {
        log('Error updating stream: $e', error: e, stackTrace: s);
        state = AsyncValue.error(e, s);
      }
    }
  }

  String? extractVideoId(String url) {
    if (url.contains('youtube.com/live/')) {
      return url.split('youtube.com/live/')[1].split('?').first;
    }
    return YoutubePlayer.convertUrlToId(url);
  }

  Future<RTSPCameraSettingsState> _handleYoutubeStream(
      bool isEnabled, String url) async {
    try {
      // Ensure previous controllers are disposed
      await dispose();

      final videoId = extractVideoId(url);
      if (videoId == null) {
        throw InvalidRTSPURLException('URL is empty: $url');
      }
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
          hideControls: true,
          isLive: true,
          useHybridComposition: true,
          forceHD: true,
        ),
      );

      return RTSPCameraSettingsState(
        isRTSPEnabled: isEnabled,
        streamUrl: url,
        isInvalidUrl: false,
        streamType: StreamType.youtubeLive,
        youtubeController: _youtubeController,
      );
    } catch (e) {
      await dispose();
      throw YouTubeVideoIdExtractionException(e.toString());
    }
  }

  Future<RTSPCameraSettingsState> _handleRTSPStream(
      bool isEnabled, String url) async {
    try {
      // Ensure previous controllers are disposed
      await dispose();

      _player = Player();
      _videoController = VideoController(_player!);
      await _player!.open(Media(url));

      return RTSPCameraSettingsState(
        isRTSPEnabled: isEnabled,
        streamUrl: url,
        streamType: StreamType.rtsp,
        isInvalidUrl: false,
        videoController: _videoController,
      );
    } catch (e) {
      await dispose();
      throw RTSPStreamUpdateException(e.toString());
    }
  }

  // Add this method to pause/stop streams
  Future<void> pauseStreams() async {
    _youtubeController?.pause();
    await _player?.pause();
  }

  // Add this method to resume streams
  Future<void> resumeStreams() async {
    _youtubeController?.play();
    await _player?.play();
  }
}

final rtspCameraSettingsProvider = AutoDisposeAsyncNotifierProvider<
    RTSPCameraSettingsNotifier, RTSPCameraSettingsState>(() {
  return RTSPCameraSettingsNotifier();
});
