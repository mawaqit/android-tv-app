import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefModule = FutureProvider<SharedPreferences>(
  (_) async => await SharedPreferences.getInstance(),
);
