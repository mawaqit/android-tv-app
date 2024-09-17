
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';

class MoshafState {
  final Option<String> hafsVersion;
  final Option<String> warshVersion;
  final Option<MoshafType> selectedMoshaf;

  MoshafState({
    required this.hafsVersion,
    required this.warshVersion,
    required this.selectedMoshaf,
  });

  // copy with
  MoshafState copyWith({
    Option<String>? hafsVersion,
    Option<String>? warshVersion,
    Option<MoshafType>? selectedMoshaf,
  }) {
    return MoshafState(
      hafsVersion: hafsVersion ?? this.hafsVersion,
      warshVersion: warshVersion ?? this.warshVersion,
      selectedMoshaf: selectedMoshaf ?? this.selectedMoshaf,
    );
  }
}
