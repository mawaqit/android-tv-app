import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/quran/widget/reading/moshaf_selector.dart';
import 'package:mawaqit/src/pages/quran/widget/switch_button.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:sizer/sizer.dart';

import '../../../../state_management/quran/reading/quran_reading_notifer.dart';

Widget buildVerticalPageView(QuranReadingState quranReadingState, WidgetRef ref) {
  return PageView.builder(
    scrollDirection: Axis.vertical,
    controller: quranReadingState.pageController,
    onPageChanged: (index) {
      if (index != quranReadingState.currentPage) {
        ref.read(quranReadingNotifierProvider.notifier).updatePage(index, isPortairt: true);
      }
    },
    itemCount: quranReadingState.totalPages,
    itemBuilder: (context, index) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final pageWidth = constraints.maxWidth;
          final pageHeight = constraints.maxHeight;

          return Stack(
            children: [
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: pageWidth + 150,
                    height: pageHeight + 100,
                    child: buildSvgPicture(
                      quranReadingState.svgs[index % quranReadingState.svgs.length],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget buildHorizontalPageView(QuranReadingState quranReadingState, WidgetRef ref, BuildContext context) {
  return PageView.builder(
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
      return LayoutBuilder(
        builder: (context, constraints) {
          final pageWidth = constraints.maxWidth / 2;
          final pageHeight = constraints.maxHeight;
          final bottomPadding = pageHeight * 0.05;

          final leftPageIndex = index * 2;
          final rightPageIndex = leftPageIndex + 1;
          return Stack(
            children: [
              if (rightPageIndex < quranReadingState.svgs.length)
                Positioned(
                  left: 12.w,
                  top: 0,
                  bottom: bottomPadding,
                  width: pageWidth * 0.9,
                  child: buildSvgPicture(
                    quranReadingState.svgs[rightPageIndex % quranReadingState.svgs.length],
                  ),
                ),
              if (leftPageIndex < quranReadingState.svgs.length)
                Positioned(
                  right: 12.w,
                  top: 0,
                  bottom: bottomPadding,
                  width: pageWidth * 0.9,
                  child: buildSvgPicture(
                    quranReadingState.svgs[leftPageIndex % quranReadingState.svgs.length],
                  ),
                ),
            ],
          );
        },
      );
    },
  );
}

Widget buildRightSwitchButton(BuildContext context, FocusNode focusNode, Function() onPressed) {
  return Positioned(
    right: 10,
    top: 0,
    bottom: 0,
    child: SwitchButton(
      focusNode: focusNode,
      opacity: 0.7,
      iconSize: 14.sp,
      icon: Directionality.of(context) == TextDirection.ltr ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
      onPressed: onPressed,
    ),
  );
}

Widget buildLeftSwitchButton(BuildContext context, FocusNode focusNode, Function() onPressed) {
  return Positioned(
    left: 10,
    top: 0,
    bottom: 0,
    child: SwitchButton(
      focusNode: focusNode,
      opacity: 0.7,
      iconSize: 14.sp,
      icon: Directionality.of(context) != TextDirection.ltr ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
      onPressed: onPressed,
    ),
  );
}

Widget buildPageNumberIndicator(QuranReadingState quranReadingState, bool isPortrait, BuildContext context,
    FocusNode focusNode, Function(BuildContext, int, int, bool) showPageSelector) {
  return Positioned(
    left: 15.w,
    right: 15.w,
    bottom: isPortrait ? 1.h : 0.5.h,

    child: Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          focusNode: focusNode,
          autofocus: false,
          onTap: () =>
              showPageSelector(context, quranReadingState.totalPages, quranReadingState.currentPage, isPortrait),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: isPortrait ? 8 : 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPortrait
                  ? S
                      .of(context)
                      .quranReadingPagePortrait(quranReadingState.currentPage + 1, quranReadingState.totalPages)
                  : S.of(context).quranReadingPage(
                        quranReadingState.currentPage + 1,
                        quranReadingState.currentPage + 2,
                        quranReadingState.totalPages,
                      ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget buildMoshafSelector(
    bool isPortrait, BuildContext context, FocusNode focusNode, bool isThereCurrentDialogShowing) {
  return isPortrait
      ? Positioned.directional(
          end: 10,
          textDirection: Directionality.of(context),
          top: 1.h,
          child: MoshafSelector(
            isAutofocus: !isThereCurrentDialogShowing,
            focusNode: focusNode,
          ),
        )
      : Positioned(
          left: 10,
          bottom: 0.5.h,
          child: MoshafSelector(
            isPortrait: false,
            isAutofocus: !isThereCurrentDialogShowing,
            focusNode: focusNode,
          ),
        );
}

Widget buildBackButton(bool isPortrait, UserPreferencesManager userPrefs, BuildContext context, FocusNode focusNode) {
  return Positioned.directional(
      start: 10,
      top: 10,
      textDirection: Directionality.of(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          focusNode: focusNode,
          onTap: () {
            if (isPortrait) {
              userPrefs.orientationLandscape = true;
            }
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(40),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 14.sp,
              ),
            ),
          ),
        ),
      ));
}

Widget buildSvgPicture(SvgPicture svgPicture) {
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
