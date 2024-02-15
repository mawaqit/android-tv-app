import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/state_management/workflow/workflow_notifier.dart';

/// [AnnouncementWorkFlowItem] is a class that represents an item in the announcement workflow.
///
/// It is used to define the content of the announcement workflow and the behavior of each item.
class AnnouncementWorkFlowItem {

  /// [builder] A function that returns a widget to display for this announcement item.
  final Widget Function(BuildContext) builder;

  /// [skip] Indicates whether this item should be skipped in the workflow. Defaults to `false`.
  final bool skip, disabled;

  /// [duration] Specifies how long this item should be displayed before automatically proceeding to the next item.
  /// If `null`, the item does not automatically advance, requiring manual intervention to proceed.
  /// It is set to `null` for video announcement workflow item.
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
  int  _currentIndex = 0;
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
    _pageController
        .animateToPage(
      nextPageIndex,
      duration: const Duration(microseconds: 1), // Adjust duration as needed
      curve: Curves.easeInOut,
    )
        .then((_) {
      if (!mounted) return;
      setState(() {
        _currentIndex = nextPageIndex;
      });
      initiateItemTransition(); // Prepare the next item (whether it's timed or needs an external trigger)
    });
  }

  void scheduleTransition(Duration duration) {
    _transitionTimer?.cancel(); // Cancel any existing timer
    _transitionTimer = Timer(duration, goToNextPage);
  }
  @override
  void didUpdateWidget(covariant AnnouncementContinuesWorkFlowWidget oldWidget) {
    activeWorkFlowItems = widget.workFlowItems.where((item) => !item.skip && !item.disabled).toList();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(videoWorkflowProvider, (previous, next) {
      if(next.isVideoFinished){
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
    _transitionTimer?.cancel(); // Ensure the timer is cancelled on dispose
    _pageController.dispose();
    super.dispose();
  }
}
