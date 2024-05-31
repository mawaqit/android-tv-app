import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/widget/switch_button.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_notifer.dart';

import 'package:mawaqit/src/pages/quran/widget/download_quran_popup.dart';
import 'package:sizer/sizer.dart';

import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';


import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_notifier.dart';

import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';

import 'package:mawaqit/i18n/l10n.dart';

class QuranReadingScreen extends ConsumerStatefulWidget {
  const QuranReadingScreen({super.key});

  @override
  ConsumerState createState() => _QuranReadingScreenState();
}

class _QuranReadingScreenState extends ConsumerState<QuranReadingScreen> {
  int quranIndex = 0;
  late PageController _pageController;
  late FocusNode _leftFocusNode;
  late FocusNode _rightFocusNode;

  @override
  void initState() {
    super.initState();
    _leftFocusNode = FocusNode();
    _rightFocusNode = FocusNode();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDownloadQuranAlertDialog(context, ref);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _leftFocusNode.dispose();
    _rightFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranReadingState = ref.watch(quranReadingNotifierProvider);
    ref.listen(quranReadingNotifierProvider, (previous, next) async {
      if (next.hasValue && next.value!.isInitial) {
        await Future.delayed(Duration(milliseconds: 500));
        log('quran: QuranReadingScreen: Current page: ${next}');
        _pageController.jumpToPage(
          (next.value!.currentPage),
        );
        log('quran: QuranReadingScreen: Current page: final ${next}');
      }
    });

    ref.listen(downloadQuranNotifierProvider, (previous, next) {
      if (!next.hasValue || next.value is Success) {
        log('quran: QuranReadingScreen: Downloaded quran');
        ref.invalidate(quranReadingNotifierProvider);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
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
          log('quran: QuranReadingScreen: total ${quranReadingState.totalPages}, '
              'currentPage: ${quranReadingState.currentPage}');
          return Stack(
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      quranIndex = index;
                      ref.read(quranReadingNotifierProvider.notifier).updatePage(index);
                    },
                    itemCount: (quranReadingState.totalPages / 2).ceil(),
                    itemBuilder: (context, index) {
                      final leftPageIndex = index * 2;
                      final rightPageIndex = leftPageIndex + 1;
                      return Stack(
                        children: [
                          // Left Page
                          if (leftPageIndex < quranReadingState.svgs.length)
                            Positioned(
                              left: 12.w,
                              top: 0,
                              bottom: 0,
                              right: MediaQuery.of(context).size.width / 2,
                              child: _buildSvgPicture(
                                  quranReadingState.svgs[rightPageIndex % quranReadingState.svgs.length]),
                            ),
                          // Right Page
                          if (rightPageIndex < quranReadingState.svgs.length)
                            Positioned(
                              right: 12.w,
                              top: 0,
                              bottom: 0,
                              left: MediaQuery.of(context).size.width / 2,
                              child: _buildSvgPicture(
                                quranReadingState.svgs[leftPageIndex % quranReadingState.svgs.length],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child: SwitchButton(
                  iconSize: 14.sp,
                  opacity: 0.7,
                  icon: _getBackIcon(context),
                  onPressed: () => _scrollPageList(ScrollDirection.reverse),
                ),
              ),
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: SwitchButton(
                  opacity: 0.7,
                  iconSize: 14.sp,
                  icon: _getForwardIcon(context),
                  onPressed: () => _scrollPageList(ScrollDirection.forward),
                ),
              ),
              Positioned(
                left: Directionality.of(context) == TextDirection.rtl ? null : 10,
                top: 10,
                child: SwitchButton(
                  opacity: 0.7,
                  iconSize: 14.sp,
                  icon: Icons.arrow_back_rounded,
                  onPressed: () {
                    log('quran: QuranReadingScreen: back');
                    Navigator.pop(context);
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 5,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      S.of(context).quranReadingPage(
                            quranReadingState.currentPage * 2 + 1,
                            quranReadingState.currentPage * 2 + 2,
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
            ],
          );
        },
      ),
    );
  }

  void _scrollPageList(ScrollDirection direction) {
    if (direction == ScrollDirection.forward) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  Widget _buildSvgPicture(SvgPicture svgPicture) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(8.0),
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
    return Directionality.of(context) == TextDirection.rtl ? Icons.arrow_forward : Icons.arrow_back;
  }

  IconData _getForwardIcon(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl ? Icons.arrow_back : Icons.arrow_forward;
  }
}
