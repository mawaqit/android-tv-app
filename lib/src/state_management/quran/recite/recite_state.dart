import 'package:equatable/equatable.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';

import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

import 'package:mawaqit/src/domain/model/quran/surah_model.dart';

class ReciteState extends Equatable {
  final List<ReciterModel> reciters;
  final ReciterModel? selectedReciter;
  final MoshafModel? selectedMoshaf;

  ReciteState({
    required this.reciters,
    this.selectedReciter,
    this.selectedMoshaf,
  });

  ReciteState copyWith({
    List<ReciterModel>? reciters,
    ReciterModel? selectedReciter,
    MoshafModel? selectedMoshaf,
  }) {
    return ReciteState(
      reciters: reciters ?? this.reciters,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      selectedMoshaf: selectedMoshaf ?? this.selectedMoshaf,
    );
  }

  @override
  String toString() {
    return 'ReciteState(reciters: ${reciters[0]}) selectedReciter: $selectedReciter selectedMoshaf: $selectedMoshaf)';
  }

  @override
  List<Object?> get props => [reciters, selectedMoshaf, selectedReciter];
}
