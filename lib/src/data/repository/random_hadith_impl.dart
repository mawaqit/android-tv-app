import 'dart:developer';
import 'dart:math' show Random;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/data/data_source/random_hadith_local_data_source.dart';
import 'package:mawaqit/src/domain/repository/random_hadith_repository.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/helpers/random_hadith_helper.dart';
import 'package:mawaqit/src/models/address_model.dart';
import 'package:mawaqit/src/services/connectivity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import '../data_source/random_hadith_remote_data_source.dart';

/// [RandomHadithImpl] Implementation of the RandomHadithRepository.
///
/// This class handles the logic to fetch a random Hadith either from remote or local sources
/// based on the connectivity status. It leverages the connectivity service to check for internet
/// connection and SharedPreferences to cache the date of the last fetch operation.
class RandomHadithImpl implements RandomHadithRepository {
  final RandomHadithRemoteDataSource remoteDataSource;
  final RandomHadithLocalDataSource localDataSource;
  final ConnectivityService connectivityService;
  final SharedPreferences sharedPreferences;

  RandomHadithImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
    required this.sharedPreferences,
  });

  /// [getRandomHadith] Fetches a random Hadith based on the provided or stored language preference.
  ///
  /// The method performs several checks before attempting to fetch a new Hadith:
  /// 1. Checks for internet connectivity. If connected, it proceeds with further checks;
  /// 2. Retrieves the last fetch timestamp and language from SharedPreferences to determine
  ///    if a fetch operation is needed. A new fetch is deemed necessary if either a day has
  ///    passed since the last fetch, or the language preference has changed.
  /// 3. If a new fetch is required and the device is connected to the internet, it fetches
  ///    the Hadith from the remote source, updates the local cache with the new Hadith data,
  ///    and records the fetch timestamp and language in SharedPreferences.
  /// 4. If a new fetch is not required or if the device is not connected, it attempts to
  ///    return the Hadith from the local cache.
  ///
  /// This approach ensures that the Hadith is fetched at most once per day per language,
  /// optimizing both network usage and user experience by providing quick access to cached data.
  ///
  ///
  @override
  Future<String> getRandomHadith({required String language}) async {
    log('random_hadith: RandomHadithImpl: Fetching random Hadith');
    final hadithLanguageLocal = sharedPreferences.getString(RandomHadithConstant.kHadithLanguage);
    log('random_hadith: RandomHadithImpl: Stored language: $hadithLanguageLocal');

    if (language != hadithLanguageLocal) {
      language = language;
    }

    language = RandomHadithHelper.changeLanguageFormat(language);
    log('random_hadith: RandomHadithImpl: Formatted language: $language');

    final isConnected = await connectivityService.connectionStatus == ConnectivityStatus.connected;
    log('random_hadith: RandomHadithImpl: Internet connection status: $isConnected');

    if (isConnected) {
      return await _handleOnlineMode(language);
    } else {
      return await _handleOfflineMode(language);
    }
  }

  /// [fetchAndCacheHadith] Fetches and caches a random Hadith from the remote source.
  ///
  /// This method uses an Isolate to fetch the Hadith in XML format from the
  /// remote source and caches it locally using the [RandomHadithLocalDataSource].
  /// If the provided language string contains two languages separated by an
  /// underscore, it fetches and caches the Hadith for both languages.
  @override
  Future<void> fetchAndCacheHadith(String language) async {
    language = RandomHadithHelper.changeLanguageFormat(language);

    log('random_hadith: RandomHadithImpl: fetchAndCacheHadith: isTwoLanguage ${RandomHadithHelper.isTwoLanguage(language)}');
    if (RandomHadithHelper.isTwoLanguage(language)) {
      final languageList = RandomHadithHelper.getLanguage(language);
      log('random_hadith: RandomHadithImpl: fetchAndCacheHadith: languageList $languageList');
      for (final lang in languageList) {
        log('random_hadith: RandomHadithImpl: fetchAndCacheHadith: language in for $lang');
        // Use an isolate to fetch the Hadith in XML format and cache it locally.
        final hadithXmlList = await remoteDataSource.getRandomHadithXML(language: lang);
        if (hadithXmlList != null) {
          final hadithList = hadithXmlList.map((e) => e.text).whereType<String>().toList();
          log('random_hadith: RandomHadithImpl: fetchAndCacheHadith: hadithList ${hadithList.length} ${hadithList.first}');
          await localDataSource.cacheRandomHadith(lang, hadithList);
        }
      }
    } else {
      log('random_hadith: RandomHadithImpl: fetchAndCacheHadith: language $language');
      final hadithXmlList = await remoteDataSource.getRandomHadithXML(language: language);
      log('random_hadith: RandomHadithImpl: fetchAndCacheHadith: fetchedHadithXML ${hadithXmlList?.length} ${hadithXmlList?.first.text}');
      if (hadithXmlList != null) {
        final hadithList = hadithXmlList.map((e) => e.text).whereType<String>().toList();
        log('random_hadith: RandomHadithImpl: fetchAndCacheHadith: hadithList ${hadithList.length} ${hadithList.first}');
        await localDataSource.cacheRandomHadith(language, hadithList);
      }
    }
  }

  /// Handles the online mode for fetching a random Hadith.
  ///
  /// This method checks if a fetch operation is needed based on the last fetch
  /// timestamp and language. If a new fetch is required, it fetches the Hadith
  /// from the remote source, updates the local cache, and records the fetch
  /// timestamp and language in [SharedPreferences].
  Future<String> _handleOnlineMode(String language) async {
    log('random_hadith: RandomHadithImpl: Handling online mode');

    final hadith = await remoteDataSource.getRandomHadith(language: language);

    final lastRunTime = sharedPreferences.getInt(RandomHadithConstant.kLastHadithXMLFetchDate);
    final lastRunLanguage = sharedPreferences.getString(RandomHadithConstant.kLastHadithXMLFetchLanguage);

    log('random_hadith: RandomHadithImpl: Last fetch time: $lastRunTime, Last fetch language: $lastRunLanguage');

    bool isFetchNeeded = true;

    if (lastRunTime != null && lastRunLanguage != language) {
      final lastRunDate = DateTime.fromMillisecondsSinceEpoch(lastRunTime);
      final now = AppDateTime.now();
      isFetchNeeded = now.difference(lastRunDate).inDays >= 1 || lastRunLanguage != language;
    }

    log('random_hadith: RandomHadithImpl: Fetch needed: $isFetchNeeded');

    // If the fetch is not needed, return the cached Hadith.
    if (!isFetchNeeded) {
      log('random_hadith: RandomHadithImpl: Returning cached Hadith');
      return hadith;
    }

    // Update the date of the last successful fetch operation.
    final today = AppDateTime.now().millisecondsSinceEpoch;
    await sharedPreferences.setInt(RandomHadithConstant.kLastHadithXMLFetchDate, today);
    await sharedPreferences.setString(RandomHadithConstant.kLastHadithXMLFetchLanguage, language);

    log('random_hadith: RandomHadithImpl: Updating fetch timestamp and language with $language');

    fetchAndCacheHadith(language);

    log('random_hadith: RandomHadithImpl: Returning fetched Hadith');
    return hadith;
  }

  /// Handles the offline mode for fetching a random Hadith.
  ///
  /// This method fetches the Hadith from the local cache based on the provided
  /// language. If the language string contains two languages separated by an
  /// underscore, it randomly selects one of the languages and fetches the
  /// Hadith for that language.
  Future<String> _handleOfflineMode(String language) async {
    log('random_hadith: RandomHadithImpl: Handling offline mode');

    if (RandomHadithHelper.isTwoLanguage(language)) {
      final languageList = RandomHadithHelper.getLanguage(language);
      final randomLanguage = languageList[Random().nextInt(languageList.length)];
      log('random_hadith: RandomHadithImpl: Fetching Hadith for random language: $randomLanguage');

      // Fetch from local cache if not connected.
      final hadith = await localDataSource.getRandomHadith(language: randomLanguage);
      log('random_hadith: RandomHadithImpl: Fetched Hadith: ${hadith ?? 'No Hadith found'}');
      return hadith ?? '';
    } else {
      log('random_hadith: RandomHadithImpl: Fetching Hadith for language: $language');

      // Fetch from local cache if not connected.
      final hadith = await localDataSource.getRandomHadith(language: language);
      log('random_hadith: RandomHadithImpl: Fetched Hadith: ${hadith ?? 'No Hadith found'}');
      return hadith ?? '';
    }
  }
}

/// [randomHadithRepositoryProvider] Riverpod provider for RandomHadithImpl.
final randomHadithRepositoryProvider = FutureProvider.autoDispose<RandomHadithImpl>(
  (ref) async {
    final localDataSource = await ref.read(randomHadithLocalDataSourceProvider.future);
    final remoteDataSource = ref.read(randomHadithRemoteDataSourceProvider);
    final sharedPreferences = await SharedPreferences.getInstance();
    return RandomHadithImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      sharedPreferences: sharedPreferences,
      connectivityService: ref.read(
        connectivityServiceProvider(
          ConnectivityServiceParams(
            interval: const Duration(seconds: 5),
            timeout: const Duration(seconds: 5),
          ),
        ),
      ),
    );
  },
);
