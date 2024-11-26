import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/error/rtsp_expceptions.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_state.dart';
import 'package:media_kit/media_kit.dart';
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

  Future<void> dispose() async {
    _youtubeController?.dispose();
    await _player?.dispose();
    await _videoController?.player.dispose();
  }

  @override
  Future<RTSPCameraSettingsState> build() async {
    ref.onDispose(() async {
      await dispose();
    });

    return await initializeSettings();
  }

  Future<RTSPCameraSettingsState> initializeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(RtspCameraStreamConstant.prefKeyEnabled) ?? false;
      final savedUrl = prefs.getString(RtspCameraStreamConstant.prefKeyUrl);
      if (!isEnabled || savedUrl == null || savedUrl.isEmpty) {
        return RTSPCameraSettingsState(
          isRTSPEnabled: isEnabled,
          streamUrl: savedUrl,
          isInvalidUrl: false,
        );
      }
      return await _initializeFromSavedUrl(isEnabled: isEnabled, url: savedUrl);
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
        }
        state = AsyncValue.data(
          currentState.copyWith(
            isRTSPEnabled: isEnabled,
            isInvalidUrl: false,
          ),
        );

        if (isEnabled && currentState.streamUrl != null) {
          await updateStream(isEnabled: isEnabled, url: currentState.streamUrl ?? '');
          await resumeStreams();
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

      // Handle YouTube URLs (including live streams)
      if (RtspCameraStreamConstant.youtubeUrlRegex.hasMatch(url)) {
        final newState = await _handleYoutubeStream(isEnabled, url);
        state = AsyncValue.data(newState);
        return;
      }
      // Handle RTSP URLs
      else if (url.startsWith('rtsp://')) {
        final newState = await _handleRTSPStream(isEnabled, url);
        state = AsyncValue.data(newState);
        return;
      }

      throw InvalidRTSPURLException('Invalid URL format: $url');
    } catch (e, s) {
      if (e is InvalidRTSPURLException || e is URLNotProvidedRTSPURLException) {
        state = AsyncValue.data(
          state.value!.copyWith(
            isInvalidUrl: true,
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

  Future<RTSPCameraSettingsState> _handleYoutubeStream(bool isEnabled, String url) async {
    try {
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
      throw YouTubeVideoIdExtractionException(e.toString());
    }
  }

  Future<RTSPCameraSettingsState> _handleRTSPStream(bool isEnabled, String url) async {
    try {
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

final rtspCameraSettingsProvider =
    AutoDisposeAsyncNotifierProvider<RTSPCameraSettingsNotifier, RTSPCameraSettingsState>(() {
  return RTSPCameraSettingsNotifier();
});
