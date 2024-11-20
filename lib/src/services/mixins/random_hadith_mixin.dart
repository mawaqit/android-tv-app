import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import '../../../i18n/AppLanguage.dart';

@Deprecated('Use RandomHadithNotifier instead')
mixin RandomHadithMixin on ChangeNotifier {
  abstract bool isOnline;
  abstract MosqueConfig? mosqueConfig;

  /// [_hadithLanguage] is the language of the hadith to be displayed for shared preferences
  String _hadithLanguage = '';

  /// channel to communicate with [AppLanguage] class
  /// [initState] will add a listener to this channel
  /// [dispose] will remove the listener from this channel
  @override
  void initState() {
    appLanguage.addListener(_languageChanged);
  }

  void _languageChanged() {
    if (appLanguage.hadithLanguage != _hadithLanguage) {
      _hadithLanguage = appLanguage.hadithLanguage;
      _fetchHadith();
    }
  }

  @override
  void dispose() {
    appLanguage.removeListener(_languageChanged);
    super.dispose();
  }

  /// [_hadith] is the hadith to be displayed
  String? _hadith;

  /// [hadith] getter
  get hadith => _hadith;
  AppLanguage appLanguage = AppLanguage();

  /// pre cache the random hadith file to be used in the hadith widget
  // Future<void> preCacheHadith() async {
  //   await Api.cacheHadithXMLFiles(language: mosqueConfig?.hadithLang ?? 'ar');
  //
  //   /// fetch hadith for the first time
  //   /// Delay it to keep the main thread free for the UI animations
  //   Future.delayed(Duration(seconds: 5), _fetchHadith);
  // }

  /// [_fetchHadith] will fetch the hadith from the hadith file
  /// and store it in [_hadith]
  /// case1: if the app is online, fetch the hadith from the server
  /// case2: if the app is offline, fetch the hadith from the cache
  Future<void> _fetchHadith() async {
    // Fetch the hadith language from shared preferences
    try {
      // Determine the language to use
      String language = _hadithLanguage.isNotEmpty ? _hadithLanguage : mosqueConfig?.hadithLang ?? 'ar';
      _hadithLanguage = _hadithLanguage.replaceAll('_', '-');
      // Fetch the hadith
      _hadith =
          isOnline ? await Api.randomHadith(language: language) : await Api.randomHadithCached(language: language);

      notifyListeners();
    } catch (e) {
      Logger().e('Error fetching Hadith: $e');
    }
  }

  /// [getRandomHadith] will return a random hadith from the hadith file
  /// Interface with the UI
  Future<String?> getRandomHadith() async {
    if (_hadith == null) await _fetchHadith();

    final currentHadith = _hadith;

    /// fetch another hadith for the next time
    /// Delay it to keep the main thread free for the UI animations
    Future.delayed(Duration(seconds: 3), _fetchHadith);

    return currentHadith;
  }
}
