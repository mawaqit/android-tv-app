import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/module/shared_preference_module.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mawaqit/src/const/constants.dart';

class QuranReadingLocalDataSource {
  final SharedPreferences sharedPreferences;

  const QuranReadingLocalDataSource({
    required this.sharedPreferences,
  });

  Future<int> getLastReadPage() async {
    return sharedPreferences.getInt(QuranConstant.kSavedCurrentPage) ?? 0;
  }

  Future<void> saveLastReadPage(int lastReadingPage) async {
    await sharedPreferences.setInt(QuranConstant.kSavedCurrentPage, lastReadingPage);
  }
}

final quranReadingLocalDataSourceProvider = FutureProvider<QuranReadingLocalDataSource>((ref) async {
  final sharedPreferences = await ref.read(sharedPreferenceModule.future);
  return QuranReadingLocalDataSource(
    sharedPreferences: sharedPreferences,
  );
});
