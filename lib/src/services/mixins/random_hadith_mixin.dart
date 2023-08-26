import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';

mixin RandomHadithMixin on ChangeNotifier {
  abstract bool isOnline;
  abstract MosqueConfig? mosqueConfig;

  String? _hadith;

  /// pre cache the random hadith file to be used in the hadith widget
  Future<void> preCacheHadith() async {
    await Api.cacheHadithXMLFiles(language: mosqueConfig?.hadithLang ?? 'ar');

    /// fetch hadith for the first time
    /// Delay it to keep the main thread free for the UI animations
    Future.delayed(Duration(seconds: 5), _fetchHadith);
  }

  Future<void> _fetchHadith() async {
    if (isOnline) {
      Api.randomHadith(language: mosqueConfig!.hadithLang!)
          .then((value) => _hadith = value);
    } else {
      Api.randomHadithCached(language: mosqueConfig!.hadithLang!)
          .then((value) => _hadith = value);
    }
  }

  Future<String?> getRandomHadith() async {
    if (_hadith == null) await _fetchHadith();

    final currentHadith = _hadith;

    /// fetch another hadith for the next time
    /// Delay it to keep the main thread free for the UI animations
    Future.delayed(Duration(seconds: 3), _fetchHadith);

    return currentHadith;
  }
}
