import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/error/rtsp_expceptions.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_state.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

enum StreamType { rtsp, youtubeLive }

class RTSPCameraSettingsNotifier extends AutoDisposeAsyncNotifier<RTSPCameraSettingsState> {
  YoutubePlayerController? _youtubeController;
  Player? _player;
  VideoController? _videoController;
  Timer? _statusCheckTimer;

  Future<void> _dispose() async {
    try {
      dev.log('🧹 [RTSP_NOTIFIER] Starting disposal of controllers');
      if (_youtubeController != null) {
        // First remove all listeners to prevent callbacks during disposal
        try {
          _youtubeController!.removeListener(() {});
          dev.log('🎥 [RTSP_NOTIFIER] Removed YouTube controller listeners');
        } catch (e) {
          dev.log('⚠️ [RTSP_NOTIFIER] Error removing YouTube controller listeners: $e');
        }

        // Use a try/catch specifically for YouTube controller disposal
        try {
          _youtubeController!.dispose();
          dev.log('🎥 [RTSP_NOTIFIER] Disposed YouTube controller');
        } catch (e) {
          dev.log('⚠️ [RTSP_NOTIFIER] Error disposing YouTube controller: $e');
        }
        _youtubeController = null;
      }

      if (_player != null) {
        try {
          await _player!.pause();
          await _player!.dispose();
          dev.log('🎬 [RTSP_NOTIFIER] Disposed media player');
        } catch (e) {
          dev.log('⚠️ [RTSP_NOTIFIER] Error disposing media player: $e');
        }
        _player = null;
      }

      if (_videoController != null) {
        try {
          await _videoController!.player.dispose();
          dev.log('🎬 [RTSP_NOTIFIER] Disposed video controller');
        } catch (e) {
          dev.log('⚠️ [RTSP_NOTIFIER] Error disposing video controller: $e');
        }
        _videoController = null;
      }

      // Make sure to update state with null controllers
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.copyWith(
            youtubeController: null,
            videoController: null,
          ),
        );
        dev.log('🔄 [RTSP_NOTIFIER] Updated state with null controllers');
      }
    } catch (e) {
      dev.log('🚨 [RTSP_NOTIFIER] Error in general controller disposal: $e');
    }
  }

  @override
  Future<RTSPCameraSettingsState> build() async {
    dev.log('🏗️ [RTSP_NOTIFIER] Building RTSP Camera Settings Notifier');
    ref.onDispose(() async {
      dev.log('🧹 [RTSP_NOTIFIER] Provider disposed, cleaning up');
      _statusCheckTimer?.cancel();
      await _dispose();
    });

    return await initializeSettings();
  }

  void _startStatusCheckTimer() {
    dev.log('⏱️ [RTSP_NOTIFIER] Starting periodic stream status check');
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      print('🔍 [RTSP_NOTIFIER] Checking stream status');
      if (state.hasValue && state.value!.isRTSPEnabled) {
        checkStreamStatus();
      }
    });
  }

  void _stopStatusCheckTimer() {
    dev.log('⏱️ [RTSP_NOTIFIER] Stopping periodic stream status check');
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
  }

  Future<RTSPCameraSettingsState> initializeSettings() async {
    try {
      dev.log('⚙️ [RTSP_NOTIFIER] Initializing settings from SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(RtspCameraStreamConstant.prefKeyEnabled) ?? false;
      final savedUrl = prefs.getString(RtspCameraStreamConstant.prefKeyUrl);
      final replaceWorkflow = prefs.getBool(RtspCameraStreamConstant.prefKeyReplaceWorkflow) ?? false;

      dev.log(
          '📊 [RTSP_NOTIFIER] Loaded settings - Enabled: $isEnabled, URL: $savedUrl, ReplaceWorkflow: $replaceWorkflow');

      if (!isEnabled || savedUrl == null || savedUrl.isEmpty) {
        dev.log('ℹ️ [RTSP_NOTIFIER] No saved settings found, returning default state');
        return RTSPCameraSettingsState(
          isRTSPEnabled: isEnabled,
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
    } catch (e, s) {
      dev.log('🚨 [RTSP_NOTIFIER] Error initializing settings: $e');
      throw RTSPInitializationException(e.toString());
    }
  }

  Future<RTSPCameraSettingsState> _initializeFromSavedUrl({
    required bool isEnabled,
    required String url,
    bool? replaceWorkflow,
  }) async {
    try {
      dev.log('🔄 [RTSP_NOTIFIER] Initializing from saved URL: $url');
      await _dispose();
      if (RtspCameraStreamConstant.youtubeUrlRegex.hasMatch(url)) {
        dev.log('🎥 [RTSP_NOTIFIER] Detected YouTube URL, handling YouTube stream');
        return await _handleYoutubeStream(isEnabled, url);
      } else if (url.startsWith('rtsp://')) {
        dev.log('🎬 [RTSP_NOTIFIER] Detected RTSP URL, handling RTSP stream');
        return await _handleRTSPStream(isEnabled, url);
      }

      dev.log('❌ [RTSP_NOTIFIER] Invalid URL format: $url');
      throw InvalidRTSPURLException('Invalid URL format: $url');
    } catch (e) {
      dev.log('⚠️ [RTSP_NOTIFIER] Error initializing from saved URL: $e');
      if (e is InvalidRTSPURLException) {
        return RTSPCameraSettingsState(
          isRTSPEnabled: isEnabled,
          streamUrl: url,
          isInvalidUrl: true,
          replaceWorkflow: replaceWorkflow ?? false,
        );
      }
      return RTSPCameraSettingsState(
        isRTSPEnabled: isEnabled,
        streamUrl: url,
        replaceWorkflow: replaceWorkflow ?? false,
      );
    }
  }

  Future<void> toggleEnabled(bool isEnabled) async {
    try {
      dev.log('🔌 [RTSP_NOTIFIER] Toggling RTSP enabled state: $isEnabled');
      // First update the SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(RtspCameraStreamConstant.prefKeyEnabled, isEnabled);
      dev.log('💾 [RTSP_NOTIFIER] Updated SharedPreferences with enabled state');

      // Before making state changes, update state to loading to prevent UI from accessing controllers
      state = const AsyncValue.loading();
      dev.log('⏳ [RTSP_NOTIFIER] Set state to loading');

      // Explicitly dispose controllers before state changes
      await _dispose();
      dev.log('🧹 [RTSP_NOTIFIER] Disposed controllers');

      // Wait for disposal to complete
      await Future.delayed(const Duration(milliseconds: 200));

      final currentState = state.value;
      if (currentState != null) {
        // Create a new state with the controllers cleared
        state = AsyncValue.data(
          currentState.copyWith(
            isRTSPEnabled: isEnabled,
            isInvalidUrl: false,
            // Explicitly set controllers to null to prevent old references
            youtubeController: null,
            videoController: null,
          ),
        );
        dev.log('🔄 [RTSP_NOTIFIER] Updated state with new enabled value');

        // Only initialize streams if needed
        if (isEnabled && currentState.streamUrl != null && currentState.streamUrl!.isNotEmpty) {
          dev.log('🎥 [RTSP_NOTIFIER] Reinitializing stream with URL: ${currentState.streamUrl}');
          // Use a slight delay to ensure UI has updated before creating new controllers
          await Future.delayed(const Duration(milliseconds: 200));
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
      dev.log('🚨 [RTSP_NOTIFIER] Error toggling RTSP enabled state: $e');
      state = AsyncValue.error(RTSPToggleException(e.toString()), s);
    }
  }

  Future<void> updateStream({
    required bool isEnabled,
    required String url,
    bool replaceWorkflow = false,
  }) async {
    dev.log('🔄 [RTSP_NOTIFIER] Updating stream - URL: $url, Enabled: $isEnabled, ReplaceWorkflow: $replaceWorkflow');
    // Store current state before going into loading
    final previousState = state.value;

    // Set state to loading
    state = const AsyncValue.loading();
    dev.log('⏳ [RTSP_NOTIFIER] Set state to loading');

    // IMPORTANT: Small delay to allow any UI components to detach from the controllers
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      if (url.isEmpty) {
        dev.log('❌ [RTSP_NOTIFIER] Empty URL provided');
        throw URLNotProvidedRTSPURLException(url);
      }

      dev.log('🔍 [RTSP_NOTIFIER] Processing URL: $url');

      // Try to cleanup YouTube URL - sometimes there are extra parameters or spaces
      String cleanUrl = url.trim();

      // Basic validation for YouTube URLs
      if (cleanUrl.contains('youtube.com') || cleanUrl.contains('youtu.be')) {
        dev.log('🎥 [RTSP_NOTIFIER] YouTube URL detected, attempting to validate');

        // Extract video ID
        final videoId = extractVideoId(cleanUrl);
        if (videoId == null || videoId.isEmpty) {
          dev.log('❌ [RTSP_NOTIFIER] Could not extract valid video ID from URL: $cleanUrl');
          throw InvalidRTSPURLException('Could not extract valid YouTube video ID');
        }

        dev.log('✅ [RTSP_NOTIFIER] Successfully extracted YouTube video ID: $videoId');

        // Check if the URL is a YouTube Live stream
        if (cleanUrl.contains('youtube.com/live/')) {
          dev.log('🎥 [RTSP_NOTIFIER] Detected YouTube live URL format');
          // Many YouTube live URLs in this format are actually just links to a channel
          // They often don't have a valid video ID that can be played

          // Try to convert to a standard YouTube URL with v= parameter if possible
          try {
            // Use YoutubeExplode to validate if this is an actual playable video
            final yt = YoutubeExplode();
            dev.log('🔍 [RTSP_NOTIFIER] Validating YouTube video with YoutubeExplode');

            // Use a timeout for the validation check
            final video = await yt.videos.get(videoId).timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                dev.log('⏰ [RTSP_NOTIFIER] Timeout validating YouTube video');
                throw TimeoutException('Timed out attempting to validate YouTube video ID');
              },
            );

            // Check if the video is actually live
            final isActuallyLive = video.isLive;
            dev.log('🎥 [RTSP_NOTIFIER] YouTube video is actually live: $isActuallyLive');

            // Make sure to close the YoutubeExplode client
            yt.close();

            if (!isActuallyLive) {
              dev.log('❌ [RTSP_NOTIFIER] YouTube video is not a live stream: $videoId');

              // IMPORTANT: Keep previous controllers and just update error state
              // to avoid disposal issues during rendering
              if (previousState != null) {
                // Return error state but keep existing controller reference
                state = AsyncValue.data(
                  previousState.copyWith(
                    isInvalidUrl: true,
                    streamStatus: StreamStatus.error,
                    replaceWorkflow: false, // Force disable replacement workflow for non-live
                  ),
                );
                dev.log('🔄 [RTSP_NOTIFIER] Updated state for non-live video');
              }

              // Schedule disposal after UI has updated
              Future.delayed(Duration(milliseconds: 100), () async {
                await _dispose();
              });

              throw InvalidRTSPURLException('This YouTube URL is not a live stream. Only live streams can be used.');
            }

            // Convert to a standard YouTube URL with v= parameter
            cleanUrl = 'https://www.youtube.com/watch?v=$videoId';
            dev.log('🔄 [RTSP_NOTIFIER] Converted live URL to standard format: $cleanUrl');
          } catch (e) {
            dev.log('⚠️ [RTSP_NOTIFIER] Error validating YouTube URL: $e');

            // Reset to previous state but mark as invalid
            if (previousState != null) {
              state = AsyncValue.data(
                previousState.copyWith(
                  isInvalidUrl: true,
                  streamStatus: StreamStatus.error,
                  replaceWorkflow: false,
                ),
              );

              // Schedule disposal after UI has updated
              Future.delayed(Duration(milliseconds: 100), () async {
                await _dispose();
              });
            }

            throw InvalidRTSPURLException('Unable to validate YouTube URL: ${e.toString()}');
          }
        } else {
          // For standard YouTube URLs, also verify if it's actually live
          try {
            final yt = YoutubeExplode();
            dev.log('🔍 [RTSP_NOTIFIER] Validating standard YouTube URL');
            final video = await yt.videos.get(videoId).timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                dev.log('⏰ [RTSP_NOTIFIER] Timeout validating YouTube video');
                throw TimeoutException('Timed out attempting to validate YouTube video');
              },
            );

            // Check if the video is actually live
            final isActuallyLive = video.isLive;
            dev.log('🎥 [RTSP_NOTIFIER] YouTube video is actually live: $isActuallyLive');

            // Make sure to close the YoutubeExplode client
            yt.close();

            if (!isActuallyLive) {
              dev.log('❌ [RTSP_NOTIFIER] YouTube video is not a live stream: $videoId');

              // Return to previous state but mark as invalid
              if (previousState != null) {
                state = AsyncValue.data(
                  previousState.copyWith(
                    isInvalidUrl: true,
                    streamStatus: StreamStatus.error,
                    replaceWorkflow: false,
                  ),
                );

                // Schedule disposal after UI has updated
                Future.delayed(Duration(milliseconds: 100), () async {
                  await _dispose();
                });
              }

              throw InvalidRTSPURLException('This YouTube URL is not a live stream. Only live streams can be used.');
            }
          } catch (e) {
            dev.log('⚠️ [RTSP_NOTIFIER] Error checking if YouTube video is live: $e');

            // Return to previous state but mark as invalid
            if (previousState != null) {
              state = AsyncValue.data(
                previousState.copyWith(
                  isInvalidUrl: true,
                  streamStatus: StreamStatus.error,
                  replaceWorkflow: false,
                ),
              );

              // Schedule disposal after UI has updated
              Future.delayed(Duration(milliseconds: 100), () async {
                await _dispose();
              });
            }

            throw InvalidRTSPURLException('Unable to verify if YouTube video is a live stream: ${e.toString()}');
          }
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(RtspCameraStreamConstant.prefKeyEnabled, isEnabled);
      await prefs.setString(RtspCameraStreamConstant.prefKeyUrl, cleanUrl);

      // Save replaceWorkflow if provided or use existing value
      bool replaceWorkflowValue = replaceWorkflow;
      await prefs.setBool(RtspCameraStreamConstant.prefKeyReplaceWorkflow, replaceWorkflowValue);

      dev.log('💾 [RTSP_NOTIFIER] Saved settings to SharedPreferences');
      dev.log('📊 [RTSP_NOTIFIER] Stream settings - URL: $cleanUrl, ReplaceWorkflow: $replaceWorkflowValue');

      // Important: dispose controllers before updating state or creating new ones
      // Use a delayed microtask to ensure UI finishes with old controllers before disposing
      await Future.microtask(() async {
        await _dispose();
      });
      dev.log('🧹 [RTSP_NOTIFIER] Disposed controllers before creating new ones');

      // Explicitly set status to active while initializing to prevent false detections
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.copyWith(
            streamStatus: StreamStatus.active,
            // Clear controllers in state first to prevent UI from using old ones
            youtubeController: null,
            videoController: null,
          ),
        );
        dev.log('🔄 [RTSP_NOTIFIER] Updated state with active status');
      }

      // Allow UI to update before creating new controllers
      await Future.delayed(Duration(milliseconds: 50));

      // Handle YouTube URLs (including live streams)
      if (cleanUrl.contains('youtube.com') || cleanUrl.contains('youtu.be')) {
        dev.log('🎥 [RTSP_NOTIFIER] Initializing YouTube player');
        final newState = await _handleYoutubeStream(isEnabled, cleanUrl);
        if (state.hasValue) {
          // Ensure we're not keeping any references to old controllers
          state = AsyncValue.data(
            state.value!.copyWith(
              videoController: null,
              youtubeController: newState.youtubeController,
              streamType: StreamType.youtubeLive,
              streamUrl: cleanUrl,
              isInvalidUrl: false,
              replaceWorkflow: replaceWorkflowValue,
              streamStatus: StreamStatus.active, // Ensure status is active
            ),
          );
          dev.log('✅ [RTSP_NOTIFIER] Updated state with YouTube player');
        } else {
          state = AsyncValue.data(newState.copyWith(replaceWorkflow: replaceWorkflowValue));
        }
        return;
      }
      // Handle RTSP URLs
      else if (cleanUrl.startsWith('rtsp://')) {
        dev.log('🎬 [RTSP_NOTIFIER] Initializing RTSP player');
        final newState = await _handleRTSPStream(isEnabled, cleanUrl);
        if (state.hasValue) {
          // Ensure we're not keeping any references to old controllers
          state = AsyncValue.data(
            state.value!.copyWith(
              youtubeController: null,
              videoController: newState.videoController,
              streamType: StreamType.rtsp,
              streamUrl: cleanUrl,
              isInvalidUrl: false,
              replaceWorkflow: replaceWorkflowValue,
              streamStatus: StreamStatus.active, // Ensure status is active
            ),
          );
          dev.log('✅ [RTSP_NOTIFIER] Updated state with RTSP player');
        } else {
          state = AsyncValue.data(newState.copyWith(replaceWorkflow: replaceWorkflowValue));
        }
        return;
      }

      dev.log('❌ [RTSP_NOTIFIER] Invalid URL format: $cleanUrl');
      throw InvalidRTSPURLException('Invalid URL format: $cleanUrl');
    } catch (e, s) {
      // Clean up on error
      await _dispose();
      _stopStatusCheckTimer();
      dev.log('🚨 [RTSP_NOTIFIER] Error updating stream: $e');

      if (e is InvalidRTSPURLException || e is URLNotProvidedRTSPURLException) {
        // Preserve replaceWorkflow when handling URL errors
        bool replaceWorkflowValue = replaceWorkflow ?? state.value?.replaceWorkflow ?? false;
        state = AsyncValue.data(
          state.value!.copyWith(
            isInvalidUrl: true,
            videoController: null,
            youtubeController: null,
            replaceWorkflow: replaceWorkflowValue,
          ),
        );
        dev.log('⚠️ [RTSP_NOTIFIER] Updated state for invalid URL');
      } else {
        state = AsyncValue.error(e, s);
      }
    }
  }

  String? extractVideoId(String url) {
    dev.log('🔍 [RTSP_NOTIFIER] Extracting video ID from URL: $url');

    // Handle live URLs in the format youtube.com/live/VIDEO_ID
    if (url.contains('youtube.com/live/')) {
      try {
        final id = url.split('youtube.com/live/')[1].split('?').first;
        dev.log('✅ [RTSP_NOTIFIER] Extracted ID from live URL: $id');
        return id;
      } catch (e) {
        dev.log('⚠️ [RTSP_NOTIFIER] Error extracting ID from live URL: $e');
        // Fall through to standard extraction
      }
    }

    // Standard youtube URL extraction
    final regularId = YoutubePlayer.convertUrlToId(url);
    dev.log('🔍 [RTSP_NOTIFIER] Standard YouTube ID extraction result: $regularId');

    // If the URL format is different, try manual extraction
    if (regularId == null) {
      final uri = Uri.tryParse(url);
      if (uri != null && (uri.host == 'youtube.com' || uri.host == 'www.youtube.com')) {
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          if (pathSegments.contains('live')) {
            final liveIndex = pathSegments.indexOf('live');
            if (liveIndex < pathSegments.length - 1) {
              final potentialId = pathSegments[liveIndex + 1];
              dev.log('🔍 [RTSP_NOTIFIER] Manual extraction from pathSegments: $potentialId');
              return potentialId;
            }
          }
          // Try to find the ID in other path segments
          for (final segment in pathSegments) {
            if (segment.length > 8) {
              // Most YouTube IDs are longer than 8 chars
              dev.log('🔍 [RTSP_NOTIFIER] Trying path segment as ID: $segment');
              return segment;
            }
          }
        }
      }
    }

    return regularId;
  }

  Future<RTSPCameraSettingsState> _handleYoutubeStream(bool isEnabled, String url) async {
    try {
      dev.log('🎥 [RTSP_NOTIFIER] Handling YouTube stream for URL: $url');
      // Store previous controller before disposal
      final previousController = _youtubeController;

      // Don't dispose the controller immediately
      // We'll do it after building the new state

      final videoId = extractVideoId(url);
      if (videoId == null) {
        dev.log('❌ [RTSP_NOTIFIER] Could not extract video ID from URL: $url');
        throw InvalidRTSPURLException('URL is empty or invalid: $url');
      }

      dev.log('✅ [RTSP_NOTIFIER] Creating YouTube player with ID: $videoId');

      // Check if the video is actually live before proceeding
      bool isActuallyLive = false;
      try {
        final yt = YoutubeExplode();
        dev.log('🔍 [RTSP_NOTIFIER] Validating YouTube video with YoutubeExplode');
        // First check if the video exists and we can get its metadata
        final video = await yt.videos.get(videoId).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            dev.log('⏰ [RTSP_NOTIFIER] Timeout validating YouTube video');
            throw TimeoutException('Timed out attempting to validate YouTube video');
          },
        );

        // Check if the video is marked as a live stream
        isActuallyLive = video.isLive;
        dev.log('🎥 [RTSP_NOTIFIER] YouTube video is live: $isActuallyLive');

        // Close the YoutubeExplode client
        yt.close();

        // If it's not actually live, throw an exception to skip creating a player
        if (!isActuallyLive) {
          dev.log('❌ [RTSP_NOTIFIER] YouTube video is not a live stream: $videoId');
          throw InvalidRTSPURLException('This YouTube URL is not a live stream. Only live streams can be used.');
        }
      } catch (e) {
        dev.log('⚠️ [RTSP_NOTIFIER] Error checking if YouTube video is live: $e');
        // If we failed to determine if it's live, assume it's not
        throw InvalidRTSPURLException('Unable to verify if YouTube video is a live stream');
      }

      // Only now create the new controller
      // Always use the standard URL format for the player to maximize compatibility
      final standardUrl = 'https://www.youtube.com/watch?v=$videoId';

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
      dev.log('🎥 [RTSP_NOTIFIER] Created YouTube player controller');

      // Get the current replaceWorkflow value
      final prefs = await SharedPreferences.getInstance();
      final replaceWorkflow = prefs.getBool(RtspCameraStreamConstant.prefKeyReplaceWorkflow) ?? false;

      // Schedule disposal of previous controller after we've created new state
      if (previousController != null) {
        dev.log('🧹 [RTSP_NOTIFIER] Scheduling disposal of previous YouTube controller');
        Future.delayed(Duration(milliseconds: 100), () async {
          try {
            previousController.removeListener(() {});
            previousController.dispose();
            dev.log('✅ [RTSP_NOTIFIER] Disposed previous YouTube controller');
          } catch (e) {
            dev.log('⚠️ [RTSP_NOTIFIER] Error disposing previous YouTube controller: $e');
          }
        });
      }

      return RTSPCameraSettingsState(
        isRTSPEnabled: isEnabled,
        streamUrl: standardUrl,
        // Use the standard URL format
        isInvalidUrl: false,
        streamType: StreamType.youtubeLive,
        youtubeController: _youtubeController,
        replaceWorkflow: replaceWorkflow,
        streamStatus: StreamStatus.active,
      );
    } catch (e) {
      dev.log('🚨 [RTSP_NOTIFIER] Error handling YouTube stream: $e');

      // Return a state indicating the stream isn't valid or live
      // This will cause the app to fall back to normal workflow
      return RTSPCameraSettingsState(
        isRTSPEnabled: isEnabled,
        streamUrl: url,
        isInvalidUrl: true,
        streamStatus: StreamStatus.error,
        replaceWorkflow: false, // Force replaceWorkflow to false for non-live videos
      );
    }
  }

  Future<RTSPCameraSettingsState> _handleRTSPStream(bool isEnabled, String url) async {
    try {
      dev.log('🎬 [RTSP_NOTIFIER] Handling RTSP stream for URL: $url');
      // Ensure previous controllers are disposed
      await _dispose();

      _player = Player();
      _videoController = VideoController(_player!);
      await _player!.open(Media(url));
      dev.log('✅ [RTSP_NOTIFIER] Created and opened RTSP player');

      // Setup error and completion listeners
      _player!.stream.error.listen((error) {
        if (error.isNotEmpty) {
          dev.log('⚠️ [RTSP_NOTIFIER] RTSP stream error: $error');
          _handleStreamError(error);
        }
      });

      _player!.stream.completed.listen((completed) {
        if (completed) {
          dev.log('🏁 [RTSP_NOTIFIER] RTSP stream completed');
          _handleStreamEnded();
        }
      });

      // Get the current replaceWorkflow value
      final prefs = await SharedPreferences.getInstance();
      final replaceWorkflow = prefs.getBool(RtspCameraStreamConstant.prefKeyReplaceWorkflow) ?? false;

      return RTSPCameraSettingsState(
        isRTSPEnabled: isEnabled,
        streamUrl: url,
        streamType: StreamType.rtsp,
        isInvalidUrl: false,
        videoController: _videoController,
        replaceWorkflow: replaceWorkflow,
        streamStatus: StreamStatus.active,
      );
    } catch (e) {
      dev.log('🚨 [RTSP_NOTIFIER] Error handling RTSP stream: $e');
      await _dispose();
      throw RTSPStreamUpdateException(e.toString());
    }
  }

  Future<void> _handleStreamError(String error) async {
    dev.log('⚠️ [RTSP_NOTIFIER] Stream error detected: $error');

    // Update state to reflect error
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.copyWith(
          streamStatus: StreamStatus.error,
        ),
      );
      dev.log('🔄 [RTSP_NOTIFIER] Updated state for stream error');

      // If replaceWorkflow is enabled, disable it to return to normal workflow
      if (state.value!.replaceWorkflow) {
        dev.log('🔄 [RTSP_NOTIFIER] Disabling workflow replacement due to stream error');
        await toggleReplaceWorkflow(false);
      }
    }
  }

  Future<void> _handleStreamEnded() async {
    dev.log('🏁 [RTSP_NOTIFIER] Stream ended detected');

    // Update state to reflect ended stream
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.copyWith(
          streamStatus: StreamStatus.ended,
        ),
      );
      dev.log('🔄 [RTSP_NOTIFIER] Updated state for stream ended');

      // If replaceWorkflow is enabled, disable it to return to normal workflow
      if (state.value!.replaceWorkflow) {
        dev.log('🔄 [RTSP_NOTIFIER] Disabling workflow replacement due to stream ended');
        await toggleReplaceWorkflow(false);
      }
    }
  }

  void _updateStreamStatus(StreamStatus status) {
    if (state.hasValue && state.value!.streamStatus != status) {
      dev.log('🔄 [RTSP_NOTIFIER] Updating stream status to: $status');
      state = AsyncValue.data(
        state.value!.copyWith(
          streamStatus: status,
        ),
      );
    }
  }

  // Public method to update stream status from outside components
  void updateStreamStatus(StreamStatus status) {
    dev.log('🔄 [RTSP_NOTIFIER] Public update of stream status to: $status');
    _updateStreamStatus(status);
  }

  // Add this method to check stream status and update if needed
  Future<void> checkStreamStatus() async {
    if (!state.hasValue || !state.value!.isRTSPEnabled) {
      dev.log('ℹ️ [RTSP_NOTIFIER] Skipping stream status check - not enabled or no state');
      return;
    }

    final currentState = state.value!;

    if (currentState.streamType == StreamType.youtubeLive && currentState.youtubeController != null) {
      final playerValue = currentState.youtubeController!.value;
      final playerState = playerValue.playerState;

      // Only consider stream ended if player is fully initialized AND ended state
      if (playerValue.metaData.videoId.isNotEmpty && playerValue.isReady && playerState == PlayerState.ended) {
        dev.log('🏁 [RTSP_NOTIFIER] YouTube stream ended');
        await _handleStreamEnded();
      }
      // Handle errors with error code
      else if (playerValue.hasError || (playerValue.errorCode != 0)) {
        dev.log('⚠️ [RTSP_NOTIFIER] YouTube error detected: ${playerValue.errorCode}');
        await _handleStreamError('YouTube error: ${playerValue.errorCode}');
      }
      // If the player is playing, update status to active
      else if (playerState == PlayerState.playing) {
        dev.log('▶️ [RTSP_NOTIFIER] YouTube stream is playing');
        _updateStreamStatus(StreamStatus.active);
      }
    } else if (currentState.streamType == StreamType.rtsp && currentState.videoController != null) {
      try {
        // Check RTSP stream status
        final isPlaying = currentState.videoController!.player.state.playing;
        final hasError = await currentState.videoController!.player.stream.error.first.timeout(
          const Duration(seconds: 10),
          onTimeout: () => '',
        );

        if (hasError.isNotEmpty) {
          dev.log('⚠️ [RTSP_NOTIFIER] RTSP error detected');
          await _handleStreamError(hasError);
        } else if (!isPlaying) {
          // Check if stream is just paused or truly ended
          final isEnded = await currentState.videoController!.player.stream.completed.first.timeout(
            const Duration(seconds: 10),
            onTimeout: () => false,
          );

          if (isEnded) {
            dev.log('🏁 [RTSP_NOTIFIER] RTSP stream ended');
            await _handleStreamEnded();
          }
        }
      } catch (e) {
        dev.log('⚠️ [RTSP_NOTIFIER] Error checking RTSP stream status: $e');
      }
    }
  }

  // Add this method to pause/stop streams
  Future<void> pauseStreams() async {
    dev.log('⏸️ [RTSP_NOTIFIER] Pausing all streams');
    _youtubeController?.pause();
    await _player?.pause();
  }

  // Add this method to resume streams
  Future<void> resumeStreams() async {
    dev.log('▶️ [RTSP_NOTIFIER] Resuming all streams');
    _youtubeController?.play();
    await _player?.play();
  }

  Future<void> toggleReplaceWorkflow(bool replaceWorkflow) async {
    try {
      dev.log('🔄 '
          '[RTSP_NOTIFIER] Toggling workflow replacement: $replaceWorkflow');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(RtspCameraStreamConstant.prefKeyReplaceWorkflow, replaceWorkflow);

      final currentState = state.value;
      if (currentState != null) {
        // Update the state with the new replaceWorkflow value
        state = AsyncValue.data(
          currentState.copyWith(
            replaceWorkflow: replaceWorkflow,
            // Reset the stream status to active if we're enabling replacement
            streamStatus: replaceWorkflow ? StreamStatus.active : currentState.streamStatus,
          ),
        );
        dev.log('✅ [RTSP_NOTIFIER] Updated state with new workflow replacement value');

        // If replacing workflow and we have a stream, make sure it's playing
        if (replaceWorkflow) {
          dev.log('▶️ [RTSP_NOTIFIER] Resuming streams for workflow replacement');
          // Resume streams just in case
          await resumeStreams();

          // Force check the stream status
          await checkStreamStatus();
        }
      }
    } catch (e, s) {
      dev.log('🚨 [RTSP_NOTIFIER] Error toggling workflow replacement: $e');
      state = AsyncValue.error(RTSPToggleException(e.toString()), s);
    }
  }
}

final rtspCameraSettingsProvider =
    AutoDisposeAsyncNotifierProvider<RTSPCameraSettingsNotifier, RTSPCameraSettingsState>(() {
  return RTSPCameraSettingsNotifier();
});
