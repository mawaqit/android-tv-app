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
  ended
}

/// State class for livestream viewer feature
class LiveStreamViewerState extends Equatable {
  /// Whether livestream is enabled
  final bool isEnabled;
  
  /// URL of the stream
  final String? streamUrl;
  
  /// Type of stream (RTSP or YouTube)
  final LiveStreamType? streamType;
  
  /// Controller for RTSP video
  final VideoController? videoController;
  
  /// Controller for YouTube video
  final YoutubePlayerController? youtubeController;
  
  /// Whether URL is invalid
  final bool isInvalidUrl;
  
  /// Whether to replace the main workflow with the stream
  final bool replaceWorkflow;
  
  /// Current status of the stream
  final LiveStreamStatus streamStatus;

  const LiveStreamViewerState({
    this.isEnabled = false,
    this.streamUrl,
    this.streamType,
    this.videoController,
    this.youtubeController,
    this.isInvalidUrl = false,
    this.replaceWorkflow = false,
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
      streamStatus: streamStatus ?? this.streamStatus,
    );
  }

  @override
  List<Object?> get props => [
    isEnabled,
    streamUrl,
    streamType,
    // Skip controllers in equality check since they're not equatable
    isInvalidUrl,
    replaceWorkflow,
    streamStatus,
  ];
} 