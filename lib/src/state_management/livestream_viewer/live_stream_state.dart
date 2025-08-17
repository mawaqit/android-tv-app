import 'package:equatable/equatable.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Enumeration of stream types supported by the livestream viewer
enum LiveStreamType { rtsp, youtubeLive }

/// Enumeration of stream statuses
enum LiveStreamStatus {
  idle,
  active,
  error,
  ended,
  connecting, // New status for when trying to reconnect
  unreliable, // New status for when stream quality is poor
}

/// State class for livestream viewer feature
class LiveStreamViewerState extends Equatable {
  /// Whether livestream is enabled
  final bool isEnabled;

  /// URL of the stream
  final String? streamUrl;

  /// Type of stream (RTSP or YouTube)
  final LiveStreamType? streamType;

  /// Controller for RTSP video8
  final VideoController? videoController;

  /// Controller for YouTube video
  final YoutubePlayerController? youtubeController;

  /// Whether URL is invalid
  final bool isInvalidUrl;

  /// Whether to replace the main workflow with the stream
  final bool replaceWorkflow;

  /// Whether workflow replacement should be automatic (based on stream status)
  final bool autoReplaceWorkflow;

  /// Current status of the stream
  final LiveStreamStatus streamStatus;

  /// Whether the workflow should currently be replaced (computed property)
  /// This considers both manual and automatic replacement modes
  bool get shouldReplaceWorkflow {
    // Stream must be enabled, active, and URL must be valid for any replacement
    if (!isEnabled || streamStatus != LiveStreamStatus.active || isInvalidUrl) {
      return false;
    }

    // In both auto and manual modes, respect the replaceWorkflow setting
    // This ensures that if user explicitly disables it, it stays disabled
    return replaceWorkflow;
  }

  const LiveStreamViewerState({
    this.isEnabled = false,
    this.streamUrl,
    this.streamType,
    this.videoController,
    this.youtubeController,
    this.isInvalidUrl = false,
    this.replaceWorkflow = false,
    this.autoReplaceWorkflow = true,
    this.streamStatus = LiveStreamStatus.idle,
  });

  /// Create a copy of this state with specified attributes replaced
  LiveStreamViewerState copyWith({
    bool? isEnabled,
    String? streamUrl,
    LiveStreamType? streamType,
    VideoController? videoController,
    YoutubePlayerController? youtubeController,
    bool? isInvalidUrl,
    bool? replaceWorkflow,
    bool? autoReplaceWorkflow,
    LiveStreamStatus? streamStatus,
  }) {
    return LiveStreamViewerState(
      isEnabled: isEnabled ?? this.isEnabled,
      streamUrl: streamUrl ?? this.streamUrl,
      streamType: streamType ?? this.streamType,
      videoController: videoController ?? this.videoController,
      youtubeController: youtubeController ?? this.youtubeController,
      isInvalidUrl: isInvalidUrl ?? this.isInvalidUrl,
      replaceWorkflow: replaceWorkflow ?? this.replaceWorkflow,
      autoReplaceWorkflow: autoReplaceWorkflow ?? this.autoReplaceWorkflow,
      streamStatus: streamStatus ?? this.streamStatus,
    );
  }

  @override
  List<Object?> get props => [
        isEnabled,
        streamUrl,
        streamType,
        isInvalidUrl,
        replaceWorkflow,
        autoReplaceWorkflow,
        streamStatus,
      ];

  @override
  String toString() {
    return 'LiveStreamViewerState{isEnabled: $isEnabled, streamUrl: $streamUrl, streamType: $streamType, videoController: $videoController, youtubeController: $youtubeController, isInvalidUrl: $isInvalidUrl, replaceWorkflow: $replaceWorkflow, autoReplaceWorkflow: $autoReplaceWorkflow, streamStatus: $streamStatus} \n\n';
  }
}
