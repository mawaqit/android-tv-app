import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/pages/quran/page/surah_selection_screen.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';
import 'package:sizer/sizer.dart';

class ReciteTypeGridView extends ConsumerStatefulWidget {
  const ReciteTypeGridView({
    super.key,
    required this.reciterTypes,
  });

  final List<MoshafModel> reciterTypes;

  @override
  ConsumerState createState() => _ReciteTypeGridViewState();
}

class _ReciteTypeGridViewState extends ConsumerState<ReciteTypeGridView> {
  int selectedReciteTypeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.reciterTypes.length,
      itemBuilder: (context, index) {
        return InkWell(
          autofocus: FocusScope.of(context).hasFocus && index == 0,
          hoverColor: Colors.transparent,
          focusColor: Colors.green,
          onTap: () {
            setState(() {
              selectedReciteTypeIndex = index;
            });
            // Perform actions related to the selected recite type
            ref.read(reciteNotifierProvider.notifier).setSelectedMoshaf(
                  moshafModel: widget.reciterTypes[selectedReciteTypeIndex],
                );

            ref.read(quranNotifierProvider.notifier).getSuwarByReciter(
                  selectedMoshaf: widget.reciterTypes[selectedReciteTypeIndex],
                );

            final Option<ReciterModel> selectedReciterId = ref.watch(reciteNotifierProvider).maybeWhen(
                  orElse: () => none(),
                  data: (reciterState) => reciterState.selectedReciter,
                );
            selectedReciterId.fold(
              () => null,
              (reciter) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurahSelectionScreen(
                    reciterId: reciter.id.toString(),
                    selectedMoshaf: widget.reciterTypes[selectedReciteTypeIndex],
                  ),
                ),
              ),
            );
          },
          child: Builder(
            builder: (context) {
              final isFocused = Focus.of(context).hasFocus;
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: isFocused
                      ? Border.all(
                          color: Colors.white,
                          width: 2,
                        )
                      : null,
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    widget.reciterTypes[index].name,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 8.sp,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
