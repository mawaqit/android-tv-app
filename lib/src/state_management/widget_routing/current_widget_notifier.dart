import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentWidgetNotifier extends StateNotifier<String> {
  CurrentWidgetNotifier() : super('');

  void setCurrentWidget(String widgetName) {
    state = widgetName;
  }
}

final currentWidgetProvider =
    StateNotifierProvider<CurrentWidgetNotifier, String>((ref) {
  return CurrentWidgetNotifier();
});
