import 'package:equatable/equatable.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

enum StreamType { rtsp, youtubeLive, unknown }

class RtspCameraStreamState extends Equatable {
  final bool isRTSPEnabled;
  final String? streamUrl;
  final bool isStreamInitialized;
  final bool invalidStreamUrl;
  final StreamType streamType;
  final int retryCount;
  final YoutubePlayerController? youtubeController;

  const RtspCameraStreamState({
    required this.isRTSPEnabled,
    this.streamUrl,
    required this.isStreamInitialized,
    required this.invalidStreamUrl,
    required this.streamType,
    required this.retryCount,
    this.youtubeController,
  });

  RtspCameraStreamState copyWith({
    bool? isRTSPEnabled,
    String? streamUrl,
    bool? isStreamInitialized,
    bool? invalidStreamUrl,
    StreamType? streamType,
    int? retryCount,
    YoutubePlayerController? youtubeController,
  }) {
    return RtspCameraStreamState(
      isRTSPEnabled: isRTSPEnabled ?? this.isRTSPEnabled,
      streamUrl: streamUrl ?? this.streamUrl,
      isStreamInitialized: isStreamInitialized ?? this.isStreamInitialized,
      invalidStreamUrl: invalidStreamUrl ?? this.invalidStreamUrl,
      streamType: streamType ?? this.streamType,
      retryCount: retryCount ?? this.retryCount,
      youtubeController: youtubeController ?? this.youtubeController,
    );
  }

  @override
  List<Object?> get props => [
        isRTSPEnabled,
        streamUrl,
        isStreamInitialized,
        invalidStreamUrl,
        streamType,
        retryCount,
        youtubeController,
      ];

  factory RtspCameraStreamState.initial() => const RtspCameraStreamState(
        isRTSPEnabled: false,
        isStreamInitialized: false,
        invalidStreamUrl: false,
        streamType: StreamType.unknown,
        retryCount: 0,
      );
}
