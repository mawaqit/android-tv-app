import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';

mixin AudioMixin on ChangeNotifier {
  abstract MosqueConfig? mosqueConfig;

  // Abstract getter that will be implemented by classes that use this mixin
  bool get typeIsMosque;
}
