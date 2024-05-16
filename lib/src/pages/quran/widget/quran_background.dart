import 'package:flutter/material.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:sizer/sizer.dart';

class QuranBackground extends StatelessWidget {
  final Widget screen;
  final AppBar? appBar;

  const QuranBackground({
    super.key,
    required this.screen,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return appBar != null
        ? Scaffold(
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
          )
        : Scaffold(
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
          );
  }
}
