import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';
import 'package:mawaqit/src/pages/quran/widget/quran_background.dart';
import 'package:mawaqit/src/pages/quran/widget/surah_card.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';

import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';
import 'package:shimmer/shimmer.dart';

import 'package:mawaqit/src/state_management/quran/recite/quran_audio_player_notifier.dart';
import 'package:mawaqit/src/pages/quran/page/quran_player_screen.dart';
import 'package:sizer/sizer.dart';

class SurahSelectionScreen extends ConsumerStatefulWidget {
  final MoshafModel selectedMoshaf;

  const SurahSelectionScreen({
    required this.selectedMoshaf,
    super.key,
  });

  @override
  ConsumerState createState() => _SurahSelectionScreenState();
}

class _SurahSelectionScreenState extends ConsumerState<SurahSelectionScreen> {
  int selectedIndex = 0;
  final int _crossAxisCount = 4;
  final ScrollController _scrollController = ScrollController();
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    _searchFocusNode = FocusNode();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranState = ref.watch(quranNotifierProvider);
    ref.listen(navigateIntoNewPageProvider, (previous, next) {
      if (next) {
        RawKeyboard.instance.removeListener(_handleKeyEvent);
      } else {
        RawKeyboard.instance.addListener(_handleKeyEvent);
      }
    });
    return QuranBackground(
      isSwitch: false,
      screen: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExcludeFocus(
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: quranState.when(
                    data: (data) {
                      return GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        controller: _scrollController,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _crossAxisCount,
                          childAspectRatio: 1.8,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: data.suwar.length,
                        itemBuilder: (context, index) {
                          return SurahCard(
                            surahName: data.suwar[index].name,
                            surahNumber: data.suwar[index].id,
                            isSelected: index == selectedIndex,
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                              final moshaf = ref.read(reciteNotifierProvider).maybeWhen(
                                    orElse: () => null,
                                    data: (data) => data.selectedMoshaf,
                                  );
                              ref.read(quranPlayerNotifierProvider.notifier).initialize(
                                    moshaf: widget.selectedMoshaf,
                                    surah: data.suwar[index],
                                    suwar: data.suwar,
                                  );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuranPlayerScreen(),
                                ),
                              );
                              _scrollToSelectedItem();
                            },
                          );
                        },
                      );
                    },
                    error: (error, stack) {
                      log('Error: $error\n$stack');
                      return Center(
                        child: Text(
                          'Error: $error',
                        ),
                      );
                    },
                    loading: () => _buildShimmerGrid(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleKeyEvent(RawKeyEvent event) {
    final surahs = ref.read(quranNotifierProvider).maybeWhen(orElse: () => [], data: (data) => data.suwar);
    final textDirection = Directionality.of(context);

    if (event is RawKeyDownEvent) {
      log('Key pressed: ${event.logicalKey}');
      if (event.logicalKey == LogicalKeyboardKey.select) {
        _searchFocusNode.requestFocus();
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          if (textDirection == TextDirection.ltr) {
            selectedIndex = (selectedIndex + 1) % surahs.length;
          } else {
            selectedIndex = (selectedIndex - 1 + surahs.length) % surahs.length;
          }
        });
        _scrollToSelectedItem();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          if (textDirection == TextDirection.ltr) {
            selectedIndex = (selectedIndex - 1) % surahs.length;
          } else {
            selectedIndex = (selectedIndex + 1 + surahs.length) % surahs.length;
          }
        });
        _scrollToSelectedItem();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (selectedIndex < _crossAxisCount) {
          // _searchFocusNode.requestFocus();
        } else {
          setState(() {
            selectedIndex = (selectedIndex - _crossAxisCount + surahs.length) % surahs.length;
          });
          _scrollToSelectedItem();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          selectedIndex = (selectedIndex + _crossAxisCount) % surahs.length;
        });
        _scrollToSelectedItem();
      } else if (event.logicalKey == LogicalKeyboardKey.select) {
        _handleSurahSelection(surahs[selectedIndex]);
      }
    }
  }

  void _handleSurahSelection(SurahModel selectedSurah) {
    final moshaf = ref.read(reciteNotifierProvider).maybeWhen(
          orElse: () => null,
          data: (data) => data.selectedMoshaf,
        );
    final quranState = ref.read(quranNotifierProvider);

    quranState.maybeWhen(
      orElse: () {},
      data: (data) {
        ref.read(quranPlayerNotifierProvider.notifier).initialize(
              moshaf: widget.selectedMoshaf,
              surah: selectedSurah,
              suwar: data.suwar,
            );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(navigateIntoNewPageProvider.notifier).state = true;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuranPlayerScreen(),
            ),
          ).then((_) {
            ref.read(navigateIntoNewPageProvider.notifier).state = false;
          });
        });
      },
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        childAspectRatio: 1.8,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: 20, // Adjust the count as needed
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[700]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  void _scrollToSelectedItem() {
    final surahs = ref.read(quranNotifierProvider).maybeWhen(orElse: () => [], data: (data) => data.suwar);
    final int rowIndex = selectedIndex ~/ _crossAxisCount;
    final double itemHeight = _scrollController.position.maxScrollExtent / ((surahs.length - 1) / _crossAxisCount);
    final double targetOffset = rowIndex * itemHeight;
    _scrollController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }
}

final navigateIntoNewPageProvider = StateProvider.autoDispose<bool>((ref) => false);
