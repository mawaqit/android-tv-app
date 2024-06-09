import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'quran_favorite_reciter_favorite_model.g.dart';

@HiveType(typeId: 4)
class QuranReciterFavoriteModel with EquatableMixin {
  @HiveField(0)
  final int reciterId;

  @HiveField(1)
  final List<SurahFavoriteModel> favoriteSuwar;

  QuranReciterFavoriteModel({required this.reciterId, required this.favoriteSuwar});

  QuranReciterFavoriteModel addSurahFavorite(int surahId, int riwayatId) {
    final surahFavorite = _getSurahFavoriteByRiwayatId(riwayatId);
    if (surahFavorite == null) {
      final newSurahFavorite = SurahFavoriteModel(surahIds: [surahId], riwayatId: riwayatId);
      return copyWith(favoriteSuwar: [...favoriteSuwar, newSurahFavorite]);
    } else {
      final newNonDuplicatedSurahIds = surahFavorite.surahIds.toSet()..add(surahId);
      final newNonDuplicatedSurahIdsList = newNonDuplicatedSurahIds.toList();
      final newSurahFavorite = surahFavorite.copyWith(surahIds: newNonDuplicatedSurahIdsList);
      final newFavoriteSuwar = favoriteSuwar.map((e) => e.riwayatId == riwayatId ? newSurahFavorite : e).toList();
      return copyWith(favoriteSuwar: newFavoriteSuwar);
    }
  }

  SurahFavoriteModel? getFavoriteSuwarByRiwayatId(int riwayatId) {
    return favoriteSuwar.firstWhereOrNull((element) => element.riwayatId == riwayatId);
  }

  QuranReciterFavoriteModel copyWith({
    int? reciterId,
    List<SurahFavoriteModel>? favoriteSuwar,
  }) {
    return QuranReciterFavoriteModel(
      reciterId: reciterId ?? this.reciterId,
      favoriteSuwar: favoriteSuwar ?? this.favoriteSuwar,
    );
  }

  SurahFavoriteModel? _getSurahFavoriteByRiwayatId(int riwayatId) {
    return favoriteSuwar.firstWhereOrNull((element) => element.riwayatId == riwayatId);
  }

  @override
  List<Object?> get props => [reciterId, favoriteSuwar];
}

@HiveType(typeId: 5)
class SurahFavoriteModel with EquatableMixin {
  @HiveField(0)
  final List<int> surahIds;

  @HiveField(1)
  final int riwayatId;

  SurahFavoriteModel({required this.surahIds, required this.riwayatId});

  SurahFavoriteModel copyWith({
    List<int>? surahIds,
    int? riwayatId,
  }) {
    return SurahFavoriteModel(
      surahIds: surahIds ?? this.surahIds,
      riwayatId: riwayatId ?? this.riwayatId,
    );
  }

  bool isSurahFavorite(int surahId) {
    return surahIds.contains(surahId);
  }

  SurahFavoriteModel removeSurahFavorite(int surahId) {
    surahIds.remove(surahId);
    return copyWith(surahIds: surahIds);
  }

  @override
  List<Object?> get props => [surahIds, riwayatId];
}
