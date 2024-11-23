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

      if (isEnabled && savedUrl != null) {
        return await updateStream(isEnabled: isEnabled, url: savedUrl);
      }

      return RTSPCameraSettingsState(
        isRTSPEnabled: isEnabled,
        streamUrl: savedUrl,
      );
    } catch (e) {
      return RTSPCameraSettingsState(
        showValidationSnackbar: true,
      );
    }
  }

  Future<void> toggleEnabled(bool isEnabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(RtspCameraStreamConstant.prefKeyEnabled, isEnabled);

      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(
            isRTSPEnabled: isEnabled,
          ),
        );
      }
    } catch (e) {
      log('Error toggling RTSP camera: $e');
    }
  }

  String? extractVideoId(String url) {
    if (url.contains('youtube.com/live/')) {
      return url.split('youtube.com/live/')[1].split('?').first;
    }
    return YoutubePlayer.convertUrlToId(url);
  }

  Future<RTSPCameraSettingsState> updateStream({required bool isEnabled, required String url}) async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(RtspCameraStreamConstant.prefKeyEnabled, isEnabled);

      await prefs.setString(RtspCameraStreamConstant.prefKeyUrl, url);

      // Dispose existing controllers
      _youtubeController?.dispose();
      _player?.dispose();

      if (RtspCameraStreamConstant.youtubeUrlRegex.hasMatch(url)) {
        return await _handleYoutubeStream(isEnabled, url);
      } else if (url.startsWith('rtsp://')) {
        return await _handleRTSPStream(isEnabled, url);
      }

      // Invalid URL format
      final newState = RTSPCameraSettingsState(
        isRTSPEnabled: isEnabled,
        invalidStreamUrl: true,
        showValidationSnackbar: true,
      );

      state = AsyncValue.data(newState);
      return newState;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      throw RTSPStreamUpdateException(e.toString());
    }
  }

  Future<RTSPCameraSettingsState> _handleYoutubeStream(bool isEnabled, String url) async {
    final videoId = extractVideoId(url);
    if (videoId == null) {
      throw InvalidRTSPURLException(url);
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

    final newState = RTSPCameraSettingsState(
      isRTSPEnabled: isEnabled,
      streamUrl: url,
      streamType: StreamType.youtubeLive,
      youtubeController: _youtubeController,
      invalidStreamUrl: false,
      showValidationSnackbar: true,
    );

    state = AsyncValue.data(newState);
    return newState;
  }

  Future<RTSPCameraSettingsState> _handleRTSPStream(bool isEnabled, String url) async {
    _player = Player();
    _videoController = VideoController(_player!);
    await _player!.open(Media(url));

    final newState = RTSPCameraSettingsState(
      isRTSPEnabled: isEnabled,
      streamUrl: url,
      streamType: StreamType.rtsp,
      videoController: _videoController,
      showValidationSnackbar: true,
    );

    state = AsyncValue.data(newState);
    return newState;
  }

  Future<void> clearSnackBarFlag() async {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(showValidationSnackbar: false));
    }
  }
}

final rtspCameraSettingsProvider =
    AutoDisposeAsyncNotifierProvider<RTSPCameraSettingsNotifier, RTSPCameraSettingsState>(() {
  return RTSPCameraSettingsNotifier();
});
