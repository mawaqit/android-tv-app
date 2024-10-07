import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/widget/reading/moshaf_selector.dart';

import 'package:mawaqit/src/pages/quran/widget/switch_button.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_notifer.dart';

import 'package:mawaqit/src/pages/quran/widget/download_quran_popup.dart';
import 'package:provider/provider.dart';

import 'package:sizer/sizer.dart';

import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';

import 'package:mawaqit/src/pages/quran/widget/reading/quran_reading_page_selector.dart';

import '../../../services/user_preferences_manager.dart';
import '../../../state_management/quran/reading/quran_reading_state.dart';

class QuranReadingScreen extends ConsumerStatefulWidget {
  const QuranReadingScreen({super.key});

  @override
  ConsumerState createState() => _QuranReadingScreenState();
}

class _QuranReadingScreenState extends ConsumerState<QuranReadingScreen> {
  int quranIndex = 0;

  late FocusNode _rightSkipButtonFocusNode;
  late FocusNode _leftSkipButtonFocusNode;
  late FocusNode _backButtonFocusNode;
  late FocusNode _switchQuranFocusNode;
  late FocusNode _switchQuranModeNode;
  late FocusNode _switchScreenViewFocusNode;
  late FocusNode _portraitModeBackButtonFocusNode;
  late FocusNode _portraitModeSwitchQuranFocusNode;
  late FocusNode _portraitModePageSelectorFocusNode;


  final ScrollController _gridScrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _rightSkipButtonFocusNode = FocusNode(debugLabel: 'right_skip_node');
    _leftSkipButtonFocusNode = FocusNode(debugLabel: 'left_skip_node');
    _backButtonFocusNode = FocusNode(debugLabel: 'back_button_node');
    _switchQuranFocusNode = FocusNode(debugLabel: 'switch_quran_node');
    _switchQuranModeNode = FocusNode(debugLabel: 'switchQuranModeNode');
    _switchScreenViewFocusNode = FocusNode(debugLabel: 'switchScreenViewFocusNode');
    _portraitModeBackButtonFocusNode = FocusNode(debugLabel: '_portraitModeBackButtonFocusNode');
    _portraitModeSwitchQuranFocusNode = FocusNode(debugLabel: '_portraitModeSwitchQuranFocusNode');
    _portraitModePageSelectorFocusNode = FocusNode(debugLabel: '_portraitModePageSelectorFocusNode');


    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(downloadQuranNotifierProvider);
      ref.read(quranReadingNotifierProvider);
    });
  }

  void _setLandscapeOrientation(UserPreferencesManager userPrefs) {
    userPrefs.orientationLandscape = true;
  }

  @override
  void dispose() {
    _leftSkipButtonFocusNode.dispose();
    _rightSkipButtonFocusNode.dispose();
    _backButtonFocusNode.dispose();
    _switchQuranFocusNode.dispose();
    _switchScreenViewFocusNode.dispose();
    _portraitModeBackButtonFocusNode.dispose();
    _portraitModeSwitchQuranFocusNode.dispose();
    _portraitModePageSelectorFocusNode.dispose();

    super.dispose();
  }

  void _toggleOrientation(UserPreferencesManager userPrefs) async {
    final newOrientation =
        MediaQuery.of(context).orientation == Orientation.portrait ? Orientation.landscape : Orientation.portrait;

    if (newOrientation == Orientation.landscape) {
      userPrefs.orientationLandscape = true;
    } else {
      userPrefs.orientationLandscape = false;
    }

    // Force the screen to rebuild
    setState(() {});
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

    final userPrefs = context.watch<UserPreferencesManager>();
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
    _switchQuranModeNode.onKeyEvent = (node, event) => _handlePageScrollDownFocusGroupNode(node, event);
    _switchScreenViewFocusNode.onKeyEvent = (node, event) => _handlePageScrollDownFocusGroupNode(node, event);
    _portraitModeBackButtonFocusNode.onKeyEvent = (node, event) => _handlePageScrollUpFocusGroupNode(node, event);
    _portraitModeSwitchQuranFocusNode.onKeyEvent = (node, event) => _handlePageScrollUpFocusGroupNode(node, event);
    _portraitModePageSelectorFocusNode.onKeyEvent = (node, event) => _handlePageScrollDownFocusGroupNode(node, event);

    return OrientationBuilder(
      builder: ((context, orientation) {
        final isPortrait = orientation == Orientation.portrait;

        return WillPopScope(
          onWillPop: () async {
            _setLandscapeOrientation(userPrefs);
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            floatingActionButtonLocation:
                isPortrait ? FloatingActionButtonLocation.startFloat : _getFloatingActionButtonLocation(context),
            floatingActionButton: isPortrait
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 35.sp,
                        height: 35.sp,
                        child: FloatingActionButton(
                          focusNode: _switchScreenViewFocusNode,
                          backgroundColor: Colors.black.withOpacity(.3),
                          child: Icon(
                            !isPortrait ? Icons.stay_current_portrait : Icons.stay_current_landscape,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          onPressed: () => {_toggleOrientation(userPrefs)},
                        ),
                      ),
                      SizedBox(width: 200.sp),
                      SizedBox(
                        width: 35.sp,
                        height: 35.sp,
                        child: FloatingActionButton(
                          focusNode: _switchQuranModeNode,
                          backgroundColor: Colors.black.withOpacity(.3),
                          child: Icon(
                            Icons.headset,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          onPressed: () async {
                            ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.listening);
                            if (isPortrait) {
                              _setLandscapeOrientation(userPrefs);
                            }
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReciterSelectionScreen.withoutSurahName(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 30.sp,
                        height: 30.sp,
                        child: FloatingActionButton(
                          backgroundColor: Colors.black.withOpacity(.3),
                          child: Icon(
                            !isPortrait ? Icons.stay_current_portrait : Icons.stay_current_landscape,
                            color: Colors.white,
                            size: 15.sp,
                          ),
                          onPressed: () => _toggleOrientation(userPrefs),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 30.sp,
                        height: 30.sp,
                        child: FloatingActionButton(
                          backgroundColor: Colors.black.withOpacity(.3),
                          child: Icon(
                            Icons.headset,
                            color: Colors.white,
                            size: 15.sp,
                          ),
                          onPressed: () async {
                            ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.listening);
                            if (isPortrait) {
                              _setLandscapeOrientation(userPrefs);
                            }
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReciterSelectionScreen.withoutSurahName(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
                    isPortrait
                        ? _buildVerticalPageView(quranReadingState)
                        : _buildHorizontalPageView(quranReadingState),
                    !isPortrait
                        ? Positioned(
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
                          )
                        : SizedBox(),
                    !isPortrait
                        ? Positioned(
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
                          )
                        : SizedBox(),
                    // Page Number
                    Positioned(
                      left: 15.w,
                      right: 15.w,
                      bottom: 1.h,
                      child: Center(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            focusNode: _portraitModePageSelectorFocusNode,
                            autofocus: false,
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
                                isPortrait
                                    ? S.of(context).quranReadingPagePortrait(
                                        quranReadingState.currentPage + 1, quranReadingState.totalPages)
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
                    ),

                    /// moshaf selector
                    isPortrait
                        ? Positioned.directional(
                            end: 10,
                            textDirection: Directionality.of(context),
                            top: 1.h,
                            child: MoshafSelector(
                              isAutofocus: !_isThereCurrentDialogShowing(context),
                              focusNode: _portraitModeSwitchQuranFocusNode,
                            ),
                          )
                        : Positioned(
                            left: 10,
                            bottom: 1.h,
                            child: MoshafSelector(
                              isAutofocus: !_isThereCurrentDialogShowing(context),
                              focusNode: _switchQuranFocusNode,
                            ),
                          ),

                    /// back button

                    Positioned.directional(
                      start: 10,
                      textDirection: Directionality.of(context),
                      child: SwitchButton(
                        focusNode: isPortrait ? _portraitModeBackButtonFocusNode : _backButtonFocusNode,
                        opacity: 0.7,
                        iconSize: 14.sp,
                        splashFactorSize: 0.9,
                        icon: Icons.arrow_back_rounded,
                        onPressed: () {
                          log('quran: QuranReadingScreen: back');
                          if (isPortrait) {
                            _setLandscapeOrientation(userPrefs);
                          }
                          Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVerticalPageView(QuranReadingState quranReadingState) {
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
                      height: pageHeight + 150,
                      child: _buildSvgPicture(
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

  Widget _buildHorizontalPageView(QuranReadingState quranReadingState) {
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
                    child: _buildSvgPicture(
                      quranReadingState.svgs[rightPageIndex % quranReadingState.svgs.length],
                    ),
                  ),
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

    );
  }

  void _scrollPageList(ScrollDirection direction) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if (direction == ScrollDirection.forward) {
      ref.read(quranReadingNotifierProvider.notifier).previousPage(isPortrait: isPortrait);
    } else {
      ref.read(quranReadingNotifierProvider.notifier).nextPage(isPortrait: isPortrait);
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
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _backButtonFocusNode.requestFocus();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _switchQuranFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handlePageScrollDownFocusGroupNode(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _scrollPageList(ScrollDirection.reverse);

        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handlePageScrollUpFocusGroupNode(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _scrollPageList(ScrollDirection.forward);

        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }


  _isThereCurrentDialogShowing(BuildContext context) => ModalRoute.of(context)?.isCurrent != true;
}
