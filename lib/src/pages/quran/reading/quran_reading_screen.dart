import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/reading/widget/quran_floating_action_buttons.dart';
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
  late FocusNode _switchToPlayQuranFocusNode;
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
    _switchToPlayQuranFocusNode = FocusNode(debugLabel: 'switch_to_play_quran_node');
  }

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
    _switchToPlayQuranFocusNode.dispose();
  }

  void _toggleOrientation(UserPreferencesManager userPrefs) {
    final newOrientation =
        MediaQuery.of(context).orientation == Orientation.portrait ? Orientation.landscape : Orientation.portrait;

    userPrefs.orientationLandscape = newOrientation == Orientation.landscape;
    setState(() {});
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
    _switchQuranModeNode.onKeyEvent = (node, event) => _handlePageScrollDownFocusGroupNode(node, event);
    _switchScreenViewFocusNode.onKeyEvent = (node, event) => _handlePageScrollDownFocusGroupNode(node, event);
    _portraitModeBackButtonFocusNode.onKeyEvent = (node, event) => _handlePageScrollUpFocusGroupNode(node, event);
    _portraitModeSwitchQuranFocusNode.onKeyEvent = (node, event) => _handlePageScrollUpFocusGroupNode(node, event);
    _portraitModePageSelectorFocusNode.onKeyEvent = (node, event) => _handlePageScrollDownFocusGroupNode(node, event);

    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;

        return WillPopScope(
          onWillPop: () async {
            userPrefs.orientationLandscape = true;
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            floatingActionButtonLocation: _getFloatingActionButtonLocation(context),
            floatingActionButton: QuranFloatingActionControls(
              switchScreenViewFocusNode: _switchScreenViewFocusNode,
              switchQuranModeNode: _switchQuranModeNode,
              switchToPlayQuranFocusNode: _switchToPlayQuranFocusNode,
            ),
            body: _buildBody(quranReadingState, isPortrait, userPrefs),
          ),
        );
      },
    );
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
                  context, _rightSkipButtonFocusNode, () => _scrollPageList(ScrollDirection.forward)),
              buildLeftSwitchButton(context, _leftSkipButtonFocusNode, () => _scrollPageList(ScrollDirection.reverse)),
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
            isPortrait ? Container() : buildShowSurah(quranReadingState),
          ],
        );
      },
    );
  }

  Align buildShowSurah(QuranReadingState quranReadingState) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 0.5.h),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ref.read(quranReadingNotifierProvider.notifier).getAllSuwarPage();
              showSurahSelector(context, quranReadingState.currentPage);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildOrientationToggleButton(isPortrait, userPrefs),
        SizedBox(width: 200.sp),
        _buildQuranModeButton(isPortrait, userPrefs, context),
        SizedBox(width: 200.sp),
        _buildPlayToggleButton(isPortrait),
      ],
    );
  }

  Widget buildFloatingLandscape(bool isPortrait, UserPreferencesManager userPrefs, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildPlayToggleButton(isPortrait),
        SizedBox(height: 1.h),
        _buildOrientationToggleButton(isPortrait, userPrefs),
        SizedBox(height: 1.h),
        _buildQuranModeButton(isPortrait, userPrefs, context),
      ],
    );
  }

  Widget _buildOrientationToggleButton(bool isPortrait, UserPreferencesManager userPrefs) {
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
        onPressed: () => _toggleOrientation(userPrefs),
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

  Widget _buildPlayToggleButton(bool isPortrait) {
    return SizedBox(
      width: isPortrait ? 35.sp : 30.sp,
      height: isPortrait ? 35.sp : 30.sp,
      child: FloatingActionButton(
        focusNode: _switchToPlayQuranFocusNode,
        backgroundColor: Colors.black.withOpacity(.3),
        child: Icon(
          !isPortrait ? Icons.play_arrow : Icons.stay_current_landscape,
          color: Colors.white,
          size: isPortrait ? 20.sp : 15.sp,
        ),
        onPressed: () {
          ;
        },
        heroTag: null,
      ),
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

  FloatingActionButtonLocation _getFloatingActionButtonLocation(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    if (isPortrait) {
      return FloatingActionButtonLocation.startFloat;
    } else {
      switch (textDirection) {
        case TextDirection.ltr:
          return FloatingActionButtonLocation.endFloat;
        case TextDirection.rtl:
          return FloatingActionButtonLocation.startFloat;
        default:
          return FloatingActionButtonLocation.endFloat;
      }
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

  KeyEventResult _handlePageScrollDownFocusGroupNode(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
      if (event.logicalKey == LogicalKeyboardKey.arrowDown && isPortrait) {
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

  bool _isThereCurrentDialogShowing(BuildContext context) => ModalRoute.of(context)?.isCurrent != true;
}

