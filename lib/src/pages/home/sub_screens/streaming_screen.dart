import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_notifier.dart';

/// A screen to display when streaming is active
/// This component handles showing RTSP or YouTube streaming content
class StreamingScreen extends ConsumerStatefulWidget {
  const StreamingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StreamingScreen> createState() => _StreamingScreenState();
}

class _StreamingScreenState extends ConsumerState<StreamingScreen> {
  @override
  void initState() {
    super.initState();
    // Setup listeners for stream state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupStreamListeners();
    });
  }

  void _setupStreamListeners() {
    final streamState = ref.read(rtspCameraSettingsProvider).value;

    // Setup YouTube stream state listener
    if (streamState?.youtubeController != null) {
      streamState!.youtubeController!.addListener(() {
        final playerState = streamState.youtubeController!.value.playerState;
        if (playerState == PlayerState.ended || playerState == PlayerState.unknown) {
          // Stream has ended or encountered an error, return to regular workflow
          if (streamState.replaceWorkflow) {
            ref.read(rtspCameraSettingsProvider.notifier).toggleReplaceWorkflow(false);
          }
        }
      });
    }

    // Setup RTSP stream state listener
    if (streamState?.videoController != null) {
      streamState!.videoController!.player.stream.completed.listen((completed) {
        if (completed) {
          // Stream has completed, return to regular workflow
          if (streamState.replaceWorkflow) {
            ref.read(rtspCameraSettingsProvider.notifier).toggleReplaceWorkflow(false);
          }
        }
      });

      // Listen for playback errors
      streamState.videoController!.player.stream.error.listen((error) {
        if (error.isNotEmpty && streamState.replaceWorkflow) {
          ref.read(rtspCameraSettingsProvider.notifier).toggleReplaceWorkflow(false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final streamStateAsync = ref.watch(rtspCameraSettingsProvider);

    return streamStateAsync.when(
      data: (streamState) {
        // Check if RTSP stream is configured
        final isRTSPWorking = streamState.isRTSPEnabled &&
            streamState.streamType == StreamType.rtsp &&
            streamState.videoController != null;

        // Check if YouTube stream is configured
        final isYouTubeWorking = streamState.isRTSPEnabled &&
            streamState.streamType == StreamType.youtubeLive &&
            streamState.youtubeController != null;

        // Priority 1: RTSP Stream if working
        if (isRTSPWorking) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Video(
                  controller: streamState.videoController!,
                ),
              ),
            ),
          );
        }

        // Priority 2: YouTube Stream if working
        if (isYouTubeWorking) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  controller: streamState.youtubeController!,
                ),
              ),
            ),
          );
        }

        // Fallback - should not happen since this screen should only be shown when streaming is active
        return const Scaffold(backgroundColor: Colors.black);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (_, __) => const Scaffold(backgroundColor: Colors.black),
    );
  }
}
