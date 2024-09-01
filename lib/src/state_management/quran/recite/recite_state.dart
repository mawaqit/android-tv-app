import 'package:equatable/equatable.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';

import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

import 'package:mawaqit/src/domain/model/quran/surah_model.dart';

class ReciteState extends Equatable {
  final List<ReciterModel> reciters;
  final ReciterModel? selectedReciter;
  final MoshafModel? selectedMoshaf;
  final List<ReciterModel> favoriteReciters;

  ReciteState({
    required this.reciters,
    this.selectedReciter,
    this.favoriteReciters = const [],
    this.selectedMoshaf,
  });

  ReciteState copyWith({
    List<ReciterModel>? reciters,
    List<ReciterModel>? favoriteReciters,
    ReciterModel? selectedReciter,
    MoshafModel? selectedMoshaf,
  }) {
    return ReciteState(
      reciters: reciters ?? this.reciters,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      favoriteReciters: favoriteReciters ?? this.favoriteReciters,
      selectedMoshaf: selectedMoshaf ?? this.selectedMoshaf,
    );
  }

  @override
  String toString() {
    final reciterInfo = reciters.isNotEmpty ? reciters[0] : 'No reciters';
    return 'ReciteState(reciters: $reciterInfo, selectedReciter: ${selectedReciter?.hashCode}, selectedMoshaf: ${selectedMoshaf?.hashCode})';
  }

  @override
  List<Object?> get props => [reciters, selectedMoshaf, selectedReciter];
}
