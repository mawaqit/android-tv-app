import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/state_management/device_info/device_info_notifier.dart';
import 'package:mawaqit/src/state_management/livestream_viewer/live_stream_notifier.dart';
import 'package:mawaqit/src/state_management/livestream_viewer/live_stream_state.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:mawaqit/src/widgets/MawaqitDrawer.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:sizer/sizer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:developer' as dev;

/// StreamReplacementScreen completely replaces the app workflow when the stream is active
/// This ensures that prayer schedules and other workflow activities don't affect the stream
class StreamReplacementScreen extends ConsumerWidget {
  const StreamReplacementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamState = ref.watch(liveStreamProvider);

    return streamState.when(
      data: (state) {
        if (!state.isEnabled || !state.replaceWorkflow) {
          return const SizedBox.shrink();
        }

        // Show black screen with message for connecting or unreliable status
        if (state.streamStatus == LiveStreamStatus.connecting || state.streamStatus == LiveStreamStatus.unreliable) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.streamStatus == LiveStreamStatus.connecting
                        ? 'Connecting to stream...'
                        : 'Stream quality is poor. Please wait...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show YouTube stream if available
        if (state.streamType == LiveStreamType.youtubeLive &&
            state.youtubeController != null &&
            state.streamStatus == LiveStreamStatus.active) {
          return _buildStreamUI(
            context,
            ref,
            YoutubePlayer(
              controller: state.youtubeController!,
              onEnded: (_) {
                ref.read(liveStreamProvider.notifier).updateStreamStatus(LiveStreamStatus.ended);
                ref.read(liveStreamProvider.notifier).toggleReplaceWorkflow(false);
              },
            ),
          );
        }

        // Show RTSP stream if available
        if (state.streamType == LiveStreamType.rtsp &&
            state.videoController != null &&
            state.streamStatus == LiveStreamStatus.active) {
          return _buildStreamUI(
            context,
            ref,
            Video(
              controller: state.videoController!,
              controls: null,
            ),
          );
        }

        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) {
        // Disable replacement workflow on error
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(liveStreamProvider.notifier).toggleReplaceWorkflow(false);
        });
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStreamUI(BuildContext context, WidgetRef ref, Widget streamWidget) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    final isBoxOrAndroidTV = ref.watch(deviceInfoProvider).maybeWhen(
          data: (value) => value.isBoxOrAndroidTV,
          orElse: () => false,
        );


    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.arrowRight) {
            scaffoldKey.currentState?.openDrawer();
          }
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.black,
        drawer: MawaqitDrawer(goHome: () => AppRouter.popAll()),
        body: Stack(
          children: [
            // Stream widget in the center with proper aspect ratio
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: streamWidget,
              ),
            ),
            !isBoxOrAndroidTV
                ?
                // Add hamburger menu to open drawer
                Align(
                    alignment: AlignmentDirectional.topStart,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () {
                          scaffoldKey.currentState?.openDrawer();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 8.w,
                            shadows: kHomeTextShadow,
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
            !isBoxOrAndroidTV
                ?
                // For top-start (will be top-left in LTR, top-right in RTL)
                Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(liveStreamProvider.notifier).toggleReplaceWorkflow(false);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 8.w,
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
