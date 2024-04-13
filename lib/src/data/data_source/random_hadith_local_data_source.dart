import 'dart:developer';
import 'dart:io';
import 'dart:math' show Random;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../main.dart';
import '../../const/constants.dart';

/// [RandomHadithLocalDataSource] Handles the local storage and retrieval of random hadiths using Hive.
///
/// This class provides methods to cache and fetch hadiths from local storage.
/// It is designed to work with a specific language and leverages the Hive package
class RandomHadithLocalDataSource {
  /// [box] is the Hive box used to store the hadiths
  final Box box;

  RandomHadithLocalDataSource({
    required this.box,
  });

  /// [getRandomHadith] Fetches a random hadith from the local storage based on the provided language.
  ///
  /// If hadiths are available for the specified language, this method returns a randomly
  /// selected hadith. Otherwise, it returns null.
  Future<String?> getRandomHadith({String language = 'ar'}) async {
    try {
      final s = box.keys;
      final ss = box.path;
      log(
        'Caching hadiths size $s',
        name: 'RandomHadithLocalDataSource',
        time: DateTime.now(),
      );
      // box size
      log(
        'Caching hadiths size ${File(ss!).lengthSync()}',
        name: 'RandomHadithLocalDataSource',
        time: DateTime.now(),
      );
      final hadithList = box.get(language) as List<String>?;
      if (hadithList != null && hadithList.isNotEmpty) {
        final randomIndex = Random().nextInt(hadithList.length);
        return hadithList[randomIndex];
      }
      return null;
    } catch (e) {
      throw e;
    }
  }

  /// [cacheRandomHadith] Caches a list of hadiths in the local storage for the specified language.
  ///
  /// [language] The language of the hadiths.
  /// [hadiths] The list of hadiths to cache.
  Future<void> cacheRandomHadith(String language, List<String> hadiths) async {
    try {
      await box.put(language, hadiths);
    } catch (e) {
      throw e;
    }
  }

  /// [clearAllCache] Clears all hadiths from the local storage.
  ///
  /// This method removes all hadiths from the local storage.
  Future<void> clearAllCache() async {
    try {
      await box.clear();
    } catch (e) {
      throw e;
    }
  }

  /// [availableLanguages] Returns a list of languages for which hadiths are available in the local storage.
  ///
  /// This method returns a list of languages for which hadiths are available in the local storage.
  List<String> availableLanguages() {
    try {
      if (box.keys.isNotEmpty) {
        return [];
      }
      return box.keys.cast<String>().toList();
    } catch (e) {
      throw e;
    }
  }
}

/// This provider is responsible for initializing and providing an instance of
/// RandomHadithLocalDataSource. It ensures the Hive box is opened before the data source
/// [RandomHadithLocalDataSource] is used.
final randomHadithLocalDataSourceProvider = FutureProvider<RandomHadithLocalDataSource>(
  (ref) async {
    // open box if not opened
    final box = await Hive.openBox(RandomHadithConstant.kBoxName);
    return RandomHadithLocalDataSource(
      box: box,
    );
  },
);
