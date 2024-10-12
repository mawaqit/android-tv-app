import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/src/data/repository/quran/recite_impl.dart';
import 'package:mawaqit/src/state_management/quran/recite/recite_state.dart';

import 'package:mawaqit/src/module/shared_preference_module.dart';

import 'package:mawaqit/src/helpers/language_helper.dart';

import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';

class ReciteNotifier extends AsyncNotifier<ReciteState> {
  // Option<List<ReciterModel>> _cachedReciters = None();
  Timer? _debounce;

  @override
  build() async {
    ref.onDispose(() async {
      final reciteImpl = await ref.read(reciteImplProvider.future);
      await reciteImpl.clearAllReciters();
      _debounce?.cancel();
    });

    final reciters = await _getRemoteReciters();
    final favoriteReciters = await _loadFavoriteReciters();
    final aggregatedReciters = await _getAllReciters(favoriteReciters, reciters);
    return ReciteState(
      reciters: aggregatedReciters,
      favoriteReciters: favoriteReciters,
      filteredReciters: aggregatedReciters,
      filteredFavoriteReciters: favoriteReciters,
    );
  }

  void setSearchQuery(String query, bool isAllReciters) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _updateFilteredReciters(query.toLowerCase(), isAllReciters);
    });
  }

  Future<void> _updateFilteredReciters(String query, bool isAllReciters) async {
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      if (isAllReciters) {
        final filteredReciters = _filterReciters(currentState.reciters, query);
        return currentState.copyWith(filteredReciters: filteredReciters);
      } else {
        final filteredFavoriteReciters = _filterReciters(currentState.favoriteReciters, query);
        return currentState.copyWith(filteredFavoriteReciters: filteredFavoriteReciters);
      }
    });
  }

  List<ReciterModel> _filterReciters(List<ReciterModel> reciters, String query) {
    if (query.length <= 2) {
      return reciters;
    }
    return reciters.where((reciter) => reciter.name.toLowerCase().contains(query)).toList();
  }

  void setSelectedReciter({
    required ReciterModel reciterModel,
  }) {
    state = AsyncData(
      state.value!.copyWith(
        selectedReciter: Option.of(reciterModel),
      ),
    );
  }

  void setSelectedMoshaf({
    required MoshafModel moshafModel,
  }) {
    state = AsyncData(
      state.value!.copyWith(
        selectedMoshaf: Option.of(moshafModel),
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

  Future<List<ReciterModel>> _getRemoteReciters() async {
    state = AsyncLoading();
    try {
      final reciteImpl = await ref.read(reciteImplProvider.future);
      final sharedPreference = await ref.read(sharedPreferenceModule.future);
      final languageCode = sharedPreference.getString('language_code') ?? 'en';
      final mappedLanguage = LanguageHelper.mapLocaleWithQuran(languageCode);
      final reciters = await reciteImpl.getAllReciters(language: mappedLanguage);
      return reciters;
    } catch (e, s) {
      state = AsyncError(e, s);
      rethrow;
    }
  }

  Future<List<ReciterModel>> _getAllReciters(List<ReciterModel> favorite, List<ReciterModel> reciters) async {
    try {
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
