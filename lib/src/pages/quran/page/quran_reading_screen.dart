import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      ref.read(quranReadingNotifierProvider);
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
          return Stack(
            children: [
              PageView.builder(
                reverse: true,
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
                  return Stack(
                    children: [
                      // Left Page
                      if (leftPageIndex < quranReadingState.svgs.length)
                        Positioned(
                          left: 12.w,
                          top: 0,
                          bottom: 0,
                          right: MediaQuery.of(context).size.width / 2,
                          child:
                              _buildSvgPicture(quranReadingState.svgs[leftPageIndex % quranReadingState.svgs.length]),
                        ),
                      // Right Page
                      if (rightPageIndex < quranReadingState.svgs.length)
                        Positioned(
                          right: 12.w,
                          top: 0,
                          bottom: 0,
                          left: MediaQuery.of(context).size.width / 2,
                          child:
                              _buildSvgPicture(quranReadingState.svgs[rightPageIndex % quranReadingState.svgs.length]),
                        ),
                    ],
                  );
                },
              ),
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child: SwitchButton(
                  iconSize: 18.sp,
                  opacity: 0.7,
                  icon: Icons.arrow_left,
                  onPressed: () => _scrollPageList(ScrollDirection.reverse),
                ),
              ),
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: SwitchButton(
                  opacity: 0.7,
                  iconSize: 18.sp,
                  icon: Icons.arrow_right,
                  onPressed: () => _scrollPageList(ScrollDirection.forward),
                ),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: SwitchButton(
                  opacity: 0.7,
                  iconSize: 15.sp,
                  icon: Icons.arrow_back_rounded,
                  onPressed: () {
                    log('quran: QuranReadingScreen: back');
                    Navigator.pop(context);
                  },
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
      ref.read(quranReadingNotifierProvider.notifier).previousPage();
    } else {
      ref.read(quranReadingNotifierProvider.notifier).nextPage();
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
}
