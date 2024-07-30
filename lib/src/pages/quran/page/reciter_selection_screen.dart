import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/quran/page/quran_reading_screen.dart';
import 'package:mawaqit/src/pages/quran/page/surah_selection_screen.dart';
import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/pages/quran/widget/quran_background.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late FocusNode floatingActionButtonFocusNode;
  final ScrollController _reciterScrollController = ScrollController();
  double sizeOfContainerReciter = 15.w;
  double marginOfContainerReciter = 16;
  List<ReciterModel> reciters = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reciteNotifierProvider.notifier).getAllReciters();
      if (mounted) {
        FocusScope.of(context).requestFocus(reciterFocusNode);
      }
    });
    floatingActionButtonFocusNode = FocusNode(debugLabel: 'Floating Action Button');
    reciterFocusNode = FocusNode(debugLabel: 'Reciter');
    reciteTypeFocusNode = FocusNode(debugLabel: 'Recite Type');
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    // reciterFocusNode.dispose();
    reciteTypeFocusNode.dispose();
    floatingActionButtonFocusNode.dispose();
    _reciterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuranBackground(
      key: _scaffoldKey,
      isSwitch: true,
      floatingActionButtonFocusNode: floatingActionButtonFocusNode,
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
                  ref.watch(reciteNotifierProvider).when(
                        data: (reciter) => _buildReciterList(reciter.reciters),
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

  Widget _buildReciterList(List<ReciterModel> reciterNames) {
    return Container(
      height: 16.h,
      child: Stack(
        children: [
          Positioned.fill(
            child: ListView.builder(
              controller: _reciterScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: reciterNames.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedReciterIndex = index;
                    });
                  },
                  child: _reciterCard(index, reciterNames),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Container _reciterCard(int index, List<ReciterModel> reciterNames) {
    return Container(
      width: 25.w,
      margin: EdgeInsets.only(right: marginOfContainerReciter),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: selectedReciterIndex == index
            ? Border.all(
                color: Colors.white,
                width: 2,
              )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFF490094),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
            ),
            Image.asset(
              R.ASSETS_IMG_QURAN_DEFAULT_AVATAR_PNG,
              width: 17.w,
              fit: BoxFit.fitWidth,
            ),
            Spacer(),
            FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  reciterNames[index].name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ],
        ),
      ),
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
        FocusNode reciteTypeItemFocusNode = FocusNode();
        return Focus(
          focusNode: reciteTypeItemFocusNode,
          child: GestureDetector(
            onTap: () async {
              final reciters = ref.read(reciteNotifierProvider).maybeWhen(
                    data: (data) => data.reciters,
                    orElse: () => [],
                  );
              setState(() {
                selectedReciteTypeIndex = index;
              });

              ref.read(reciteNotifierProvider.notifier).setSelectedMoshaf(
                    moshafModel: reciterTypes[selectedReciteTypeIndex],
                  );
              ref.read(reciteNotifierProvider.notifier).setSelectedReciter(
                    reciterModel: reciters[selectedReciterIndex],
                  );

              ref.read(quranNotifierProvider.notifier).getSuwarByReciter(
                    selectedMoshaf: reciterTypes[selectedReciteTypeIndex],
                  );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurahSelectionScreen(),
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
    if (value is RawKeyDownEvent) {
      final List<ReciterModel> reciters = ref.read(reciteNotifierProvider).maybeWhen(
            data: (data) => data.reciters,
            orElse: () => [],
          );
      if (reciterFocusNode.hasFocus) {
        _handleReciteKeyEvent(value, reciters);
      } else if (reciteTypeFocusNode.hasFocus) {
        _handleReciteTypeKeyEvent(value, reciters, reciters[selectedReciterIndex].moshaf);
      } else if (floatingActionButtonFocusNode.hasFocus) {
        _handleFloatingActionButtonKeyEvent(value);
      }
    }
  }

  void _handleReciteKeyEvent(RawKeyEvent value, List<ReciterModel> reciters) {
    if (!mounted || reciters.isEmpty) return;
    if (value is RawKeyDownEvent) {
      if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (selectedReciterIndex < reciters.length - 1) {
          setState(() {
            selectedReciterIndex++;
            _animateToReciter(selectedReciterIndex, value.logicalKey);
          });
        }
      } else if (value.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (selectedReciterIndex > 0) {
          setState(() {
            selectedReciterIndex--;
            _animateToReciter(selectedReciterIndex, value.logicalKey);
          });
        }
      } else if (value.logicalKey == LogicalKeyboardKey.select) {
        FocusScope.of(context).unfocus();
        FocusScope.of(context).requestFocus(reciteTypeFocusNode);
        setState(() {
          selectedReciteTypeIndex = 0;
        });
      } else if (value.logicalKey == LogicalKeyboardKey.arrowDown) {
        FocusScope.of(context).unfocus();
        FocusScope.of(context).requestFocus(reciteTypeFocusNode);
        setState(() {
          selectedReciteTypeIndex = 0;
        });
      }
    }
  }

  void _handleReciteTypeKeyEvent(RawKeyEvent value, List<ReciterModel> reciters, List<MoshafModel> reciterTypes) {
    if (!mounted || reciters.isEmpty || reciterTypes.isEmpty) return;
    if (value is RawKeyDownEvent) {
      if (reciteTypeFocusNode.hasFocus) {
        if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
          if (selectedReciteTypeIndex < reciters[selectedReciterIndex].moshaf.length - 1) {
            setState(() {
              selectedReciteTypeIndex++;
            });
          }
        } else if (value.logicalKey == LogicalKeyboardKey.arrowLeft) {
          if (selectedReciteTypeIndex > 0) {
            setState(() {
              selectedReciteTypeIndex--;
            });
          }
        } else if (value.logicalKey == LogicalKeyboardKey.select) {
          setState(() {
            selectedReciteTypeIndex = selectedReciteTypeIndex;
          });
          ref.read(reciteNotifierProvider.notifier).setSelectedMoshaf(
                moshafModel: reciterTypes[selectedReciteTypeIndex],
              );
          ref.read(reciteNotifierProvider.notifier).setSelectedReciter(
                reciterModel: reciters[selectedReciterIndex],
              );
          ref.read(quranNotifierProvider.notifier).getSuwarByReciter(
                selectedMoshaf: reciterTypes[selectedReciteTypeIndex],
              );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurahSelectionScreen(),
            ),
          );
        } else if (value.logicalKey == LogicalKeyboardKey.arrowUp) {
          FocusScope.of(context).unfocus();
          FocusScope.of(context).requestFocus(reciterFocusNode);
          setState(() {
            selectedReciteTypeIndex = 0;
          });
        } else if (value.logicalKey == LogicalKeyboardKey.arrowDown) {
          FocusScope.of(context).requestFocus(floatingActionButtonFocusNode);
        }
      }
    }
  }

  void _handleFloatingActionButtonKeyEvent(RawKeyEvent value) {
    if (!mounted) return;
    if (value is RawKeyDownEvent) {
      if (value.logicalKey == LogicalKeyboardKey.arrowUp) {
        FocusScope.of(context).requestFocus(reciteTypeFocusNode);
      } else if (value.logicalKey == LogicalKeyboardKey.select || value.logicalKey == LogicalKeyboardKey.enter) {
        ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.reading);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuranReadingScreen(),
          ),
        );
      }
    }
  }

  void _animateToReciter(int index, LogicalKeyboardKey direction) {
    final itemWidth = sizeOfContainerReciter + marginOfContainerReciter;
    final targetOffset = (index) * itemWidth * 1.5;

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
