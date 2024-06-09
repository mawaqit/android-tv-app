import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/data/repository/quran/quran_favorite_impl.dart';
import 'package:mawaqit/src/state_management/quran/favorite/quran_favorite_state.dart';

class QuranFavoriteNotifier extends AsyncNotifier<QuranFavoriteState> {
  @override
  build() async {
    getFavoriteReciters();
    return QuranFavoriteState(
      favoriteReciters: [],
    );
  }

  Future<void> getFavoriteReciters() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final quranFavoriteRepository = await ref.read(quranFavoriteRepositoryProvider.future);
      final reciters = await quranFavoriteRepository.getFavoriteReciters();
      return state.value!.copyWith(favoriteReciters: reciters);
    });
  }

  Future<void> getFavoriteSuwar({
    required int riwayatId,
    required int reciterId,
  }) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final quranFavoriteRepository = await ref.read(quranFavoriteRepositoryProvider.future);
      final favoriteMoshafs = await quranFavoriteRepository.getFavoriteSuwar(reciterId, riwayatId);
      log('quran: QuranFavoriteNotifier: getFavoriteSuwar: ${favoriteMoshafs.surahList}');
      return state.value!.copyWith(favoriteMoshafs: favoriteMoshafs);
    });
  }

  Future<void> saveFavoriteReciter({
    required int reciterId,
  }) async {
    try {
      state = AsyncLoading();
      final quranFavoriteRepository = await ref.read(quranFavoriteRepositoryProvider.future);
      await quranFavoriteRepository.saveFavoriteReciter(reciterId);
      getFavoriteReciters();
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> saveFavoriteSuwar({
    required int reciterId,
    required int surahId,
    required int riwayatId,
  }) async {
    try {
      state = AsyncLoading();
      final quranFavoriteRepository = await ref.read(quranFavoriteRepositoryProvider.future);
      await quranFavoriteRepository.saveFavoriteSuwar(
        reciterId: reciterId,
        surahId: surahId,
        riwayatId: riwayatId,
      );
      getFavoriteSuwar(riwayatId: riwayatId, reciterId: reciterId);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> deleteFavoriteReciter({required int reciterId}) async {
    try {
      state = AsyncLoading();
      final quranFavoriteRepository = await ref.read(quranFavoriteRepositoryProvider.future);
      await quranFavoriteRepository.deleteFavoriteReciter(reciterId: reciterId);
      getFavoriteReciters();
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> deleteFavoriteSuwar({
    required int reciterId,
    required int surahId,
    required int riwayatId,
  }) async {
    try {
      state = AsyncLoading();
      final quranFavoriteRepository = await ref.read(quranFavoriteRepositoryProvider.future);
      await quranFavoriteRepository.deleteFavoriteSuwar(reciterId: reciterId, surahId: surahId, riwayatId: riwayatId);
      getFavoriteReciters();
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}

final quranFavoriteNotifierProvider = AsyncNotifierProvider<QuranFavoriteNotifier, QuranFavoriteState>(
  QuranFavoriteNotifier.new,
);
