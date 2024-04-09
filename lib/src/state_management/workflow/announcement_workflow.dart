import 'package:flutter_riverpod/flutter_riverpod.dart';

enum WorkflowState {
  idle,
  running,
  paused,
  finished,
}

class AnnouncementWorkflowNotifier extends AutoDisposeNotifier<WorkflowState> {
  @override
  WorkflowState build() {
    return WorkflowState.idle;
  }

  void setAnnouncementWorkflowFinished() {
    state = WorkflowState.finished;
  }

  void resetAnnouncementWorkflowFinished() {
    state = WorkflowState.idle;
  }
}

final announcementWorkflowProvider =
    AutoDisposeNotifierProvider<AnnouncementWorkflowNotifier, WorkflowState>(AnnouncementWorkflowNotifier.new);
