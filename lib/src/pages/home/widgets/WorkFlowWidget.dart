import 'package:flutter/material.dart';

class WorkFlowItem {
  final Widget Function(BuildContext context, VoidCallback next) builder;

  /// this this item on the initial start of the workflow
  /// this used to calculate the first item to show in the workflow
  final bool skip;
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

  WorkFlowItem activeItem() {
    return widget.workFlowItems[_currentItemIndex];
  }

  getInitialItem() {
    for (var i = 0; i < widget.workFlowItems.length; i++) {
      final workflowItem = widget.workFlowItems[i];
      if (workflowItem.skip) continue;

      _currentItemIndex = i - 1;
      nextPage();
      return;
    }
  }

  nextPage() async {
    if (_currentItemIndex >= widget.workFlowItems.length - 1) {
      widget.onDone?.call();
      return;
    }

    _currentItemIndex++;

    if (activeItem().disabled) return nextPage();

    if (minimumDurationFuture != null) await minimumDurationFuture;

    setState(() {
      if (activeItem().minimumDuration != null)
        minimumDurationFuture = Future.delayed(activeItem().minimumDuration!);
    });

    if (activeItem().duration != null)
      Future.delayed(activeItem().duration!, nextPage);
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
