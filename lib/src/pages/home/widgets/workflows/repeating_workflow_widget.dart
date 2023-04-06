import 'package:flutter/material.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

class RepeatingWorkflowItem {
  /// this item starting time
  /// if not set will use the initState time
  final DateTime? dateTime;

  /// this item ending time
  /// if set the item will be in that time
  /// this can be used instead of [duration] in case need to in specific time
  final DateTime? endTime;

  /// if set the item will be repeated every [repeatingDuration]
  /// starting count for duration after item done
  final Duration? repeatingDuration;

  /// item builder function
  final Widget Function(BuildContext context, VoidCallback next) builder;

  /// this item is disabled and will not be shown
  final bool disabled;

  /// if set this item will override any other item
  /// if not set this item trigger will be only if there are no any other active item
  /// repeating will be ste
  final bool forceStart;

  /// minimum duration for this item
  /// if the item calls [next] before the minimum duration
  /// the item will wait for the minimum duration to finish
  final Duration? minimumDuration;

  /// this is the duration of the item
  /// automatically calls [next] after the duration
  final Duration? duration;

  /// if set will be shown as the initial item if the function return true
  /// first item on the list has higher priority
  final bool Function()? showInitial;

  RepeatingWorkflowItem({
    required this.builder,
    this.disabled = false,
    this.forceStart = false,
    this.endTime,
    this.dateTime,
    this.repeatingDuration,
    this.minimumDuration,
    this.duration,
    this.showInitial,
  });
}

/// handle workflows that its item isn't shown one after another
/// TODO: This will be used in the future to handle the active workflow
/// TODO: this will be used to handle the normal workflow transitions
class RepeatingWorkFlowWidget extends StatefulWidget {
  const RepeatingWorkFlowWidget({Key? key, this.child, this.items = const []}) : super(key: key);

  /// main child if there are no active child
  final Widget? child;

  /// items that will show in the workflow
  final List<RepeatingWorkflowItem> items;

  @override
  State<RepeatingWorkFlowWidget> createState() => _RepeatingWorkFlowWidgetState();
}

class _RepeatingWorkFlowWidgetState extends State<RepeatingWorkFlowWidget> {
  late final DateTime startDate;
  late final MosqueManager mosqueManager;

  /// used to handle the minimum duration if set for the item
  Future? minimumDurationFuture;

  /// if set to null use [child]
  int? activeItem;

  @override
  void initState() {
    super.initState();
    mosqueManager = context.read<MosqueManager>();
    startDate = mosqueManager.mosqueDate();
    checkInitialItem();
  }

  /// check if there are any initial item and start it
  checkInitialItem() {
    for (var i = 0; i < widget.items.length; i++) {
      if (widget.items[i].showInitial?.call() ?? false) {
        startItem(i);
        return;
      }
    }
    addNextItemHandled();
  }

  /// active item with index
  startItem(int itemIndex) {
    final item = widget.items[itemIndex];

    if (item.disabled) return;

    /// if there are active item and the item isn't forced to start will do nothing
    if (activeItem != null && !item.forceStart) return;

    setState(() => activeItem = itemIndex);

    /// set the minimum duration if set
    minimumDurationFuture = item.minimumDuration != null ? Future.delayed(item.minimumDuration!) : null;

    if (nextEndTimeDuration(item) != null) {
      /// if the item has end time

      Future.delayed(nextEndTimeDuration(item)!, () => onItemDone(itemIndex));
    } else if (item.duration != null) {
      /// if the item has duration
      Future.delayed(item.duration!, () => onItemDone(itemIndex));
    }
  }

  /// called when the item is done from the item builder or after the duration
  /// if the [itemIndex] isn't equal to the [activeItem] will do nothing
  onItemDone(int itemIndex) async {
    print('onItemDone: $itemIndex');
    if (itemIndex != activeItem) return;

    if (minimumDurationFuture != null) await minimumDurationFuture;

    setState(() {
      activeItem = null;

      /// check if there are any other active item
      addNextItemHandled();
    });
  }

  /// add trigger for the next item upcoming item on the list
  addNextItemHandled() {
    final now = mosqueManager.mosqueDate();
    final activeItems = widget.items.where((element) => !element.disabled).toList();
    if (activeItems.isEmpty) return;

    var firstItem = activeItems.first;

    for (var i = 0; i < activeItems.length; i++) {
      if (activeItems[i].disabled) continue;

      /// if the [activeItem[i]] will come before the [item]
      if (nextRepeat(activeItems[i])?.isBefore(nextRepeat(firstItem) ?? DateTime(2000)) ?? false) {
        firstItem = activeItems[i];
      }
    }

    /// main index on the list
    final nextItemIndex = widget.items.indexOf(firstItem);

    /// duration to the next item
    final nextActiveItemDuration = nextRepeat(firstItem)?.difference(now);

    /// if the item has past his time will do nothing
    if (nextActiveItemDuration?.isNegative ?? true) return;

    /// add the trigger
    Future.delayed(nextActiveItemDuration!, () => startItem(nextItemIndex));
  }

  /// return the next repeat time for this item
  /// repeat should be in the future
  DateTime? nextRepeat(RepeatingWorkflowItem item) {
    final now = mosqueManager.mosqueDate();

    final time = item.dateTime ?? startDate;
    if (item.repeatingDuration == null) return time.isBefore(now) ? null : time;

    int index = 0;
    while (true) {
      final nextTime = time.add(item.repeatingDuration! * index);
      if (nextTime.isAfter(now)) return nextTime;
      index++;
    }
  }

  /// return the next end time for this item
  Duration? nextEndTimeDuration(RepeatingWorkflowItem item) {
    final now = mosqueManager.mosqueDate();
    final time = item.endTime;

    if (time == null) return null;
    if (item.repeatingDuration == null) return time.isBefore(now) ? null : time.difference(now);

    int index = 0;
    while (true) {
      final nextTime = time.add(item.repeatingDuration! * index);
      if (nextTime.isAfter(now)) return nextTime.difference(now);
      index++;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (activeItem != null) {
      final item = widget.items[activeItem!];
      return item.builder(context, () => onItemDone(activeItem!));
    }

    return widget.child ?? Container();
  }
}
