import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/error/quran_exceptions.dart';

class QuranFavoriteLocalDataSource {
  /// first map is the quran (riwayat -> list of suwars)
  final Box<Map<String, Set<int>>> _quranReciterFavoriteBox;

  QuranFavoriteLocalDataSource(
    this._quranReciterFavoriteBox,
  );

  Future<void> saveFavoriteReciter(int reciterId) async {
    try {
      await _quranReciterFavoriteBox.put(reciterId, {});
    } catch (e) {
      throw SaveFavoriteReciterException(e.toString());
    }
  }

  Future<void> saveFavoriteSurahByReciter(int reciterId, int surahId, String riwayat) async {
    try {
      if(_quranReciterFavoriteBox.containsKey(riwayat)) {
        final riwayatMap = _quranReciterFavoriteBox.get(reciterId);
        final suwar = riwayatMap![riwayat] ?? {};
        if(suwar.contains(surahId)) {
          return;
        }
        suwar.add(surahId);
        riwayatMap[riwayat] = suwar;
        await _quranReciterFavoriteBox.put(reciterId, riwayatMap);
      }
    } catch (e) {
      throw SaveFavoriteSurahByReciterException(e.toString());
    }
  }

  Future<List<int>> getFavoriteReciters() async {
    try {
      final reciters = _quranReciterFavoriteBox.keys.cast<int>().toList();
      return reciters;
    } catch (e) {
      throw FetchFavoriteRecitersException(e.toString());
    }
  }

  Future<Set<int>> getFavoriteSuwarByReciter(int reciterId, String riwayat) async {
    try {
      if(_quranReciterFavoriteBox.containsKey(reciterId)) {
        final cached = _quranReciterFavoriteBox.get(reciterId);
        if(cached!.containsKey(riwayat)) {
          return cached[riwayat]!;
        }
      }
      return {};
    } catch (e) {
      throw FetchFavoriteSurahsByReciterException(e.toString());
    }
  }
}

final quranFavoriteLocalDataSourceProvider = FutureProvider<QuranFavoriteLocalDataSource>((ref) async {
  final quranReciterFavoriteBox = await Hive.openBox<Map<String, Set<int>>>(QuranConstant.kQuranReciterFavoriteBox);
  return QuranFavoriteLocalDataSource(quranReciterFavoriteBox);
});
