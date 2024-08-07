import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/state_management/widget_routing/current_widget_notifier.dart';

class CurrentWidgetWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final String widgetName;

  const CurrentWidgetWrapper({
    Key? key,
    required this.child,
    required this.widgetName,
  }) : super(key: key);

  @override
  ConsumerState<CurrentWidgetWrapper> createState() =>
      _CurrentWidgetWrapperState();
}

class _CurrentWidgetWrapperState extends ConsumerState<CurrentWidgetWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(currentWidgetProvider.notifier)
          .setCurrentWidget(widget.widgetName);
    });
  }

  @override
  void dispose() {
    ref.read(currentWidgetProvider.notifier).setCurrentWidget('');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
