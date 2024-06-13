import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/quran/audio_file_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

import 'package:mawaqit/src/domain/error/recite_exception.dart';
import 'package:path_provider/path_provider.dart';

import 'package:path/path.dart' as path;
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

  Future<String> saveAudioFile(AudioFileModel audioFileModel, List<int> bytes) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = path.join(dir.path, audioFileModel.filePath);
      final file = File(filePath);

      await file.parent.create(recursive: true);

      // Save the file
      await file.writeAsBytes(bytes);

      log('ReciteLocalDataSource: saveAudioFile: Saved audio file at $filePath');
      return filePath;
    } catch (e) {
      log('ReciteLocalDataSource: saveAudioFile: ${e.toString()}');
      throw SaveAudioFileException(e.toString());
    }
  }

  Future<String> getAudioFilePath(AudioFileModel audioFileModel) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = path.join(dir.path, audioFileModel.filePath);
      final file = File(filePath);

      if (await file.exists()) {
        log('ReciteLocalDataSource: getAudioFilePath: Found audio file at $filePath');
        return filePath;
      } else {
        log('ReciteLocalDataSource: getAudioFilePath: Audio file not found at $filePath');
        throw AudioFileNotFoundInCacheException();
      }
    } catch (e) {
      log('ReciteLocalDataSource: getAudioFilePath: ${e.toString()}');
      throw FetchAudioFileException(e.toString());
    }
  }
}

final reciteLocalDataSourceProvider = FutureProvider<ReciteLocalDataSource>((ref) async {
  final reciterBox = await Hive.openBox<ReciterModel>(QuranConstant.kReciterBox);
  return ReciteLocalDataSource(reciterBox);
});
