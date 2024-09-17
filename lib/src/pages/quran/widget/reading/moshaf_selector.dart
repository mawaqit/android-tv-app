import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/moshaf_type_notifier.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';
import 'package:sizer/sizer.dart';

class MoshafSelector extends ConsumerWidget {
  final FocusNode focusNode;

  const MoshafSelector({super.key, required this.focusNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moshafTypeState = ref.read(moshafTypeNotifierProvider);
    return moshafTypeState.maybeWhen(
      orElse: () => Container(),
      data: (state) {
        return state.selectedMoshaf.fold(
          () => Container(),
          (selectedMoshaf) {
            final moshafName = switch (selectedMoshaf) {
              MoshafType.warsh => S.of(context).hafs,
              MoshafType.hafs => S.of(context).warsh,
            };
            return InkWell(
              focusNode: focusNode,
              onTap: () async {
                await ref.read(moshafTypeNotifierProvider.notifier).switchMoshafType();
                final quranType = ref.read(moshafTypeNotifierProvider);
                quranType.maybeWhen(
                  orElse: () {},
                  data: (state) {
                    state.selectedMoshaf.fold(
                      () => null,
                      (selectedMoshaf) {
                        log('quran: MoshafSelector: Downloading Quran: ${selectedMoshaf}');
                        return ref.read(downloadQuranNotifierProvider.notifier).downloadQuran(selectedMoshaf);
                      },
                    );
                  },
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    S.of(context).switchQuranType(moshafName),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
