import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/camera_stream_overlay_notifier.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_notifier.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class StreamOverlay extends ConsumerWidget {
  const StreamOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use Overlay instead of MaterialApp
    return Positioned.fill(
      child: Material(
        // Use a transparent background to show the overlay above the main app
        color: Colors.black.withOpacity(0.9),
        child: SafeArea(
          child: Stack(
            children: [
              // Stream view takes full screen
              _buildStreamView(ref),
              // Close button
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 32, // Make it more visible
                  ),
                  onPressed: () {
                    // Ensure we're using notifier.setOverlayActive correctly
                    final overlayNotifier =
                        ref.read(streamOverlaySettingsProvider.notifier);
                    overlayNotifier.setOverlayActive(false);

                    // For debugging - add a print statement to confirm the button is working
                    debugPrint('Close overlay button pressed');
                  },
                ),
              ),
              // Error and loading states should be centered
              _buildStatusIndicators(ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreamView(WidgetRef ref) {
    final streamState = ref.watch(rtspCameraSettingsProvider);

    return streamState.when(
      data: (state) {
        if (state.streamType == StreamType.youtubeLive &&
            state.youtubeController != null) {
          return Center(
            child: AspectRatio(
              aspectRatio: 16 / 9, // Adjust based on your needs
              child: YoutubePlayer(
                controller: state.youtubeController!,
                showVideoProgressIndicator: true,
                progressColors: const ProgressBarColors(
                  playedColor: Colors.red,
                  bufferedColor: Colors.white24,
                ),
              ),
            ),
          );
        }
        if (state.videoController != null) {
          return Center(
            child: AspectRatio(
              aspectRatio: 16 / 9, // Adjust based on your needs
              child: Video(controller: state.videoController!),
            ),
          );
        }
        return const Center(
          child: Text(
            'No stream available',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
      loading: () =>
          const SizedBox.shrink(), // Handled by _buildStatusIndicators
      error: (_, __) =>
          const SizedBox.shrink(), // Handled by _buildStatusIndicators
    );
  }

  Widget _buildStatusIndicators(WidgetRef ref) {
    final streamState = ref.watch(rtspCameraSettingsProvider);

    return streamState.when(
      data: (_) => const SizedBox.shrink(),
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading stream',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  error.toString(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
