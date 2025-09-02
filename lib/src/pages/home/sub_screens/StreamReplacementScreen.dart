import 'dart:developer' as dev;
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

/// StreamReplacementScreen completely replaces the app workflow when the stream is active
/// This ensures that prayer schedules and other workflow activities don't affect the stream
class StreamReplacementScreen extends ConsumerStatefulWidget {
  const StreamReplacementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StreamReplacementScreen> createState() => _StreamReplacementScreenState();
}

class _StreamReplacementScreenState extends ConsumerState<StreamReplacementScreen> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamState = ref.watch(liveStreamProvider);

    return streamState.when(
      data: (state) {
        if (!state.shouldReplaceWorkflow) {
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
          try {
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
          } catch (e) {
            // Controller might be disposed, return empty
            return const SizedBox.shrink();
          }
        }

        // Show RTSP stream if available
        if (state.streamType == LiveStreamType.rtsp &&
            state.videoController != null &&
            state.streamStatus == LiveStreamStatus.active) {
          try {
            return _buildStreamUI(
              context,
              ref,
              Video(
                controller: state.videoController!,
                controls: null,
              ),
            );
          } catch (e) {
            // Controller might be disposed, return empty
            return const SizedBox.shrink();
          }
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

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.arrowRight) {
            scaffoldKey.currentState?.openDrawer();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
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
            // Only show touch controls on non-TV devices
/*             if (!isBoxOrAndroidTV) ...[
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
              ),
              // Close button
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
              ),
            ], */
          ],
        ),
      ),
    );
  }
}
