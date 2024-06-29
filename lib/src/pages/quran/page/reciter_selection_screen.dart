import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/data/repository/quran/quran_favorite_impl.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/quran/page/surah_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/widget/reciter_list_view.dart';
import 'package:mawaqit/src/state_management/quran/favorite/quran_favorite_notifier.dart';

import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';

import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';

import 'package:mawaqit/src/pages/quran/widget/quran_background.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import 'package:mawaqit/i18n/l10n.dart';

class ReciterSelectionScreen extends ConsumerStatefulWidget {
  final String surahName;

  const ReciterSelectionScreen({super.key, required this.surahName});

  const ReciterSelectionScreen.withoutSurahName({super.key}) : surahName = '';

  @override
  createState() => _ReciterSelectionScreenState();
}

class _ReciterSelectionScreenState extends ConsumerState<ReciterSelectionScreen> {
  int selectedReciterIndex = 0;
  int selectedReciteTypeIndex = 0;
  FocusNode reciterFocusNode = FocusNode();
  FocusNode reciteTypeFocusNode = FocusNode();
  final ScrollController _reciterScrollController = ScrollController();
  double sizeOfContainerReciter = 15.w;
  double marginOfContainerReciter = 16;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log('FocusScope.of(context).requestFocus(reciterFocusNode)');
      ref.read(reciteNotifierProvider.notifier).getAllReciters();
      FocusScope.of(context).requestFocus(reciterFocusNode);
    });
    // reciterFocusNode.requestFocus(); // Set the initial focus on the reciter grid
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  @override
  void dispose() {
    reciterFocusNode.dispose();
    reciteTypeFocusNode.dispose();
    _reciterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return QuranBackground(
      isSwitch: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          S.of(context).chooseReciter,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      screen: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ref.watch(quranFavoriteNotifierProvider).when(
                        data: (reciter) {
                          if (reciter.favoriteReciters.isNotEmpty) {
                            return Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    l10n.favoriteReciter,
                                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 14),
                                ReciterListView(
                                  onSelected: (index) {
                                    setState(() {
                                      selectedReciterIndex = index;
                                    });
                                  },
                                  isFavoriteButton: false,
                                  reciterList: reciter.favoriteReciters,
                                ),
                                SizedBox(height: 5.h),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                        loading: () => _buildReciterListShimmer(true),
                        error: (error, stackTrace) => Text('Error: $error'),
                      ),
                  Text(
                    l10n.allReciters,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ref.watch(reciteNotifierProvider).when(
                        data: (reciter) => ReciterListView(
                          isFavoriteButton: true,
                          onSelected: (index) {
                            setState(() {
                              selectedReciterIndex = index;
                            });
                          },
                          reciterList: reciter.reciters,
                        ),
                        loading: () => _buildReciterListShimmer(true),
                        error: (error, stackTrace) => Text('Error: $error'),
                      ),
                  SizedBox(height: 5.h),
                  Container(
                    width: double.infinity,
                    child: Text(
                      S.of(context).reciteType,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ref.watch(reciteNotifierProvider).when(
                        data: (reciter) {
                          log('quran:ui: selectedReciterIndex: $selectedReciterIndex, reciter: ${reciter.reciters.length}');
                          return reciter.reciters.isNotEmpty
                              ? _buildReciteTypeGrid(
                                  reciter.reciters[selectedReciterIndex].moshaf,
                                )
                              : _buildReciteTypeGridShimmer(true);
                        },
                        loading: () => _buildReciteTypeGridShimmer(true),
                        error: (error, stackTrace) => Text('Error: $error'),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedButton({required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.white.withOpacity(0.2),
        fixedSize: Size(5.w, 5.w),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 15.sp,
      ),
    );
  }

  void _scrollReciterList(ScrollDirection direction) {
    log('scrollReciterList: $direction');
    final itemWidth = sizeOfContainerReciter + marginOfContainerReciter; // Item width + right margin
    double targetOffset;
    if (direction == ScrollDirection.forward) {
      targetOffset =
          (_reciterScrollController.offset - itemWidth).clamp(0.0, _reciterScrollController.position.maxScrollExtent);
    } else {
      targetOffset =
          (_reciterScrollController.offset + itemWidth).clamp(0.0, _reciterScrollController.position.maxScrollExtent);
    }

    _reciterScrollController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildReciteTypeGrid(List<MoshafModel> reciterTypes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: reciterTypes.length,
      itemBuilder: (context, index) {
        return Focus(
          focusNode: reciteTypeFocusNode,
          child: GestureDetector(
            onTap: () async {
              final reciters = ref.read(reciteNotifierProvider).maybeWhen(
                    data: (data) => data.reciters,
                    orElse: () => [],
                  );
              setState(() {
                selectedReciteTypeIndex = index;
              });
              log('quran:ui: selectedReciteTypeIndex: $selectedReciteTypeIndex');

              ref.read(reciteNotifierProvider.notifier).setSelectedMoshaf(
                    moshafModel: reciterTypes[selectedReciteTypeIndex],
                  );
              log('quran:ui: selectedReciteTypeIndex: ${selectedReciterIndex} ${reciters}');
              ref.read(reciteNotifierProvider.notifier).setSelectedReciter(
                    reciterModel: reciters[selectedReciterIndex],
                  );

              log('quran:ui: getSuwarByReciter: ${reciterTypes[selectedReciteTypeIndex]}');
              ref.read(quranNotifierProvider.notifier).getSuwarByReciter(
                    selectedMoshaf: reciterTypes[selectedReciteTypeIndex],
                  );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurahSelectionScreen(
                    reciterId: reciters[selectedReciterIndex].id,
                    riwayatId: reciterTypes[selectedReciteTypeIndex].moshafType,
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selectedReciteTypeIndex == index ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  reciterTypes[index].name,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 1.6.vwr,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleKeyEvent(RawKeyEvent value) {
    if (!mounted) return;
    log('native_key_event $value');
    if (value is RawKeyDownEvent && !value.repeat) {
      final List<ReciterModel> reciters = ref.read(reciteNotifierProvider).maybeWhen(
            data: (data) => data.reciters,
            orElse: () => [],
          );
      // log('reciters: $reciters');
      log('native_key_event: ${reciterFocusNode.hasFocus} || ${reciteTypeFocusNode.hasFocus}');
      if (reciterFocusNode.hasFocus) {
        _handleReciteKeyEvent(value, reciters);
      } else if (reciteTypeFocusNode.hasFocus) {
        _handleReciteTypeKeyEvent(value, reciters, reciters[selectedReciterIndex].moshaf);
      }
    }
  }

  void _handleReciteKeyEvent(RawKeyEvent value, List<ReciterModel> reciters) {
    log('_handleReciteKeyEvent: key_event: $value');
    if (value is RawKeyDownEvent) {
      if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (selectedReciterIndex < reciters.length - 1) {
          setState(() {
            selectedReciterIndex++;
            _animateToReciter(selectedReciterIndex, value.logicalKey);
          });
        }
      } else if (value.logicalKey == LogicalKeyboardKey.arrowLeft) {
        log('_handleReciteKeyEvent: selected_index: arrowLeft $selectedReciteTypeIndex');
        if (selectedReciterIndex > 0) {
          setState(() {
            selectedReciterIndex--;
            _animateToReciter(selectedReciterIndex, value.logicalKey);
          });
        }
      } else if (value.logicalKey == LogicalKeyboardKey.select) {
        log('selected_logicalKey: ${reciters[selectedReciterIndex]}');
        FocusScope.of(context).unfocus();
        FocusScope.of(context).requestFocus(reciteTypeFocusNode);
        setState(() {
          selectedReciteTypeIndex = 0;
        });
      }
    }
  }

  void _handleReciteTypeKeyEvent(RawKeyEvent value, List<ReciterModel> reciters, List<MoshafModel> reciterTypes) {
    log('_handleReciteTypeKeyEvent: $value');
    if (value is RawKeyDownEvent) {
      if (reciteTypeFocusNode.hasFocus) {
        if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
          log('_handleKeyEvent: selected_index: arrowRight $selectedReciteTypeIndex || ${reciters[selectedReciterIndex].moshaf.length - 1}');
          if (selectedReciteTypeIndex < reciters[selectedReciterIndex].moshaf.length - 1) {
            setState(() {
              selectedReciteTypeIndex++;
            });
          }
        } else if (value.logicalKey == LogicalKeyboardKey.arrowLeft) {
          log('_handleKeyEvent: selected_index: arrowLeft $selectedReciteTypeIndex');
          if (selectedReciteTypeIndex > 0) {
            setState(() {
              selectedReciteTypeIndex--;
            });
          }
        } else if (value.logicalKey == LogicalKeyboardKey.select) {
          setState(() {
            selectedReciteTypeIndex = selectedReciteTypeIndex;
          });
          log('begin 1 selectedReciteTypeIndex: $selectedReciteTypeIndex');

          ref.read(reciteNotifierProvider.notifier).setSelectedMoshaf(
                moshafModel: reciters[selectedReciterIndex].moshaf[selectedReciterIndex],
              );
          log('begin 3 selectedReciteTypeIndex: $selectedReciteTypeIndex');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurahSelectionScreen(
                reciterId: reciters[selectedReciterIndex].id,
                riwayatId: reciterTypes[selectedReciteTypeIndex].moshafType,
              ),
            ),
          );
        }
      }
    }
  }

  void _animateToReciter(int index, LogicalKeyboardKey direction) {
    final itemWidth = sizeOfContainerReciter + marginOfContainerReciter; // Item width + right margin
    final targetOffset = (index) * itemWidth;

    _reciterScrollController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildReciterListShimmer(bool isDarkMode) {
    return Container(
      height: 16.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        itemBuilder: (context, index) {
          return Container(
            width: 25.w,
            margin: EdgeInsets.only(right: marginOfContainerReciter),
            child: Shimmer.fromColors(
              baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return ref.watch(reciteNotifierProvider).maybeWhen(
          data: (recitersList) {
            final reciters = recitersList.reciters;
            final isFavorite = ref.watch(quranFavoriteNotifierProvider).maybeWhen(
                  data: (reciter) =>
                      reciter.favoriteReciters.map((e) => e.id).contains(reciters[selectedReciterIndex].id),
                  orElse: () => false,
                );
            return ElevatedButton(
              onPressed: () {
                log('quran:ui: isFavorite: $isFavorite ${selectedReciterIndex}');
                if (reciters.isEmpty) return;
                ref.read(quranFavoriteNotifierProvider.notifier).saveFavoriteReciter(
                      reciterId: reciters[selectedReciterIndex].id,
                    );
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: isFavorite ? Colors.white.withOpacity(0.2) : Colors.red,
                fixedSize: Size(5.w, 5.w),
              ),
              child: Icon(
                isFavorite ? Icons.favorite_border : Icons.favorite,
                color: Colors.white,
                size: 15.sp,
              ),
            );
          },
          orElse: () => Container(),
        );
  }

  Widget _buildReciteTypeGridShimmer(bool isDarkMode) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }
}