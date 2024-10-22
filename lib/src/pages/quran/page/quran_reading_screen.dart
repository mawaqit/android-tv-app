import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/widget/reading/quran_reading_widgets.dart';
import 'package:mawaqit/src/pages/quran/widget/reading/quran_surah_selector.dart';

import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_notifer.dart';

import 'package:mawaqit/src/pages/quran/widget/download_quran_popup.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';
import 'package:provider/provider.dart' as provider;

import 'package:sizer/sizer.dart';

import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';

import 'package:mawaqit/src/pages/quran/widget/reading/quran_reading_page_selector.dart';

import '../../../data/data_source/device_info_data_source.dart';

class QuranReadingScreen extends ConsumerStatefulWidget {
  const QuranReadingScreen({super.key});

  @override
  ConsumerState createState() => _QuranReadingScreenState();
}

class _QuranReadingScreenState extends ConsumerState<QuranReadingScreen> {
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
    _initializeFocusNodes();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(downloadQuranNotifierProvider);
      ref.read(quranReadingNotifierProvider);
    });
  }

  void _initializeFocusNodes() {
    _rightSkipButtonFocusNode = FocusNode(debugLabel: 'right_skip_node');
    _leftSkipButtonFocusNode = FocusNode(debugLabel: 'left_skip_node');
    _backButtonFocusNode = FocusNode(debugLabel: 'back_button_node');
    _switchQuranFocusNode = FocusNode(debugLabel: 'switch_quran_node');
    _switchQuranModeNode = FocusNode(debugLabel: 'switch_quran_mode_node');
    _switchScreenViewFocusNode = FocusNode(debugLabel: 'switch_screen_view_node');
    _portraitModeBackButtonFocusNode = FocusNode(debugLabel: 'portrait_mode_back_button_node');
    _portraitModeSwitchQuranFocusNode = FocusNode(debugLabel: 'portrait_mode_switch_quran_node');
    _portraitModePageSelectorFocusNode = FocusNode(debugLabel: 'portrait_mode_page_selector_node');
  }

  bool _isRotated = false;

  @override
  void dispose() {
    _disposeFocusNodes();

    super.dispose();
  }

  void _disposeFocusNodes() {
    _leftSkipButtonFocusNode.dispose();
    _rightSkipButtonFocusNode.dispose();
    _backButtonFocusNode.dispose();
    _switchQuranFocusNode.dispose();
    _switchScreenViewFocusNode.dispose();
    _portraitModeBackButtonFocusNode.dispose();
    _portraitModeSwitchQuranFocusNode.dispose();
    _portraitModePageSelectorFocusNode.dispose();
  }

  void _toggleOrientation() {
    setState(() {
      _isRotated = !_isRotated;
    });
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
      }

      if (!_isThereCurrentDialogShowing(context)) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => DownloadQuranDialog(),
        );
      }
    });

    _leftSkipButtonFocusNode.onKeyEvent = (node, event) => _handleSwitcherFocusGroupNode(node, event);
    _rightSkipButtonFocusNode.onKeyEvent = (node, event) => _handleSwitcherFocusGroupNode(node, event);

    _switchScreenViewFocusNode.onKeyEvent =
        (node, event) => _handlePageScrollDownFocusGroupNode(node, event, _isRotated);
    _portraitModePageSelectorFocusNode.onKeyEvent =
        (node, event) => _handlePageScrollDownFocusGroupNode(node, event, _isRotated);
    _switchQuranModeNode.onKeyEvent = (node, event) => _handlePageScrollDownFocusGroupNode(node, event, _isRotated);
    _portraitModeBackButtonFocusNode.onKeyEvent =
        (node, event) => _handlePageScrollUpFocusGroupNode(node, event, _isRotated);
    _portraitModeSwitchQuranFocusNode.onKeyEvent =
        (node, event) => _handlePageScrollUpFocusGroupNode(node, event, _isRotated);
    return WillPopScope(
        onWillPop: () async {
          userPrefs.orientationLandscape = true;

          return true;
        },
        child: RotatedBox(
          quarterTurns: _isRotated ? -1 : 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.height,
            height: MediaQuery.of(context).size.width,
            child: Scaffold(
              backgroundColor: Colors.white,
              floatingActionButtonLocation: _getFloatingActionButtonLocation(context),
              floatingActionButton: _isRotated
                  ? buildFloatingPortrait(_isRotated, userPrefs, context)
                  : buildFloatingLandscape(_isRotated, userPrefs, context),
              body: _buildBody(quranReadingState, _isRotated, userPrefs),
            ),
          ),
        ));
  }

  Widget _buildBody(
      AsyncValue<QuranReadingState> quranReadingState, bool isPortrait, UserPreferencesManager userPrefs) {
    final color = Theme.of(context).primaryColor;
    return quranReadingState.when(
      loading: () => Center(
        child: CircularProgressIndicator(
          color: color,
        ),
      ),
      error: (error, s) {
        final errorLocalized = S.of(context).error;
        return Center(child: Text('$errorLocalized: $error'));
      },
      data: (quranReadingState) {
        return Stack(
          children: [
            isPortrait
                ? buildVerticalPageView(quranReadingState, ref)
                : buildHorizontalPageView(quranReadingState, ref, context),
            if (!isPortrait) ...[
              buildRightSwitchButton(
                context,
                _rightSkipButtonFocusNode,
                () => _scrollPageList(ScrollDirection.forward, isPortrait),
              ),
              buildLeftSwitchButton(
                context,
                _leftSkipButtonFocusNode,
                () => _scrollPageList(ScrollDirection.reverse, isPortrait),
              ),
            ],
            buildPageNumberIndicator(
                quranReadingState, isPortrait, context, _portraitModePageSelectorFocusNode, _showPageSelector),
            buildMoshafSelector(
                isPortrait,
                context,
                isPortrait ? _portraitModeSwitchQuranFocusNode : _switchQuranFocusNode,
                _isThereCurrentDialogShowing(context)),
            buildBackButton(
                isPortrait, userPrefs, context, isPortrait ? _portraitModeBackButtonFocusNode : _backButtonFocusNode),
            isPortrait ? SizedBox() : buildShowSurah(quranReadingState),
          ],
        );
      },
    );
  }

  Align buildShowSurah(QuranReadingState quranReadingState) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 0.3.h),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ref.read(quranReadingNotifierProvider.notifier).getAllSuwarPage();
              showSurahSelector(context, quranReadingState.currentPage);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                quranReadingState.currentSurahName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFloatingPortrait(bool isPortrait, UserPreferencesManager userPrefs, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildOrientationToggleButton(isPortrait),
          _buildQuranModeButton(isPortrait, userPrefs, context),
        ],
      ),
    );
  }

  Widget buildFloatingLandscape(bool isPortrait, UserPreferencesManager userPrefs, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildOrientationToggleButton(isPortrait),
        SizedBox(height: 10),
        _buildQuranModeButton(isPortrait, userPrefs, context),
      ],
    );
  }

  Widget _buildOrientationToggleButton(bool isPortrait) {
    return SizedBox(
      width: isPortrait ? 35.sp : 30.sp,
      height: isPortrait ? 35.sp : 30.sp,
      child: FloatingActionButton(
        focusNode: _switchScreenViewFocusNode,
        backgroundColor: Colors.black.withOpacity(.3),
        child: Icon(
          !isPortrait ? Icons.stay_current_portrait : Icons.stay_current_landscape,
          color: Colors.white,
          size: isPortrait ? 20.sp : 15.sp,
        ),
        onPressed: () => _toggleOrientation(),
        heroTag: null,
      ),
    );
  }

  Widget _buildQuranModeButton(bool isPortrait, UserPreferencesManager userPrefs, BuildContext context) {
    return SizedBox(
      width: isPortrait ? 35.sp : 30.sp,
      height: isPortrait ? 35.sp : 30.sp,
      child: FloatingActionButton(
        focusNode: _switchQuranModeNode,
        backgroundColor: Colors.black.withOpacity(.3),
        child: Icon(
          Icons.headset,
          color: Colors.white,
          size: isPortrait ? 20.sp : 15.sp,
        ),
        onPressed: () async {
          ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.listening);
          if (isPortrait) {
            userPrefs.orientationLandscape = true;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ReciterSelectionScreen.withoutSurahName(),
            ),
          );
        },
        heroTag: null,
      ),
    );
  }

  void _scrollPageList(ScrollDirection direction, isPortrait) {
    if (direction == ScrollDirection.forward) {
      ref.read(quranReadingNotifierProvider.notifier).previousPage(isPortrait: isPortrait);
    } else {
      ref.read(quranReadingNotifierProvider.notifier).nextPage(isPortrait: isPortrait);
    }
  }

  void _showPageSelector(BuildContext context, int totalPages, int currentPage, bool switcherScreen) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QuranReadingPageSelector(
          isPortrait: switcherScreen,
          currentPage: currentPage,
          scrollController: _gridScrollController,
          totalPages: totalPages,
        );
      },
    );
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

  KeyEventResult _handlePageScrollDownFocusGroupNode(FocusNode node, KeyEvent event, bool isPortrait) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown && isPortrait) {
        _scrollPageList(ScrollDirection.reverse, isPortrait);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handlePageScrollUpFocusGroupNode(FocusNode node, KeyEvent event, bool isPortrait) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _scrollPageList(ScrollDirection.forward, isPortrait);

        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  bool _isThereCurrentDialogShowing(BuildContext context) => ModalRoute.of(context)?.isCurrent != true;
}
