import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/quran/reading/widget/quran_floating_action_buttons.dart';
import 'package:mawaqit/src/pages/quran/widget/reading/quran_reading_widgets.dart';
import 'package:mawaqit/src/pages/quran/widget/reading/quran_surah_selector.dart';

import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/auto_reading/auto_reading_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/auto_reading/auto_reading_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_notifer.dart';

import 'package:mawaqit/src/pages/quran/widget/download_quran_popup.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';
import 'package:provider/provider.dart' as provider;

import 'package:mawaqit/src/pages/quran/widget/reading/quran_reading_page_selector.dart';
import 'package:mawaqit/src/routes/routes_constant.dart';

abstract class QuranViewStrategy {
  Widget buildView(QuranReadingState state, WidgetRef ref, BuildContext context);

  List<Widget> buildControls(
      BuildContext context,
      QuranReadingState state,
      UserPreferencesManager userPrefs,
      bool isPortrait,
      FocusNodes focusNodes,
      Function(ScrollDirection, bool) onScroll,
      Function(BuildContext, int, int, bool) showPageSelector,
      );
}

// Helper class to organize focus nodes
class FocusNodes {
  final FocusNode backButtonNode;
  final FocusNode leftSkipNode;
  final FocusNode rightSkipNode;
  final FocusNode pageSelectorNode;
  final FocusNode switchQuranNode;
  final FocusNode surahSelectorNode;
  final FocusNode switchToPlayQuranFocusNode;
  final FocusNode switchScreenViewFocusNode;
  final FocusNode switchQuranModeNode;

  FocusNodes({
    required this.backButtonNode,
    required this.leftSkipNode,
    required this.rightSkipNode,
    required this.pageSelectorNode,
    required this.switchQuranNode,
    required this.surahSelectorNode,
    required this.switchToPlayQuranFocusNode,
    required this.switchScreenViewFocusNode,
    required this.switchQuranModeNode,
  });
  void setupFocusTraversal({required bool isPortrait}) {
    if (isPortrait) {
      setupPortraitFocusTraversal();
    } else {
      setupLandscapeFocusTraversal();
    }
  }

  void setupPortraitFocusTraversal() {
    // Setup focus traversal for back button
    backButtonNode.onKey = (node, event) {
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
        pageSelectorNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowRight) {
        switchQuranNode.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };

    // Setup focus traversal for page selector node
    pageSelectorNode.onKey = (node, event) {
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
        switchQuranNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowRight) {
        switchQuranModeNode.requestFocus();
        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    };

    // Setup focus traversal for switch quran node
    switchQuranNode.onKey = (node, event) {
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        backButtonNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
        switchToPlayQuranFocusNode.requestFocus();
        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    };

    // Setup focus traversal for surah selector node
    switchToPlayQuranFocusNode.onKey = (node, event) {
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
        switchQuranNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
        switchScreenViewFocusNode.requestFocus();
        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    };
    // Setup focus traversal for surah selector node
    switchScreenViewFocusNode.onKey = (node, event) {
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
        switchToPlayQuranFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
        switchQuranModeNode.requestFocus();
        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    };
    // Setup focus traversal for surah selector node
    switchQuranModeNode.onKey = (node, event) {
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
        switchScreenViewFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        pageSelectorNode.requestFocus();
        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    };
  }

  void setupLandscapeFocusTraversal() {
    // Setup focus traversal for back button
    backButtonNode.onKey = (node, event) {
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
        leftSkipNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowRight) {
        surahSelectorNode.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };

    // Setup focus traversal for left skip node
    leftSkipNode.onKey = (node, event) {
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
        backButtonNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowRight) {
        rightSkipNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
        pageSelectorNode.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };

    // Setup focus traversal for right skip node
    rightSkipNode.onKey = (node, event) {
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        leftSkipNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
        switchQuranNode.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };

    // Setup focus traversal for page selector node
    pageSelectorNode.onKey = (node, event) {
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
        leftSkipNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
        switchQuranNode.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };

    // Setup focus traversal for switch quran node
    switchQuranNode.onKey = (node, event) {
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
        rightSkipNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
        surahSelectorNode.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };

    // Setup focus traversal for surah selector node
    surahSelectorNode.onKey = (node, event) {
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
        switchQuranNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        backButtonNode.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
  }

  // Optional: Method to reset focus to a default node
  void resetToDefaultFocus() {
    backButtonNode.requestFocus();
  }

  // Optional: Method to dispose all focus nodes
  void dispose() {
    backButtonNode.dispose();
    leftSkipNode.dispose();
    rightSkipNode.dispose();
    pageSelectorNode.dispose();
    switchQuranNode.dispose();
    surahSelectorNode.dispose();
  }
}

class AutoScrollViewStrategy implements QuranViewStrategy {
  final AutoScrollState autoScrollState;

  AutoScrollViewStrategy(this.autoScrollState);

  @override
  Widget buildView(QuranReadingState state, WidgetRef ref, BuildContext context) {
    final scalingFactor = autoScrollState.fontSize;

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      controller: autoScrollState.scrollController,
      itemCount: state.totalPages,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            final autoScrollNotifier = ref.read(autoScrollNotifierProvider.notifier);
            if (autoScrollState.isPlaying) {
              autoScrollNotifier.pauseAutoScroll();
            } else {
              autoScrollNotifier.resumeAutoScroll();
            }
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width * scalingFactor,
            height: MediaQuery.of(context).size.height * scalingFactor,
            child: SvgPictureWidget(
              svgPicture: state.svgs[index],
            ),
          ),
        );
      },
    );
  }

  @override
  List<Widget> buildControls(
      BuildContext context,
      QuranReadingState state,
      UserPreferencesManager userPrefs,
      bool isPortrait,
      FocusNodes focusNodes,
      Function(ScrollDirection, bool) onScroll,
      Function(BuildContext, int, int, bool) showPageSelector,
      ) {
    return [];
  }
}

class NormalViewStrategy implements QuranViewStrategy {
  final bool isPortrait;

  NormalViewStrategy(this.isPortrait);

  @override
  Widget buildView(QuranReadingState state, WidgetRef ref, BuildContext context) {
    return isPortrait
        ? VerticalPageViewWidget(
      quranReadingState: state,
    )
        : HorizontalPageViewWidget(
      quranReadingState: state,
    );
  }

  @override
  List<Widget> buildControls(
      BuildContext context,
      QuranReadingState state,
      UserPreferencesManager userPrefs,
      bool isPortrait,
      FocusNodes focusNodes,
      Function(ScrollDirection, bool) onScroll,
      Function(BuildContext, int, int, bool) showPageSelector,
      ) {
    if (isPortrait) {
      return [
        SurahSelectorWidget(
          isPortrait: isPortrait,
          focusNode: focusNodes.surahSelectorNode,
          isThereCurrentDialogShowing: false,
        ),
        PageNumberIndicatorWidget(
          quranReadingState: state,
          focusNode: focusNodes.pageSelectorNode,
          isPortrait: isPortrait,
          showPageSelector: showPageSelector,
        ),
        MoshafSelectorPositionedWidget(
          isPortrait: isPortrait,
          focusNode: focusNodes.switchQuranNode,
          isThereCurrentDialogShowing: false,
        ),
        BackButtonWidget(
          isPortrait: isPortrait,
          userPrefs: userPrefs,
          focusNode: focusNodes.backButtonNode,
        ),
      ];
    }

    return [
      _buildNavigationButtons(
        context,
        focusNodes,
        onScroll,
        isPortrait,
      ),
      SurahSelectorWidget(
        isPortrait: isPortrait,
        focusNode: focusNodes.surahSelectorNode,
        isThereCurrentDialogShowing: false,
      ),
      PageNumberIndicatorWidget(
        quranReadingState: state,
        focusNode: focusNodes.pageSelectorNode,
        isPortrait: isPortrait,
        showPageSelector: showPageSelector,
      ),
      MoshafSelectorPositionedWidget(
        isPortrait: isPortrait,
        focusNode: focusNodes.switchQuranNode,
        isThereCurrentDialogShowing: false,
      ),
      BackButtonWidget(
        isPortrait: isPortrait,
        userPrefs: userPrefs,
        focusNode: focusNodes.backButtonNode,
      ),
    ];
  }

  Widget _buildNavigationButtons(
      BuildContext context,
      FocusNodes focusNodes,
      Function(ScrollDirection, bool) onScroll,
      bool isPortrait,
      ) {
    return Stack(
      children: [
        LeftSwitchButtonWidget(
          focusNode: focusNodes.leftSkipNode,
          onPressed: () => onScroll(ScrollDirection.reverse, isPortrait),
        ),
        RightSwitchButtonWidget(
          focusNode: focusNodes.rightSkipNode,
          onPressed: () => onScroll(ScrollDirection.forward, isPortrait),
        ),
      ],
    );
  }
}

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
  late FocusNode _surahSelectorNode;
  late FocusNode _switchScreenViewFocusNode;
  late FocusNode _switchToPlayQuranFocusNode;
  late FocusNode _portraitModeBackButtonFocusNode;
  late FocusNode _portraitModeSwitchQuranFocusNode;
  late FocusNode _portraitModePageSelectorFocusNode;
  final ScrollController _gridScrollController = ScrollController();
  bool _isRotated = false;

  @override
  void initState() {
    super.initState();
    _initializeFocusNodes();
    // Create FocusNodes instance and setup traversal
    final focusNodes = FocusNodes(
        backButtonNode: _backButtonFocusNode,
        leftSkipNode: _leftSkipButtonFocusNode,
        rightSkipNode: _rightSkipButtonFocusNode,
        pageSelectorNode: _portraitModePageSelectorFocusNode,
        switchQuranNode: _switchQuranFocusNode,
        surahSelectorNode: _surahSelectorNode,
        switchToPlayQuranFocusNode: _switchToPlayQuranFocusNode,
        switchScreenViewFocusNode: _switchScreenViewFocusNode,
        switchQuranModeNode: _switchQuranModeNode);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(downloadQuranNotifierProvider);
      final quranReadingState = ref.watch(quranReadingNotifierProvider);
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
    _surahSelectorNode = FocusNode(debugLabel: 'surah_selector_node');
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
    _surahSelectorNode.dispose();
  }

  void _navigateToListeningMode() {
    ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.listening);
    Navigator.pushReplacementNamed(context, Routes.quranReciter);
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

    final autoReadingState = ref.watch(autoScrollNotifierProvider);
    final downloadState = ref.watch(downloadQuranNotifierProvider);
    return downloadState.when(
      data: (data) {
        if (data is NeededDownloadedQuran || data is Downloading || data is Extracting) {
          return Scaffold(
            body: Container(
              color: Colors.white,
            ),
          );
        }
        return WillPopScope(
          onWillPop: () async {
            userPrefs.orientationLandscape = true;
            return true;
          },
          child: quranReadingState.when(
            data: (state) {
              setState(() {
                _isRotated = state.isRotated;
              });
              return RotatedBox(
                quarterTurns: state.isRotated ? -1 : 0,
                child: SizedBox(
                  width: MediaQuery.of(context).size.height,
                  height: MediaQuery.of(context).size.width,
                  child: Scaffold(
                    backgroundColor: Colors.white,
                    floatingActionButtonLocation: _getFloatingActionButtonLocation(context),
                    floatingActionButton: QuranFloatingActionControls(
                      switchScreenViewFocusNode: _switchScreenViewFocusNode,
                      switchQuranModeNode: _switchQuranModeNode,
                      switchToPlayQuranFocusNode: _switchToPlayQuranFocusNode,
                    ),
                    body: _buildBody(quranReadingState, state.isRotated, userPrefs, autoReadingState),
                  ),
                ),
              );
            },
            loading: () => Scaffold(body: SizedBox()),
            error: (error, stack) => Scaffold(body: const Icon(Icons.error)),
          ),
        );
      },
      loading: () => Scaffold(body: _buildLoadingIndicator()),
      error: (error, stack) => Scaffold(body: _buildErrorIndicator(error)),
    );
  }

  Widget _buildBody(
      AsyncValue<QuranReadingState> quranReadingState,
      bool isPortrait,
      UserPreferencesManager userPrefs,
      AutoScrollState autoScrollState,
      ) {
    return quranReadingState.when(
      loading: () => _buildLoadingIndicator(),
      error: (error, s) => _buildErrorIndicator(error),
      data: (state) {
        // Initialize the appropriate strategy
        final viewStrategy =
        autoScrollState.isSinglePageView ? AutoScrollViewStrategy(autoScrollState) : NormalViewStrategy(isPortrait);

        // Create focus nodes bundle
        final focusNodes = FocusNodes(
            backButtonNode: _backButtonFocusNode,
            leftSkipNode: _leftSkipButtonFocusNode,
            rightSkipNode: _rightSkipButtonFocusNode,
            pageSelectorNode: _portraitModePageSelectorFocusNode,
            switchQuranNode: _switchQuranFocusNode,
            surahSelectorNode: _surahSelectorNode,
            switchToPlayQuranFocusNode: _switchToPlayQuranFocusNode,
            switchScreenViewFocusNode: _switchScreenViewFocusNode,
            switchQuranModeNode: _switchQuranModeNode);
        focusNodes.setupFocusTraversal(isPortrait: isPortrait);

        if (isPortrait) {
          return Stack(
            children: [
              // Main content
              viewStrategy.buildView(state, ref, context),

              // Controls overlay - show in both portrait and landscape
              ...viewStrategy.buildControls(
                context,
                state,
                userPrefs,
                isPortrait,
                focusNodes,
                _scrollPageList,
                _showPageSelector,
              ),
            ],
          );
        }
        return Stack(
          children: [
            // Main content
            viewStrategy.buildView(state, ref, context),

            // Controls overlay - show in both portrait and landscape
            ...viewStrategy.buildControls(
              context,
              state,
              userPrefs,
              isPortrait,
              focusNodes,
              _scrollPageList,
              _showPageSelector,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildErrorIndicator(Object error) {
    final errorLocalized = S.of(context).error;
    return Center(
      child: Text('$errorLocalized: $error'),
    );
  }

  Widget buildAutoScrollView(
      QuranReadingState quranReadingState,
      WidgetRef ref,
      AutoScrollState autoScrollState,
      ) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      controller: autoScrollState.scrollController,
      itemCount: quranReadingState.totalPages,
      itemBuilder: (context, index) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final pageHeight =
            constraints.maxHeight.isInfinite ? MediaQuery.of(context).size.height : constraints.maxHeight;
            return Container(
              width: constraints.maxWidth,
              height: pageHeight,
              child: quranReadingState.svgs[index],
            );
          },
        );
      },
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

  bool _isThereCurrentDialogShowing(BuildContext context) => ModalRoute.of(context)?.isCurrent != true;
}
