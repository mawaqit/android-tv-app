import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferenceModule = FutureProvider<SharedPreferences>((ref) async {
  final sharedPreference = await SharedPreferences.getInstance();
  return sharedPreference;
});
