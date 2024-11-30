import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_notifier.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RTSPCameraSettingsState extends Equatable {
  final bool isRTSPEnabled;
  final String? streamUrl;
  final StreamType? streamType;
  final VideoController? videoController;
  final YoutubePlayerController? youtubeController;
  final bool isInvalidUrl;

  const RTSPCameraSettingsState({
    this.isRTSPEnabled = false,
    this.streamUrl,
    this.streamType,
    this.videoController,
    this.youtubeController,
    this.isInvalidUrl = false,
  });

  RTSPCameraSettingsState copyWith({
    bool? isRTSPEnabled,
    String? streamUrl,
    StreamType? streamType,
    VideoController? videoController,
    YoutubePlayerController? youtubeController,
    bool? invalidStreamUrl,
    bool? showValidationSnackbar,
    bool? isInvalidUrl,
  }) {
    return RTSPCameraSettingsState(
      isRTSPEnabled: isRTSPEnabled ?? this.isRTSPEnabled,
      streamUrl: streamUrl ?? this.streamUrl,
      streamType: streamType ?? this.streamType,
      videoController: videoController ?? this.videoController,
      youtubeController: youtubeController ?? this.youtubeController,
      isInvalidUrl: isInvalidUrl ?? this.isInvalidUrl,
    );
  }

  @override
  String toString() {
    return 'RTSPCameraSettingsState(isRTSPEnabled: $isRTSPEnabled, streamUrl: $streamUrl, streamType: $streamType, videoController: $videoController, youtubeController: $youtubeController, isInvalidUrl: $isInvalidUrl)';
  }

  @override
  List<Object?> get props {
    return [
      isRTSPEnabled,
      streamUrl,
      streamType,
      videoController,
      youtubeController,
      isInvalidUrl,
    ];
  }
}
