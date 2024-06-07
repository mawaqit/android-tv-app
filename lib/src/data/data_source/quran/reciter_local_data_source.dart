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
      for (var reciter in reciters) {
        await _reciterBox.put(reciter.id, reciter);
      }
      log('ReciteLocalDataSource: saveReciters: Saved ${reciters.length} reciters');
    } catch (e) {
      log('saveReciters: ${e.toString()}');
      throw SaveRecitersException(e.toString());
    }
  }

  Future<List<ReciterModel>> getReciters() async {
    try {
      final reciters = _reciterBox.values.toList();
      log('ReciteLocalDataSource: getReciters: Retrieved ${reciters.length} reciters');
      return reciters;
    } catch (e) {
      throw FetchRecitersException(e.toString());
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
