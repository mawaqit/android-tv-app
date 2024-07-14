import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/data/repository/quran/quran_download_impl.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/widget/switch_button.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_notifer.dart';

import 'package:mawaqit/src/pages/quran/widget/download_quran_popup.dart';
import 'package:sizer/sizer.dart';

import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';

class QuranReadingScreen extends ConsumerStatefulWidget {
  const QuranReadingScreen({super.key});

  @override
  ConsumerState createState() => _QuranReadingScreenState();
}

class _QuranReadingScreenState extends ConsumerState<QuranReadingScreen> {
  int quranIndex = 0;
  late FocusNode _backButtonFocusNode;
  late FocusNode _listeningModeFocusNode;

  @override
  void initState() {
    super.initState();
    _backButtonFocusNode = FocusNode();
    _listeningModeFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDownloadQuranAlertDialog(context, ref);
      ref.read(quranReadingNotifierProvider);
    });
  }

  @override
  void dispose() {
    _listeningModeFocusNode.dispose();
    _backButtonFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _scrollPageList(ScrollDirection.reverse);
        _backButtonFocusNode.unfocus();
        _listeningModeFocusNode.unfocus();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _scrollPageList(ScrollDirection.forward);
        _listeningModeFocusNode.unfocus();
        _backButtonFocusNode.unfocus();
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _listeningModeFocusNode.requestFocus();
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _backButtonFocusNode.requestFocus();
      }
    }
  }

  FloatingActionButtonLocation _getFloatingActionButtonLocation(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    switch (textDirection) {
      case TextDirection.ltr:
        return FloatingActionButtonLocation.endFloat;
      case TextDirection.rtl:
        return FloatingActionButtonLocation.startFloat;
      default:
        return FloatingActionButtonLocation.endFloat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final quranReadingState = ref.watch(quranReadingNotifierProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: _getFloatingActionButtonLocation(context),
      floatingActionButton: SizedBox(
        width: 30.sp, // Set the desired width
        height: 30.sp, //
        child: FloatingActionButton(
          backgroundColor: Colors.black.withOpacity(.3),
          child: Icon(
            Icons.headset,
            color: Colors.white,
            size: 15.sp,
          ),
          onPressed: () async {
            ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.listening);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ReciterSelectionScreen.withoutSurahName(),
              ),
            );
          },
        ),
      ),
      body: quranReadingState.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, s) => Center(child: Text('Error: $error')),
        data: (quranReadingState) {
          return RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: _handleKeyEvent,
            child: Stack(
              children: [
                PageView.builder(
                  reverse: Directionality.of(context) == TextDirection.ltr ? true : false,
                  controller: quranReadingState.pageController,
                  onPageChanged: (index) {
                    final actualPage = index * 2;
                    if (actualPage != quranReadingState.currentPage) {
                      ref.read(quranReadingNotifierProvider.notifier).updatePage(actualPage);
                    }
                  },
                  itemCount: (quranReadingState.totalPages / 2).ceil(),
                  itemBuilder: (context, index) {
                    final leftPageIndex = index * 2;
                    final rightPageIndex = leftPageIndex + 1;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final pageWidth = constraints.maxWidth / 2;
                        final pageHeight = constraints.maxHeight;
                        final bottomPadding = pageHeight * 0.05; // 5% of screen height for bottom padding

                        return Stack(
                          children: [
                            // Right Page (now on the left)
                            if (rightPageIndex < quranReadingState.svgs.length)
                              Positioned(
                                left: 12.w,
                                top: 0,
                                bottom: bottomPadding,
                                width: pageWidth * 0.9,
                                child: _buildSvgPicture(
                                  quranReadingState.svgs[rightPageIndex % quranReadingState.svgs.length],
                                ),
                              ),
                            // Left Page (now on the right)
                            if (leftPageIndex < quranReadingState.svgs.length)
                              Positioned(
                                right: 12.w,
                                top: 0,
                                bottom: bottomPadding,
                                width: pageWidth * 0.9,
                                child: _buildSvgPicture(
                                  quranReadingState.svgs[leftPageIndex % quranReadingState.svgs.length],
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: SwitchButton(
                    opacity: 0.7,
                    iconSize: 14.sp,
                    icon: Directionality.of(context) == TextDirection.ltr
                        ? Icons.arrow_forward_ios
                        : Icons.arrow_back_ios,
                    onPressed: () => _scrollPageList(ScrollDirection.forward),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: SwitchButton(
                    opacity: 0.7,
                    iconSize: 14.sp,
                    icon: Directionality.of(context) != TextDirection.ltr
                        ? Icons.arrow_forward_ios
                        : Icons.arrow_back_ios,
                    onPressed: () => _scrollPageList(ScrollDirection.reverse),
                  ),
                ),
                // Page Number
                Positioned(
                  left: 15.w,
                  right: 15.w,
                  bottom: 1.h,
                  child: GestureDetector(
                    onTap: () => _showPageSelector(
                      context,
                      quranReadingState.totalPages,
                      quranReadingState.currentPage,
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          S.of(context).quranReadingPage(
                                quranReadingState.currentPage + 1, // Right page (now on the left)
                                quranReadingState.currentPage + 2, // Left page (now on the right)
                                quranReadingState.totalPages,
                              ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // back button
                Positioned(
                  left: Directionality.of(context) == TextDirection.ltr ? 10 : null,
                  right: Directionality.of(context) == TextDirection.rtl ? 10 : null,
                  child: SwitchButton(
                    opacity: 0.7,
                    iconSize: 17.sp,
                    icon: Directionality.of(context) == TextDirection.ltr
                        ? Icons.arrow_back_rounded
                        : Icons.arrow_back_rounded,
                    onPressed: () {
                      log('quran: QuranReadingScreen: back');
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _scrollPageList(ScrollDirection direction) {
    if (direction == ScrollDirection.forward) {
      ref.read(quranReadingNotifierProvider.notifier).previousPage();
    } else {
      ref.read(quranReadingNotifierProvider.notifier).nextPage();
    }
  }

  Widget _buildSvgPicture(SvgPicture svgPicture) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(32.0),
      child: SvgPicture(
        svgPicture.bytesLoader,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
      ),
    );
  }

  IconData _getBackIcon(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios;
  }

  IconData _getForwardIcon(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl ? Icons.arrow_back_ios : Icons.arrow_forward_ios;
  }

  void _showPageSelector(BuildContext context, int totalPages, int currentPage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: SizedBox(
            width: double.maxFinite,
            child: Text(
              S.of(context).chooseQuranPage,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                childAspectRatio: 3 / 2,
              ),
              itemCount: totalPages,
              itemBuilder: (BuildContext context, int index) {
                final isSelected = index == currentPage;
                return GestureDetector(
                  onTap: () {
                    // Update to use the correct page number
                    ref.read(quranReadingNotifierProvider.notifier).updatePage(index);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).focusColor : null,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: isSelected ? FontWeight.bold : null,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
