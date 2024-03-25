import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/state_management/workflow/announcement_workflow.dart';
import 'package:mawaqit/src/state_management/workflow/workflow_notifier.dart';

class AnnouncementWorkFlowItem {
  final Widget Function(BuildContext) builder;
  final bool skip, disabled;
  final Duration? duration;

  AnnouncementWorkFlowItem({
    required this.builder,
    this.skip = false,
    this.duration,
    this.disabled = false,
  });
}

class AnnouncementContinuesWorkFlowWidget extends ConsumerStatefulWidget {
  final List<AnnouncementWorkFlowItem> workFlowItems;

  const AnnouncementContinuesWorkFlowWidget({
    Key? key,
    required this.workFlowItems,
  }) : super(key: key);

  @override
  createState() => _AnnouncementContinuesWorkFlowWidgetState();
}

class _AnnouncementContinuesWorkFlowWidgetState extends ConsumerState<AnnouncementContinuesWorkFlowWidget> {
  final PageController _pageController = PageController();
  List<AnnouncementWorkFlowItem> activeWorkFlowItems = [];
  Timer? _transitionTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    activeWorkFlowItems = widget.workFlowItems.where((item) => !item.skip && !item.disabled).toList();
    initiateItemTransition(); // Renamed for clarity
  }

  void initiateItemTransition() {
    final currentItem = activeWorkFlowItems[_currentIndex];
    if (currentItem.duration != null) {
      scheduleTransition(currentItem.duration!);
    }
  }

  void goToNextPage() {
    if (!mounted) return;
    int nextPageIndex = (_currentIndex + 1) % activeWorkFlowItems.length;
    // Check if the workflow is resetting back to the first index
    if (nextPageIndex == 0) {
      // Trigger the announcement workflow finished action
      ref.read(announcementWorkflowProvider.notifier).setAnnouncementWorkflowFinished();
    }

    _pageController.jumpToPage(nextPageIndex);
    if (!mounted) return;
    _currentIndex = nextPageIndex;
    initiateItemTransition();
    log('timer: announcement_timer: end: ${_transitionTimer.hashCode}');
  }

  void scheduleTransition(Duration duration) {
    cancelTransitionTimer();
    _transitionTimer = Timer(duration, goToNextPage);
    log('timer: announcement_timer: start: ${_transitionTimer.hashCode}');
  }

  void cancelTransitionTimer() {
    if (_transitionTimer == null) return;
    log('timer: announcement_timer: cancelled: ${_transitionTimer.hashCode}');
    _transitionTimer?.cancel();
    _transitionTimer = null;
  }

  @override
  void didUpdateWidget(covariant AnnouncementContinuesWorkFlowWidget oldWidget) {
    activeWorkFlowItems = widget.workFlowItems.where((item) => !item.skip && !item.disabled).toList();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(videoWorkflowProvider, (previous, next) {
      if (next.isVideoFinished) {
        goToNextPage();
        ref.read(videoWorkflowProvider.notifier).resetVideoFinished();
      }
    });
    return PageView.builder(
      controller: _pageController,
      itemCount: activeWorkFlowItems.length,
      physics: NeverScrollableScrollPhysics(), // Disable manual swiping
      itemBuilder: (context, index) {
        return activeWorkFlowItems[index].builder(context);
      },
    );
  }

  @override
  void dispose() {
    cancelTransitionTimer(); // Cancel the timer on dispose
    _pageController.dispose();
    log('timer: announcement_timer: end: ${_transitionTimer.hashCode}');
    super.dispose();
  }
}
