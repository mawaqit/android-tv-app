import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'video_workflow_state.dart';

/// [VideoWorkflowNotifier] manages the state related to video playback in a workflow.
/// It uses [VideoWorkflowState] to track whether a video has finished playing.
class VideoWorkflowNotifier extends Notifier<VideoWorkflowState> {
  @override
  VideoWorkflowState build() {
    return VideoWorkflowState(false);
  }

  /// [startVideoFinished] Updates the state to reflect whether the video is finished.
  void setVideoFinished() {
    state = VideoWorkflowState(true);
  }

  /// [resetVideoFinished] Resets the video finished state back to false, indicating that the video.
  ///
  /// is resting for next start.
  void resetVideoFinished() {
    state = VideoWorkflowState(false);
  }
}

// Define a provider for the WorkflowNotifier
final videoWorkflowProvider = NotifierProvider<VideoWorkflowNotifier, VideoWorkflowState>(VideoWorkflowNotifier.new);
