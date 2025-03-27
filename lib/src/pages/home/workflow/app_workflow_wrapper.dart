import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/pages/home/sub_screens/streaming_screen.dart';
import 'package:mawaqit/src/pages/home/workflow/app_workflow_screen.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_notifier.dart';

/// A wrapper widget that conditionally shows either the StreamingScreen or the AppWorkflowScreen
/// based on RTSP stream settings.
class AppWorkflowWrapper extends ConsumerWidget {
  const AppWorkflowWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rtspSettingsAsync = ref.watch(rtspCameraSettingsProvider);

    return rtspSettingsAsync.when(
      data: (rtspSettings) {
        // Check if RTSP or YouTube stream should replace the workflow
        final shouldReplaceWorkflow = rtspSettings.isRTSPEnabled &&
                                     rtspSettings.replaceWorkflow &&
                                     (rtspSettings.videoController != null ||
                                      rtspSettings.youtubeController != null);

        // Show StreamingScreen if conditions are met, otherwise show AppWorkflowScreen
        return shouldReplaceWorkflow
            ? const StreamingScreen()
            : const AppWorkflowScreen();
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const AppWorkflowScreen(),
    );
  }
}
