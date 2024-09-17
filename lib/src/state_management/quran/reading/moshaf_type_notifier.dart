import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';
import 'package:mawaqit/src/module/shared_preference_module.dart';

import 'moshaf_state.dart';

class MoshafTypeNotifier extends AsyncNotifier<MoshafState> {
  @override
  Future<MoshafState> build() async {
    final state = await _getInitialState();
    return state;
  }

  Future<void> switchMoshafType() async {
    final sharedPref = await ref.read(sharedPreferenceModule.future);

    state.maybeWhen(
      data: (data) => data.selectedMoshaf.fold(
        () => sharedPref.setString(QuranConstant.kSelectedMoshafType, MoshafType.warsh.toString()),
        (moshafType) {
          final newMoshafType = moshafType == MoshafType.hafs ? MoshafType.warsh : MoshafType.hafs;
          state = AsyncData(
            data.copyWith(
              selectedMoshaf: Option.of(newMoshafType),
            ),
          );
          return sharedPref.setString(
            QuranConstant.kSelectedMoshafType,
            newMoshafType.name,
          );
        },
      ),
      orElse: () => null,
    );
  }

  Future<void> selectMoshafType(MoshafType moshafType) async {
    final sharedPref = await ref.read(sharedPreferenceModule.future);
    state = AsyncData(
      state.value!.copyWith(
        selectedMoshaf: Option.of(moshafType),
      ),
    );
    sharedPref.setString(QuranConstant.kSelectedMoshafType, moshafType.name);
  }

  Future<MoshafState> _getInitialState() async {
    final sharedPref = await ref.read(sharedPreferenceModule.future);
    final moshafType = sharedPref.getString(QuranConstant.kSelectedMoshafType);
    final moshafTypeOption =
        moshafType == null ? Option<MoshafType>.none() : Option.of(MoshafType.fromString(moshafType));

    final hafsVersion = sharedPref.getString(QuranConstant.kHafsQuranLocalVersion);
    final warshVersion = sharedPref.getString(QuranConstant.kWarshQuranLocalVersion);

    final hafsVersionOption = Option.fromNullable(hafsVersion);
    final warshVersionOption = Option.fromNullable(warshVersion);

    return MoshafState(
      hafsVersion: hafsVersionOption,
      warshVersion: warshVersionOption,
      selectedMoshaf: moshafTypeOption,
    );
  }
}

final moshafTypeNotifierProvider = AsyncNotifierProvider<MoshafTypeNotifier, MoshafState>(MoshafTypeNotifier.new);
