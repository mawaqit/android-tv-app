import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/data/repository/quran/recite_impl.dart';
import 'package:mawaqit/src/state_management/quran/recite/recite_state.dart';

import 'package:mawaqit/src/module/shared_preference_module.dart';

import 'package:mawaqit/src/helpers/language_helper.dart';

import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';

class ReciteNotifier extends AsyncNotifier<ReciteState> {
  @override
  build() async {
    final favoriteReciters = await _loadFavoriteReciters();
    final reciters = await _getAllReciters(favoriteReciters);
    return ReciteState(
      reciters: reciters,
      favoriteReciters: favoriteReciters,
    );
  }

  void setSelectedReciter({
    required ReciterModel reciterModel,
  }) {
    state = AsyncData(
      state.value!.copyWith(
        selectedReciter: reciterModel,
      ),
    );
  }

  void setSelectedMoshaf({
    required MoshafModel moshafModel,
  }) {
    state = AsyncData(
      state.value!.copyWith(
        selectedMoshaf: moshafModel,
      ),
    );
  }

  Future<void> addFavoriteReciter(ReciterModel reciter) async {
    try {
      await _saveFavoriteReciters(reciter.id);
      final updatedFavorites = [...state.value!.favoriteReciters, reciter];
      final updatedReciters = _sortReciters(state.value!.reciters, updatedFavorites);
      state = AsyncData(
        state.value!.copyWith(
          favoriteReciters: updatedFavorites,
          reciters: updatedReciters,
        ),
      );
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> removeFavoriteReciter(ReciterModel reciter) async {
    try {
      final reciteImpl = await ref.read(reciteImplProvider.future);
      await reciteImpl.removeFavoriteReciter(reciter.id);
      final updatedFavorites = state.value!.favoriteReciters.where((r) => r.id != reciter.id).toList();
      final updatedReciters = _sortReciters(state.value!.reciters, updatedFavorites);
      state = AsyncData(
        state.value!.copyWith(
          favoriteReciters: updatedFavorites,
          reciters: updatedReciters,
        ),
      );
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  bool isReciterFavorite(ReciterModel reciter) {
    return state.value!.favoriteReciters.any((r) => r.id == reciter.id);
  }

  List<ReciterModel> _sortReciters(List<ReciterModel> allReciters, List<ReciterModel> favorites) {
    // Sort favorites alphabetically
    final sortedFavorites = List<ReciterModel>.from(favorites)..sort((a, b) => a.name.compareTo(b.name));

    // Get non-favorites and sort them alphabetically
    final nonFavorites = allReciters.where((reciter) => !favorites.any((fav) => fav.id == reciter.id)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    // Combine sorted favorites and non-favorites
    return [
      ...sortedFavorites,
      ...nonFavorites,
    ];
  }

  Future<List<ReciterModel>> _loadFavoriteReciters() async {
    final reciteImpl = await ref.read(reciteImplProvider.future);
    final favoriteReciters = await reciteImpl.getFavoriteReciters();
    return favoriteReciters;
  }

  Future<void> _saveFavoriteReciters(int id) async {
    try {
      final reciteImpl = await ref.read(reciteImplProvider.future);
      await reciteImpl.addFavoriteReciter(id);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<List<ReciterModel>> _getAllReciters(List<ReciterModel> favorite) async {
    state = AsyncLoading();
    try {
      final reciteImpl = await ref.read(reciteImplProvider.future);
      final sharedPreference = await ref.read(sharedPreferenceModule.future);
      final languageCode = sharedPreference.getString('language_code') ?? 'en';
      final mappedLanguage = LanguageHelper.mapLocaleWithQuran(languageCode);
      final reciters = await reciteImpl.getAllReciters(language: mappedLanguage);
      // Sort reciters: favorites first, then the rest
      final sortedReciters = [
        ...favorite,
        ...reciters.where((reciter) => !favorite.any((fav) => fav.id == reciter.id)),
      ];

      return sortedReciters;
    } catch (e, s) {
      state = AsyncError(e, s);
      return [];
    }
  }
}

final reciteNotifierProvider = AsyncNotifierProvider<ReciteNotifier, ReciteState>(ReciteNotifier.new);
