import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/quran/widget/reading/moshaf_selector.dart';
import 'package:mawaqit/src/pages/quran/widget/switch_button.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';
import 'package:sizer/sizer.dart';

import 'package:mawaqit/src/state_management/quran/reading/quran_reading_notifer.dart';

import 'package:mawaqit/src/state_management/quran/reading/auto_reading/auto_reading_notifier.dart';

class VerticalPageViewWidget extends ConsumerWidget {
  final QuranReadingState quranReadingState;

  const VerticalPageViewWidget({
    super.key,
    required this.quranReadingState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      child: SvgPictureWidget(
                        svgPicture: quranReadingState.svgs[index % quranReadingState.svgs.length],
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
}

class HorizontalPageViewWidget extends ConsumerWidget {
  final QuranReadingState quranReadingState;

  const HorizontalPageViewWidget({
    super.key,
    required this.quranReadingState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingState = ref.watch(quranReadingNotifierProvider);
    return readingState.maybeWhen(
      orElse: () {
        return const SizedBox.shrink();
      },
      data: (readingState) {
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
                        left: 8.w,
                        top: 0,
                        bottom: bottomPadding,
                        width: pageWidth * 0.85,
                        child: SvgPictureWidget(
                          svgPicture: quranReadingState.svgs[rightPageIndex % quranReadingState.svgs.length],
                        ),
                      ),
                    if (leftPageIndex < quranReadingState.svgs.length)
                      Positioned(
                        right: 8.w,
                        top: 0,
                        bottom: bottomPadding,
                        width: pageWidth * 0.85,
                        child: SvgPictureWidget(
                          svgPicture: quranReadingState.svgs[leftPageIndex % quranReadingState.svgs.length],
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class RightSwitchButtonWidget extends ConsumerWidget {
  final FocusNode focusNode;
  final VoidCallback onPressed;

  const RightSwitchButtonWidget({
    super.key,
    required this.focusNode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(2),
      child: Positioned(
        right: 10,
        top: 0,
        bottom: 0,
        child: Material(
          color: Colors.transparent,
          child: SwitchButton(
            focusNode: focusNode,
            opacity: 0.7,
            iconSize: 14.sp,
            icon: Directionality.of(context) == TextDirection.ltr ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

class LeftSwitchButtonWidget extends ConsumerWidget {
  final FocusNode focusNode;
  final VoidCallback onPressed;

  const LeftSwitchButtonWidget({
    Key? key,
    required this.focusNode,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(1),
      child: Positioned(
        left: 10,
        top: 0,
        bottom: 0,
        child: Material(
          color: Colors.transparent,
          child: SwitchButton(
            focusNode: focusNode,
            opacity: 0.7,
            iconSize: 14.sp,
            icon: Directionality.of(context) != TextDirection.ltr ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

class PageNumberIndicatorWidget extends ConsumerWidget {
  final QuranReadingState quranReadingState;
  final bool isPortrait;
  final FocusNode focusNode;
  final Function(BuildContext, int, int, bool) showPageSelector;

  const PageNumberIndicatorWidget({
    super.key,
    required this.quranReadingState,
    required this.isPortrait,
    required this.focusNode,
    required this.showPageSelector,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onTap: () => showPageSelector(
              context,
              quranReadingState.totalPages,
              quranReadingState.currentPage,
              isPortrait,
            ),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: isPortrait ? 8 : 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isPortrait
                    ? S.of(context).quranReadingPagePortrait(
                          quranReadingState.currentPage + 1,
                          quranReadingState.totalPages,
                        )
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
}

class MoshafSelectorPositionedWidget extends ConsumerWidget {
  final bool isPortrait;
  final FocusNode focusNode;
  final bool isThereCurrentDialogShowing;

  const MoshafSelectorPositionedWidget({
    Key? key,
    required this.isPortrait,
    required this.focusNode,
    required this.isThereCurrentDialogShowing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
}

class BackButtonWidget extends ConsumerWidget {
  final bool isPortrait;
  final UserPreferencesManager userPrefs;
  final FocusNode focusNode;

  const BackButtonWidget({
    Key? key,
    required this.isPortrait,
    required this.userPrefs,
    required this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      ),
    );
  }
}

class SvgPictureWidget extends StatelessWidget {
  final SvgPicture svgPicture;
  final double? width;
  final double? height;

  const SvgPictureWidget({
    super.key,
    required this.svgPicture,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final screenHeight = MediaQuery.of(context).size.height;

    final topPadding = isLandscape
        ? screenHeight * 0.08 // 6% of screen height in landscape
        : screenHeight * 0.04; // 4% of screen height in portrait

    // Side padding is also proportional to screen width
    final sidePadding = MediaQuery.of(context).size.width * 0.02; // 4% of screen width

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(sidePadding, topPadding, sidePadding, sidePadding),
      child: SvgPicture(
        svgPicture.bytesLoader,
        fit: BoxFit.contain,
        width: width,
        height: height,
        alignment: Alignment.center,
      ),
    );
  }
}
