import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';

import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

import 'package:mawaqit/src/domain/model/quran/surah_model.dart';

class ReciteState extends Equatable {
  final List<ReciterModel> reciters;
  final List<ReciterModel> filteredReciters;
  final List<ReciterModel> filteredFavoriteReciters;

  final List<ReciterModel> favoriteReciters;
  final Option<ReciterModel> selectedReciter;
  final Option<MoshafModel> selectedMoshaf;

  ReciteState({
    required this.reciters,
    this.selectedReciter = const None(),
    this.selectedMoshaf = const None(),
    this.favoriteReciters = const [],
    this.filteredReciters = const [],
    this.filteredFavoriteReciters = const [],
  });

  ReciteState copyWith({
    List<ReciterModel>? reciters,
    List<ReciterModel>? favoriteReciters,
    Option<ReciterModel>? selectedReciter,
    Option<MoshafModel>? selectedMoshaf,
    List<ReciterModel>? filteredReciters,
    List<ReciterModel>? filteredFavoriteReciters,
  }) {
    return ReciteState(
      reciters: reciters ?? this.reciters,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      favoriteReciters: favoriteReciters ?? this.favoriteReciters,
      selectedMoshaf: selectedMoshaf ?? this.selectedMoshaf,
      filteredReciters: filteredReciters ?? this.filteredReciters,
      filteredFavoriteReciters: filteredFavoriteReciters ?? this.filteredFavoriteReciters,
    );
  }

  @override
  String toString() {
    final reciterInfo = reciters.isNotEmpty ? reciters[0] : 'No reciters';
    return 'ReciteState(reciters: $reciterInfo, selectedReciter: ${selectedReciter.hashCode}, '
        'selectedMoshaf: ${selectedMoshaf.hashCode},'
        'filteredReciters: ${filteredReciters.length}'
        'filteredFavoriteReciters: ${filteredFavoriteReciters.length})';
  }

  @override
  List<Object?> get props => [
        reciters,
        selectedMoshaf,
        selectedReciter,
        favoriteReciters,
        filteredReciters,
        filteredFavoriteReciters,
      ];
}
