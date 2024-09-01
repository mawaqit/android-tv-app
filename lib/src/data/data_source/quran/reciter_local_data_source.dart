import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

import 'package:mawaqit/src/domain/error/recite_exception.dart';

class ReciteLocalDataSource {
  final Box<ReciterModel> _reciterBox;

  ReciteLocalDataSource(this._reciterBox);


  Future<void> saveReciters(List<ReciterModel> reciters) async {
    try {
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

      final recitersForSurah = allReciters.where((reciter) =>
          reciter.moshaf.any((moshaf) => moshaf.surahList.contains(surahId))
      ).toList();

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
}

final reciteLocalDataSourceProvider = FutureProvider<ReciteLocalDataSource>((ref) async {
  final reciterBox = await Hive.openBox<ReciterModel>(QuranConstant.kReciterBox);
  return ReciteLocalDataSource(reciterBox);
});
