import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_notifier.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RTSPCameraSettingsState {
  final bool isInitialized;
  final bool isRTSPEnabled;
  final String? streamUrl;
  final StreamType? streamType;
  final VideoController? videoController;
  final YoutubePlayerController? youtubeController;
  final bool invalidStreamUrl;
  final bool isLoading;
  final bool showValidationSnackbar;

  const RTSPCameraSettingsState({
    this.isInitialized = false,
    this.isRTSPEnabled = false,
    this.streamUrl,
    this.streamType,
    this.videoController,
    this.youtubeController,
    this.invalidStreamUrl = false,
    this.isLoading = false,
    this.showValidationSnackbar = false,
  });

  RTSPCameraSettingsState copyWith({
    bool? isInitialized,
    bool? isRTSPEnabled,
    String? streamUrl,
    StreamType? streamType,
    VideoController? videoController,
    YoutubePlayerController? youtubeController,
    bool? invalidStreamUrl,
    bool? isLoading,
    bool? showValidationSnackbar,
  }) {
    return RTSPCameraSettingsState(
      isInitialized: isInitialized ?? this.isInitialized,
      isRTSPEnabled: isRTSPEnabled ?? this.isRTSPEnabled,
      streamUrl: streamUrl ?? this.streamUrl,
      streamType: streamType ?? this.streamType,
      videoController: videoController ?? this.videoController,
      youtubeController: youtubeController ?? this.youtubeController,
      invalidStreamUrl: invalidStreamUrl ?? this.invalidStreamUrl,
      isLoading: isLoading ?? this.isLoading,
      showValidationSnackbar: showValidationSnackbar ?? this.showValidationSnackbar,
    );
  }
}
