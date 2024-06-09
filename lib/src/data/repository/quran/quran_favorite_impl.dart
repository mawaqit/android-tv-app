import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/domain/repository/quran/quran_favorite_repository.dart';

import 'package:mawaqit/src/data/data_source/quran/quran_favorite_local_data_source.dart';

import 'package:mawaqit/src/data/data_source/quran/reciter_local_data_source.dart';

class QuranFavoriteImpl implements QuranFavoriteRepository {
  final QuranFavoriteLocalDataSource _favoriteLocalDataSource;
  final ReciteLocalDataSource _reciteLocalDataSource;

  QuranFavoriteImpl(
    this._favoriteLocalDataSource,
    this._reciteLocalDataSource,
  );

  @override
  Future<List<ReciterModel>> getFavoriteReciters() async {
    final List<int> favoriteReciterIds = await _favoriteLocalDataSource.getFavoriteReciters();
    final List<ReciterModel> reciters = await _reciteLocalDataSource.getReciters();
    return reciters.where((reciter) => favoriteReciterIds.contains(reciter.id)).toList();
  }

  @override
  Future<MoshafModel> getFavoriteSuwar(int reciterId, int riwayatId) async {
    final List<int> favoriteSuwarIds = await _favoriteLocalDataSource.getFavoriteSuwarByReciter(reciterId, riwayatId);
    final List<ReciterModel> reciters = await _reciteLocalDataSource.getReciters();
    final ReciterModel reciter = reciters.firstWhere((reciter) => reciter.id == reciterId);
    log('quran: QuranFavoriteImpl: getFavoriteSuwar: ${favoriteSuwarIds} | ${reciter.name} |  ${reciter.moshaf[0].surahList} | ${reciter.moshaf.firstWhere((moshaf) => moshaf.moshafType == riwayatId).copyWith(surahList: favoriteSuwarIds.toList())}');
    return reciter.moshaf
        .firstWhere((moshaf) => moshaf.moshafType == riwayatId)
        .copyWith(surahList: favoriteSuwarIds.toList());
  }

  @override
  Future<void> saveFavoriteReciter(int reciterId) {
    return _favoriteLocalDataSource.saveFavoriteReciter(reciterId);
  }

  @override
  Future<void> saveFavoriteSuwar({
    required int reciterId,
    required int surahId,
    required int riwayatId,
  }) {
    return _favoriteLocalDataSource.saveFavoriteSurahByReciter(reciterId, surahId, riwayatId);
  }

  @override
  Future<void> deleteFavoriteReciter({required int reciterId}) {
    return _favoriteLocalDataSource.deleteFavoriteReciter(reciterId: reciterId);
  }

  @override
  Future<void> deleteFavoriteSuwar({
    required int reciterId,
    required int surahId,
    required int riwayatId,
  }) async {
    await _favoriteLocalDataSource.deleteFavoriteSuwar(reciterId: reciterId, surahId: surahId, riwayatId: riwayatId);
  }
}

final quranFavoriteRepositoryProvider = FutureProvider<QuranFavoriteRepository>((ref) async {
  final favoriteLocalDataSource = await ref.read(quranFavoriteLocalDataSourceProvider.future);
  final reciteLocalDataSource = await ref.read(reciteLocalDataSourceProvider.future);
  return QuranFavoriteImpl(favoriteLocalDataSource, reciteLocalDataSource);
});
