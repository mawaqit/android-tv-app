import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

import 'package:mawaqit/src/domain/error/recite_exception.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../main.dart';
import 'package:path/path.dart' as path;

import '../../../domain/model/quran/audio_file_model.dart';

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

  Future<String> getSurahPathWithExtension({
    required String reciterId,
    required String riwayahId,
    required String surahNumber,
  }) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String surahPath = '${appDocDir.path}/$reciterId/$riwayahId/$surahNumber.mp3';
    return surahPath;
  }

  Future<bool> isSurahDownloaded({
    required String reciterId,
    required String riwayahId,
    required int surahNumber,
  }) async {
    try {
      final surahFilePath = await getSurahPathWithExtension(
        reciterId: reciterId,
        riwayahId: riwayahId,
        surahNumber: surahNumber.toString(),
      );
      final file = File(surahFilePath);
      final exists = await file.exists();

      log('ReciteLocalDataSource: isSurahDownloaded: Surah $surahNumber ${exists ? 'exists' : 'does not exist'} for reciter $reciterId and riwayah $riwayahId');
      return exists;
    } catch (e) {
      log('ReciteLocalDataSource: error: isSurahDownloaded: ${e.toString()}');
      throw CheckSurahExistenceException(e.toString());
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

  Future<String> getSuwarFolderPath({
    required String reciterId,
    required String riwayahId,
  }) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String reciterPath = '${appDocDir.path}/$reciterId/$riwayahId';
    return reciterPath;
  }

  Future<List<File>> getDownloadedSurahByReciterAndRiwayah({
    required String reciterId,
    required String riwayahId,
  }) async {
    List<File> downloadedSuwar = [];
    try {
      // Get the application documents directory
      final path = await getSuwarFolderPath(reciterId: reciterId, riwayahId: riwayahId);
      // Check if the reciter's directory exists
      if (await Directory(path).exists()) {
        List<FileSystemEntity> files = await Directory(path).list().toList();

        // Filter and collect .mp3 files
        for (var file in files) {
          if (file is File && file.path.endsWith('.mp3')) {
            downloadedSuwar.add(file);
          }
        }
      }
    } catch (e) {
      logger.e('An error occurred while fetching downloaded surahs: $e');
    }
    return downloadedSuwar;
  }
}

final reciteLocalDataSourceProvider = FutureProvider<ReciteLocalDataSource>((ref) async {
  final reciterBox = await Hive.openBox<ReciterModel>(QuranConstant.kReciterBox);
  final favoriteReciterBox = await Hive.openBox<int>(QuranConstant.kFavoriteReciterBox);
  return ReciteLocalDataSource(reciterBox, favoriteReciterBox);
});
