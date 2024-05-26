import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_notifer.dart';

import 'package:mawaqit/src/pages/quran/widget/download_quran_popup.dart';
import 'package:rive_splash_screen/rive_splash_screen.dart';
import 'package:sizer/sizer.dart';

import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';

import 'package:mawaqit/src/pages/SplashScreen.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Splash()));
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: SizedBox(
        width: 40.sp, // Set the desired width
        height: 40.sp, //
        child: FloatingActionButton(
          backgroundColor: Colors.black.withOpacity(.5),
          child: Icon(
            Icons.headset,
            color: Colors.white,
            size: 15.sp,
          ),
          onPressed: () async {
            ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.listening);
          },
        ),
      ),
      body: quranReadingState.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, s) => Center(child: Text('Error: $error')),
        data: (quranReadingState) {
          log('quran: QuranReadingScreen: total ${quranReadingState.totalPages}, '
              'currentPage: ${quranReadingState.currentPage}');
          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        quranIndex = index;
                        ref.read(quranReadingNotifierProvider.notifier).updatePage(index);
                      },
                      itemCount: (quranReadingState.totalPages / 2).ceil(),
                      itemBuilder: (context, index) {
                        final leftPageIndex = index * 2;
                        final rightPageIndex = leftPageIndex + 1;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (leftPageIndex < quranReadingState.svgs.length)
                              Expanded(
                                flex: 1,
                                child: _buildSvgPicture(
                                    quranReadingState.svgs[leftPageIndex % quranReadingState.svgs.length]),
                              ),
                            if (rightPageIndex < quranReadingState.svgs.length)
                              Expanded(
                                flex: 1,
                                child: _buildSvgPicture(
                                    quranReadingState.svgs[rightPageIndex % quranReadingState.svgs.length]),
                              ),
                          ],
                        );
                      },
                    ),
                    Positioned(
                      left: 10,
                      top: 0,
                      bottom: 0,
                      child: _buildRoundedButton(
                        icon: Icons.arrow_left,
                        onPressed: () => _scrollPageList(ScrollDirection.forward),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 0,
                      bottom: 0,
                      child: _buildRoundedButton(
                        icon: Icons.arrow_right,
                        onPressed: () => _scrollPageList(ScrollDirection.reverse),
                      ),
                    ),
                  ],
                ),
              ),
              // _buildNavigationButtons(quranReadingState),
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

  Widget _buildRoundedButton({required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.black.withOpacity(.5),
        fixedSize: Size(5.w, 5.w),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 15.sp,
      ),
    );
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
