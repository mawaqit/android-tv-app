import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_state.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

enum StreamType { rtsp, youtubeLive }

class RTSPCameraSettingsNotifier extends AutoDisposeAsyncNotifier<RTSPCameraSettingsState> {
  @override
  Future<RTSPCameraSettingsState> build() async {
    return await initializeSettings();
  }

  Future<RTSPCameraSettingsState> initializeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('rtsp_camera_enabled') ?? false;
      final savedUrl = prefs.getString('rtsp_camera_url');

      if (isEnabled && savedUrl != null) {
        return await updateStream(isEnabled: isEnabled, url: savedUrl);
      }

      return RTSPCameraSettingsState(
        isInitialized: true,
        isRTSPEnabled: isEnabled,
        streamUrl: savedUrl,
        isLoading: false,
      );
    } catch (e) {
      return RTSPCameraSettingsState(
        isInitialized: true,
        isLoading: false,
        showValidationSnackbar: true,
      );
    }
  }

  String? extractVideoId(String url) {
    if (url.contains('youtube.com/live/')) {
      return url.split('youtube.com/live/')[1].split('?').first;
    }
    return YoutubePlayer.convertUrlToId(url);
  }

  Future<RTSPCameraSettingsState> updateStream({required bool isEnabled, String? url}) async {
    if (url != null) {
      state = const AsyncValue.loading();
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rtsp_camera_enabled', isEnabled);
      state = AsyncValue.data(RTSPCameraSettingsState(
        isRTSPEnabled: isEnabled,
        streamUrl: url ?? state.value?.streamUrl,
        isLoading: url != null,
        isInitialized: true,
      ));
      if (url == null) {
        return state.value!;
      }

      await prefs.setString('rtsp_camera_url', url);

      if (RtspCameraStreamConstant.youtubeUrlRegex.hasMatch(url)) {
        final videoId = extractVideoId(url);
        if (videoId == null) {
          return RTSPCameraSettingsState(
            isRTSPEnabled: isEnabled,
            invalidStreamUrl: true,
            isLoading: false,
            showValidationSnackbar: true,
          );
        }

        final controller = YoutubePlayerController(
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
          streamType: StreamType.youtubeLive,
          youtubeController: controller,
          invalidStreamUrl: false,
          isLoading: false,
          showValidationSnackbar: true,
        );
      } else if (url.startsWith('rtsp://')) {
        final player = Player();
        final controller = VideoController(player);
        await player.open(Media(url));

        return RTSPCameraSettingsState(
          isRTSPEnabled: isEnabled,
          streamUrl: url,
          streamType: StreamType.rtsp,
          videoController: controller,
          invalidStreamUrl: false,
          isLoading: false,
          showValidationSnackbar: true,
        );
      }

      return RTSPCameraSettingsState(
        isRTSPEnabled: isEnabled,
        invalidStreamUrl: true,
        isLoading: false,
        showValidationSnackbar: true,
      );
    } catch (e) {
      return RTSPCameraSettingsState(
        invalidStreamUrl: true,
        isLoading: false,
        showValidationSnackbar: true,
      );
    }
  }

  Future<void> clearSnackbarFlag() async {
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
