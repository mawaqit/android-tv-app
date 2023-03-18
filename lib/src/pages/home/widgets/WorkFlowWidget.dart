import 'package:flutter/material.dart';

class WorkFlowItem {
  final Widget Function(BuildContext context, VoidCallback next) builder;

  /// this this item on the initial start of the workflow
  /// this used to calculate the first item to show in the workflow
  final bool skip;

  /// this is the duration of the item
  /// if you have this item make sure you don't use [builder] to call [next]
  final Duration? duration;
  final bool disabled;

  /// this is the minimum duration of the item
  /// if the item calls [next] before the minimum duration
  /// the item will wait for the minimum duration to finish
  final Duration? minimumDuration;

  WorkFlowItem({
    required this.builder,
    this.skip = false,
    this.duration,
    this.minimumDuration,
    this.disabled = false,
  });
}

/// this widget is used to show a workflow of screens
/// can handle only continuous workflows like the salah workflow
class ContinuesWorkFlowWidget extends StatefulWidget {
  const ContinuesWorkFlowWidget({
    super.key,
    required this.workFlowItems,
    this.onDone,
  });

  final List<WorkFlowItem> workFlowItems;
  final void Function()? onDone;

  @override
  State<ContinuesWorkFlowWidget> createState() =>
      _ContinuesWorkFlowWidgetState();
}

class _ContinuesWorkFlowWidgetState extends State<ContinuesWorkFlowWidget> {
  Future? minimumDurationFuture;
  int _currentItemIndex = 0;

  /// this used to ignore the automatic next page call
  /// if user called it manually from the builder child widget
  Future? delayedNextPageFuture;

  WorkFlowItem activeItem() => widget.workFlowItems[_currentItemIndex];

  getInitialItem() {
    for (var i = 0; i < widget.workFlowItems.length; i++) {
      final workflowItem = widget.workFlowItems[i];
      if (workflowItem.skip) continue;

      _currentItemIndex = i - 1;
      nextPage();
      return;
    }
  }

  /// this function is called when the current item is done
  /// if the next page is fired from the child widget this widget should be ignored
  nextPage() async {
    print('running next page $_currentItemIndex');
    delayedNextPageFuture?.ignore();
    print('running next page $_currentItemIndex');

    if (_currentItemIndex >= widget.workFlowItems.length - 1) {
      widget.onDone?.call();
      return;
    }
    if (minimumDurationFuture != null) await minimumDurationFuture;

    setState(() => _currentItemIndex++);

    if (activeItem().disabled) return nextPage();

    if (activeItem().minimumDuration != null)
      minimumDurationFuture = Future.delayed(activeItem().minimumDuration!);

    if (activeItem().duration != null) {
      delayedNextPageFuture = Future.delayed(activeItem().duration!);
      delayedNextPageFuture?.then((_) => nextPage());
    }
  }

  @override
  void initState() {
    getInitialItem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentItemIndex < 0) return Container();
    return activeItem().builder(context, nextPage);
  }
}
