import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:sizer/sizer.dart';

import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';

import '../../../state_management/quran/quran/quran_state.dart';

class QuranBackground extends ConsumerWidget {
  final Widget screen;
  final AppBar? appBar;

  const QuranBackground({
    super.key,
    required this.screen,
    this.appBar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return appBar != null
        ? SafeArea(
            child: Scaffold(
              floatingActionButton: SizedBox(
                width: 40.sp, // Set the desired width
                height: 40.sp, // Set the desired height
                child: FloatingActionButton(
                  backgroundColor: Colors.black.withOpacity(.5),
                  child: Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 15.sp,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.reading);
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
