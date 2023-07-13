import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

typedef DebugData = ({
  DateTime? startDate,
  DateTime? endDate,
  Duration? duration,
});

class WorkFlowItem {
  final Widget Function(BuildContext context, VoidCallback next) builder;

  /// this this item on the initial start of the workflow
  /// this used to calculate the first item to show in the workflow
  final bool skip;

  /// this is the duration of the item
  /// if you have this item make sure you don't use [builder] to call [next]
  final Duration? duration;
  final bool disabled;

  /// this is the duration of the item
  /// for debug purposes only
  final Duration? debugDuration;

  /// this is the minimum duration of the item
  /// if the item calls [next] before the minimum duration
  /// the item will wait for the minimum duration to finish
  final Duration? minimumDuration;

  WorkFlowItem({
    required this.builder,
    this.skip = false,
    this.duration,
    this.minimumDuration,
    this.debugDuration,
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
    this.debug = false,
  });

  final List<WorkFlowItem> workFlowItems;
  final void Function()? onDone;

  /// print each item specification in the console
  final bool debug;

  @override
  State<ContinuesWorkFlowWidget> createState() => _ContinuesWorkFlowWidgetState();
}

class _ContinuesWorkFlowWidgetState extends State<ContinuesWorkFlowWidget> {
  Future? minimumDurationFuture;
  int _currentItemIndex = 0;

  WorkFlowItem activeItem() => widget.workFlowItems[_currentItemIndex];

  getInitialItem() {
    for (var i = 0; i < widget.workFlowItems.length; i++) {
      final workflowItem = widget.workFlowItems[i];
      if (workflowItem.skip) continue;

      _currentItemIndex = i - 1;
      nextPage(_currentItemIndex);
      return;
    }
  }

  /// this function is called when the current item is done
  /// if the next page is fired from the child widget this widget should be ignored
  ///  [_currentItemIndex] is the current active index when this function is called
  nextPage(int _currentItemIndex) async {
    if (_currentItemIndex != this._currentItemIndex) return;

    /// if the widget removed from the tree
    /// no need for [nextPage]
    if (!mounted) return;

    if (_currentItemIndex >= widget.workFlowItems.length - 1) {
      /// we adding this delay to make sure flutter called the build function
      /// if flutter didn't called the build any navigation login inside the [ContinuesWorkFlowWidget.onDone] will be ignored
      Future.delayed(80.milliseconds, widget.onDone?.call);
      return;
    }
    if (minimumDurationFuture != null) await minimumDurationFuture;

    setState(() => this._currentItemIndex = _currentItemIndex + 1);

    if (activeItem().disabled) return nextPage(this._currentItemIndex);

    if (activeItem().minimumDuration != null) minimumDurationFuture = Future.delayed(activeItem().minimumDuration!);

    if (activeItem().duration != null) {
      Future.delayed(activeItem().duration!).then((value) {
        if (_currentItemIndex + 1 == this._currentItemIndex) nextPage(this._currentItemIndex);
      });
    }
  }

  ///
  void debugPrintItem() {
    var lastItemEndTime = context.read<MosqueManager>().mosqueDate();

    final items = widget.workFlowItems.map((workflowItem) {
      if (workflowItem.skip) {
        DebugData d = (
          startDate: lastItemEndTime,
          endDate: lastItemEndTime,
          duration: Duration(seconds: 0),
        );

        return d;
      }

      //
      DebugData d = (
        startDate: lastItemEndTime,
        endDate: lastItemEndTime = lastItemEndTime.add(
          workflowItem.duration ?? workflowItem.debugDuration ?? Duration.zero,
        ),
        duration: workflowItem.duration ?? workflowItem.debugDuration ?? Duration.zero,
      );
      return d;
    });

    logger.d({
      'active-index': _currentItemIndex,
      'current-time': context.read<MosqueManager>().mosqueDate(),
      'items': items.toList(),
    });
  }

  @override
  void initState() {
    getInitialItem();
    if (widget.debug) debugPrintItem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _itemIndex = _currentItemIndex;
    if (_currentItemIndex < 0) return Container(color: Colors.black);

    return activeItem().builder(context, () => nextPage(_itemIndex));
  }
}
