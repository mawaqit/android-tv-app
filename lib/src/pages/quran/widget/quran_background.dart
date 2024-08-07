import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/pages/quran/page/quran_reading_screen.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:sizer/sizer.dart';

import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';

import '../../../state_management/quran/quran/quran_state.dart';

class QuranBackground extends ConsumerWidget {
  final Widget screen;
  final AppBar? appBar;
  final bool isSwitch;
  final FocusNode? floatingActionButtonFocusNode;

  const QuranBackground({
    super.key,
    required this.screen,
    this.isSwitch = false,
    this.appBar,
    this.floatingActionButtonFocusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return appBar != null
        ? SafeArea(
            child: Scaffold(
              floatingActionButton: !isSwitch
                  ? null
                  : SizedBox(
                      width: 40.sp, // Set the desired width
                      height: 40.sp, // Set the desired height
                      child: FloatingActionButton(
                        focusNode: floatingActionButtonFocusNode,
                        backgroundColor: floatingActionButtonFocusNode?.hasFocus == true
                            ? Colors.cyan
                            : Colors.black.withOpacity(.5),
                        child: Icon(
                          Icons.menu_book,
                          color: Colors.white,
                          size: 15.sp,
                        ),
                        onPressed: () async {
                          ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.reading);
                          log('quran: QuranBackground: Switch to reading');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuranReadingScreen(),
                            ),
                          );
                        },
                      ),
                    ),
              extendBodyBehindAppBar: true,
              appBar: appBar,
              body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(R.ASSETS_BACKGROUNDS_QURAN_BACKGROUND_PNG),
                    fit: BoxFit.cover,
                  ),
                  gradient: ThemeNotifier.quranBackground(),
                ),
                padding: EdgeInsets.only(top: 5.h),
                child: screen,
              ),
            ),
          )
        : SafeArea(
            child: Scaffold(
              floatingActionButton: !isSwitch
                  ? null
                  : SizedBox(
                      width: 40.sp, // Set the desired width
                      height: 40.sp, // Set the desired height
                      child: FloatingActionButton(
                        focusNode: floatingActionButtonFocusNode,
                        backgroundColor: floatingActionButtonFocusNode?.hasFocus == true
                            ? Colors.cyan
                            : Colors.black.withOpacity(.5),
                        child: Icon(
                          Icons.menu_book,
                          color: Colors.white,
                          size: 15.sp,
                        ),
                        onPressed: () async {
                          ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.reading);
                          log('quran: QuranBackground: Switch to reading');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuranReadingScreen(),
                            ),
                          );
                        },
                      ),
                    ),
              body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(R.ASSETS_BACKGROUNDS_QURAN_BACKGROUND_PNG),
                    fit: BoxFit.cover,
                  ),
                  gradient: ThemeNotifier.quranBackground(),
                ),
                child: screen,
              ),
            ),
          );
  }
}
