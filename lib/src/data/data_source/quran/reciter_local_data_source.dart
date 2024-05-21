import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

import 'package:mawaqit/src/domain/error/recite_exception.dart';

class ReciteLocalDataSource {
  final Box<List<ReciterModel>> _reciterBox;

  ReciteLocalDataSource(this._reciterBox);

  Future<void> saveRecitersBySurah(List<ReciterModel> reciters, int surahId) async {
    try {
      log('recite: ReciteLocalDataSource: saveReciters: ${reciters[0]} len ${reciters.length}');
      await _reciterBox.putAll({surahId: reciters});
    } catch (e) {
      log('saveReciters: ${e.toString()}');
      throw SaveRecitersException(e.toString());
    }
  }

  Future<void> saveReciters(List<ReciterModel> reciters) async {
    try {
      log('recite: ReciteLocalDataSource: saveReciters: ${reciters[0]} len ${reciters.length}');
      await _reciterBox.put(0, reciters);
    } catch (e) {
      log('saveReciters: ${e.toString()}');
      throw SaveRecitersException(e.toString());
    }
  }

  Future<List<ReciterModel>> getReciters() async {
    try {
      final reciters = _reciterBox.get(0);
      log('recite: ReciteLocalDataSource: getReciters: ${reciters?[0]}');
      if (reciters != null) {
        return reciters;
      } else {
        return [];
      }
    } catch (e) {
      throw FetchRecitersException(e.toString());
    }
  }

  Future<List<ReciterModel>?> getReciterBySurah(int surahId) async {
    try {
      final reciters = _reciterBox.get(surahId);
      log('recite: ReciteLocalDataSource: getReciterBySurah: ${reciters?[0]}');
      if (reciters != null) {
        return reciters;
      } else {
        return null;
      }
    } catch (e) {
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
  final reciterBox = await Hive.openBox<List<ReciterModel>>(QuranConstant.kReciterBox);
  return ReciteLocalDataSource(reciterBox);
});
