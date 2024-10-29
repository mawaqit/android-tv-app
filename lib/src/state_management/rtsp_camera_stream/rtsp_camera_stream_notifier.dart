import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_state.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RtspCameraStreamNotifier extends AsyncNotifier<RtspCameraStreamState> {
  late final Player _player;
  late final VideoController _videoController;
  late final SharedPreferences _prefs;

  VideoController get videoController => _videoController;

  @override
  Future<RtspCameraStreamState> build() async {
    _player = Player();
    _videoController = VideoController(_player);
    _prefs = await SharedPreferences.getInstance();
    return await _loadInitialState();
  }

  Future<RtspCameraStreamState> _loadInitialState() async {
    try {
      final isRTSPEnabled = _prefs.getBool(RtspCameraStreamConstant.kRtspEnabledKey) ?? false;
      final rtspUrl = _prefs.getString(RtspCameraStreamConstant.kRtspUrlKey);

      if (isRTSPEnabled && rtspUrl != null && rtspUrl.isNotEmpty) {
        return await _initializeRtspPlayer(
          RtspCameraStreamState(
            isRTSPEnabled: isRTSPEnabled,
            rtspUrl: rtspUrl,
            isRTSPInitialized: false,
            invalidRTSPUrl: false,
            invalidStreamUrl: false,
            retryCount: 0,
          ),
        );
      }

      return RtspCameraStreamState(
        isRTSPEnabled: isRTSPEnabled,
        rtspUrl: rtspUrl,
        isRTSPInitialized: false,
        invalidRTSPUrl: true,
        invalidStreamUrl: true,
        retryCount: 0,
      );
    } catch (e) {
      return RtspCameraStreamState(
        isRTSPEnabled: false,
        rtspUrl: null,
        isRTSPInitialized: false,
        invalidRTSPUrl: true,
        invalidStreamUrl: true,
        retryCount: 0,
      );
    }
  }

  Future<void> updateStream({
    required bool isEnabled,
    String? url,
  }) async {
    state = const AsyncLoading();
    await _player.stop();

    await _prefs.setBool(RtspCameraStreamConstant.kRtspEnabledKey, isEnabled);
    if (url != null) {
      await _prefs.setString(RtspCameraStreamConstant.kRtspUrlKey, url);
    }

    if (isEnabled && url != null && url.isNotEmpty) {
      state = AsyncData(await _initializeRtspPlayer(
        RtspCameraStreamState(
          isRTSPEnabled: isEnabled,
          rtspUrl: url,
          isRTSPInitialized: false,
          invalidRTSPUrl: false,
          invalidStreamUrl: false,
          retryCount: 0,
        ),
      ));
    } else {
      state = AsyncData(RtspCameraStreamState(
        isRTSPEnabled: isEnabled,
        rtspUrl: url,
        isRTSPInitialized: false,
        invalidRTSPUrl: true,
        invalidStreamUrl: true,
        retryCount: 0,
      ));
    }
  }

  Future<RtspCameraStreamState> _initializeRtspPlayer(
    RtspCameraStreamState currentState,
  ) async {
    try {
      await _player.open(Media(currentState.rtspUrl!));
      return currentState.copyWith(
        isRTSPInitialized: true,
        invalidRTSPUrl: false,
        invalidStreamUrl: false,
      );
    } catch (e) {
      return await _handleInitializationError(currentState);
    }
  }

  Future<RtspCameraStreamState> _handleInitializationError(
    RtspCameraStreamState currentState,
  ) async {
    if (currentState.retryCount < RtspCameraStreamConstant.kMaxRetries) {
      await Future.delayed(const Duration(seconds: 2));
      return _initializeRtspPlayer(
        currentState.copyWith(
          retryCount: currentState.retryCount + 1,
        ),
      );
    }

    return currentState.copyWith(
      invalidRTSPUrl: true,
      invalidStreamUrl: true,
      isRTSPInitialized: false,
    );
  }
}

final rtspCameraStreamProvider = AsyncNotifierProvider<RtspCameraStreamNotifier, RtspCameraStreamState>(
  () => RtspCameraStreamNotifier(),
);
