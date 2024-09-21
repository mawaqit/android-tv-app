import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/widget/reading/moshaf_selector.dart';

// import 'package:mawaqit/src/pages/quran/widget/reading/moshaf_selector.dart';
import 'package:mawaqit/src/pages/quran/widget/switch_button.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_notifer.dart';

import 'package:mawaqit/src/pages/quran/widget/download_quran_popup.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';

import 'package:sizer/sizer.dart';

import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';

import 'package:mawaqit/src/pages/quran/widget/reading/quran_reading_page_selector.dart';

class QuranReadingScreen extends ConsumerStatefulWidget {
  const QuranReadingScreen({super.key});

  @override
  ConsumerState createState() => _QuranReadingScreenState();
}

class _QuranReadingScreenState extends ConsumerState<QuranReadingScreen> {
  int quranIndex = 0;

  late FocusNode _rightSkipButtonFocusNode;
  late FocusNode _leftSkipButtonFocusNode;

  final ScrollController _gridScrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _rightSkipButtonFocusNode = FocusNode(debugLabel: 'right_skip_node');
    _leftSkipButtonFocusNode = FocusNode(debugLabel: 'left_skip_node');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(downloadQuranNotifierProvider);
      ref.read(quranReadingNotifierProvider);
    });
  }

  @override
  void dispose() {
    _leftSkipButtonFocusNode.dispose();
    _rightSkipButtonFocusNode.dispose();

    super.dispose();
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
    ref.listen(downloadQuranNotifierProvider, (previous, next) async {
      if (!next.hasValue || next.value is Success) {
        ref.invalidate(quranReadingNotifierProvider);
      }

      // don't show dialog for them
      if (next.hasValue &&
          (next.value is NoUpdate ||
              next.value is CheckingDownloadedQuran ||
              next.value is CheckingUpdate ||
              next.value is CancelDownload)) {
        return;
      }

      if (previous!.hasValue && previous.value != next.value) {
        // Perform an action based on the new status
        print('Status changed: ${previous} && $next');
      }

      print(
          'next state: $next 2 canpop: ${!Navigator.canPop(context)} || _isThereCurrentDialogShowing: ${_isThereCurrentDialogShowing(context)}');

      if (!_isThereCurrentDialogShowing(context)) {
        print(
            'next state: $next 2 canpop: ${!Navigator.canPop(context)}|| _isThereCurrentDialogShowing: ${_isThereCurrentDialogShowing(context)}');
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => DownloadQuranDialog(),
        );
      }
    });

    _leftSkipButtonFocusNode.onKeyEvent = (node, event) => _handleSwitcherFocusGroupNode(node, event);
    _rightSkipButtonFocusNode.onKeyEvent = (node, event) => _handleSwitcherFocusGroupNode(node, event);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButtonLocation: _getFloatingActionButtonLocation(context),
        floatingActionButton: SizedBox(
          width: 30.sp, // Set the desired width
          height: 30.sp, //
          child: FloatingActionButton(
            // focusNode: _listeningModeFocusNode,
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
          error: (error, s) {
            final errorLocalized = S.of(context).error;
            return Center(child: Text('$errorLocalized: $error'));
          },
          data: (quranReadingState) {
            return Stack(
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
                    focusNode: _rightSkipButtonFocusNode,
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
                    focusNode: _leftSkipButtonFocusNode,
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
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        autofocus: _isThereCurrentDialogShowing(context),
                        // focusNode: _choosePageFocusNode,
                        onTap: () => _showPageSelector(
                          context,
                          quranReadingState.totalPages,
                          quranReadingState.currentPage,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            S.of(context).quranReadingPage(
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
                ),

                /// moshaf selector
                Positioned(
                  left: 10,
                  bottom: 1.h,
                  child: MoshafSelector(
                    focusNode: FocusNode(),
                  ),
                ),

                /// back button
                Positioned.directional(
                  start: 10,
                  textDirection: Directionality.of(context),
                  child: SwitchButton(
                    opacity: 0.7,
                    iconSize: 17.sp,
                    splashFactorSize: 0.9,
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

  void _showPageSelector(BuildContext context, int totalPages, int currentPage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QuranReadingPageSelector(
          currentPage: currentPage,
          scrollController: _gridScrollController,
          totalPages: totalPages,
        );
      },
    );
  }

  KeyEventResult _handleSwitcherFocusGroupNode(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _rightSkipButtonFocusNode.requestFocus();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _leftSkipButtonFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  _isThereCurrentDialogShowing(BuildContext context) => ModalRoute.of(context)?.isCurrent != true;
}
