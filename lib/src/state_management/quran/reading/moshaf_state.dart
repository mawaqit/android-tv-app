import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';

class MoshafState {
  final Option<String> hafsVersion;
  final Option<String> warshVersion;
  final Option<MoshafType> selectedMoshaf;
  final bool isFirstTime;

  MoshafState({
    required this.hafsVersion,
    required this.warshVersion,
    required this.selectedMoshaf,
    required this.isFirstTime,
  });

  // copy with
  MoshafState copyWith({
    Option<String>? hafsVersion,
    Option<String>? warshVersion,
    Option<MoshafType>? selectedMoshaf,
    bool? isFirstTime,
  }) {
    return MoshafState(
      hafsVersion: hafsVersion ?? this.hafsVersion,
      warshVersion: warshVersion ?? this.warshVersion,
      selectedMoshaf: selectedMoshaf ?? this.selectedMoshaf,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }
}
