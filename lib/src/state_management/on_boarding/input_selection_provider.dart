import 'package:flutter_riverpod/flutter_riverpod.dart';

enum InputSelection {
  none,
  withId,
  withoutId,
}

final inputSelectionProvider = StateProvider.autoDispose<InputSelection>((ref) => InputSelection.none);
