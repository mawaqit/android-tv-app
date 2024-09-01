import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

import 'package:mawaqit/src/domain/error/recite_exception.dart';

class ReciteLocalDataSource {
  final Box<ReciterModel> _reciterBox;
  final Box<int> _favoriteReciterBox;

  ReciteLocalDataSource(
    this._reciterBox,
    this._favoriteReciterBox,
  );

  Future<void> saveReciters(List<ReciterModel> reciters) async {
    try {
      if (reciters.isEmpty) return;
      log('recite: ReciteLocalDataSource: saveReciters: ${reciters[0]} len ${reciters.length}');
      final reciterMap = {for (var r in reciters) r.id: r};

      await _reciterBox.putAll(reciterMap);
    } catch (e) {
      log('saveReciters: ${e.toString()}');
      throw SaveRecitersException(e.toString());
    }
  }

  Future<List<ReciterModel>> getReciters() async {
    try {
      final reciters = _reciterBox.values.toList();
      if (reciters.isEmpty) return [];
      log('recite: ReciteLocalDataSource: getReciters: ${reciters[0]}');
      return reciters;
    } catch (e) {
      throw FetchRecitersException(e.toString());
    }
  }

  Future<List<ReciterModel>> getReciterBySurah(int surahId) async {
    try {
      // Retrieve all reciters
      final allReciters = _reciterBox.values.toList();

      final recitersForSurah =
          allReciters.where((reciter) => reciter.moshaf.any((moshaf) => moshaf.surahList.contains(surahId))).toList();

      log('recite: ReciteLocalDataSource: getReciterBySurah: Found ${recitersForSurah.length} reciters for surah $surahId');

      return recitersForSurah;
    } catch (e) {
      log('getReciterBySurah error: ${e.toString()}');
      throw FetchRecitersBySurahException(e.toString());
    }
  }

  Future<void> clearAllReciters() async {
    try {
      await _reciterBox.clear();
      log('recite: ReciteLocalDataSource: clearAllReciters: done');
    } catch (e) {
      throw ClearAllRecitersException(e.toString());
    }
  }

  bool isRecitersCached() {
    try {
      return _reciterBox.isNotEmpty;
    } catch (e) {
      log('recite: ReciteLocalDataSource: isRecitersCached: ${e.toString()}');
      throw CannotCheckRecitersCachedException(e.toString());
    }
  }

  Future<void> addFavoriteReciter(int reciterId) async {
    try {
      await _favoriteReciterBox.add(reciterId);
      log('recite: ReciteLocalDataSource: addFavoriteReciter: $reciterId');
    } catch (e) {
      log('addFavoriteReciter: ${e.toString()}');
      throw AddFavoriteReciterException(e.toString());
    }
  }

  Future<void> removeFavoriteReciter(int reciterId) async {
    try {
      final index = _favoriteReciterBox.values.toList().indexOf(reciterId);
      if (index != -1) {
        await _favoriteReciterBox.deleteAt(index);
        log('recite: ReciteLocalDataSource: removeFavoriteReciter: $reciterId');
      }
    } catch (e) {
      log('removeFavoriteReciter: ${e.toString()}');
      throw RemoveFavoriteReciterException(e.toString());
    }
  }

  Future<List<ReciterModel>> getFavoriteReciters() async {
    try {
      final favoriteReciterIds = _favoriteReciterBox.values.toList();
      final favoriteReciters = _reciterBox.values.where((reciter) => favoriteReciterIds.contains(reciter.id)).toList();
      log('recite: ReciteLocalDataSource: getFavoriteReciters: ${favoriteReciters.length}');
      return favoriteReciters;
    } catch (e) {
      log('getFavoriteReciters: ${e.toString()}');
      throw FetchFavoriteRecitersException(e.toString());
    }
  }

  bool isFavoriteReciter(int reciterId) {
    return _favoriteReciterBox.values.contains(reciterId);
  }
}

final reciteLocalDataSourceProvider = FutureProvider<ReciteLocalDataSource>((ref) async {
  final reciterBox = await Hive.openBox<ReciterModel>(QuranConstant.kReciterBox);
  final favoriteReciterBox = await Hive.openBox<int>(QuranConstant.kFavoriteReciterBox);
  return ReciteLocalDataSource(reciterBox, favoriteReciterBox);
});
