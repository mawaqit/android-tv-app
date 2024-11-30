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

  FocusNodes({
    required this.backButtonNode,
    required this.leftSkipNode,
    required this.rightSkipNode,
    required this.pageSelectorNode,
    required this.switchQuranNode,
    required this.surahSelectorNode,
  });
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
        BackButtonWidget(
          isPortrait: isPortrait,
          userPrefs: userPrefs,
          focusNode: focusNodes.backButtonNode,
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
      ];
    }

    return [
      BackButtonWidget(
        isPortrait: isPortrait,
        userPrefs: userPrefs,
        focusNode: focusNodes.backButtonNode,
      ),
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
    ];
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    FocusNodes focusNodes,
    Function(ScrollDirection, bool) onScroll,
    bool isPortrait,
  ) {
    return FocusTraversalGroup(
      policy: ArrowButtonsFocusTraversalPolicy(
        backButtonNode: focusNodes.backButtonNode,
        pageSelectorNode: focusNodes.pageSelectorNode,
      ),
      child: Stack(
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
      ),
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
        Navigator.pop(context);
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
        loading: () => SizedBox(),
        error: (error, stack) => const Icon(Icons.error),
      ),
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
        );
        if (isPortrait) {
          return FocusTraversalGroup(
            policy: PortraitModeFocusTraversalPolicy(
              backButtonNode: _backButtonFocusNode,
              switchToPlayQuranFocusNode: _switchToPlayQuranFocusNode,
              switchQuranNode: _switchQuranFocusNode,
              pageSelectorNode: _portraitModePageSelectorFocusNode,
            ),
            child: Stack(
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
            ),
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

class ArrowButtonsFocusTraversalPolicy extends FocusTraversalPolicy {
  final FocusNode backButtonNode;
  final FocusNode pageSelectorNode;

  const ArrowButtonsFocusTraversalPolicy({
    super.requestFocusCallback,
    required this.backButtonNode,
    required this.pageSelectorNode,
  });

  @override
  FocusNode? findFirstFocus(FocusNode currentNode, {bool ignoreCurrentFocus = false}) {
    final nodes = currentNode.nearestScope!.traversalDescendants;
    return nodes.firstWhereOrNull((node) => node.debugLabel?.contains('left_skip_node') == true);
  }

  @override
  FocusNode findLastFocus(FocusNode currentNode, {bool ignoreCurrentFocus = false}) {
    final nodes = currentNode.nearestScope!.traversalDescendants;
    return nodes.firstWhereOrNull((node) => node.debugLabel?.contains('right_skip_node') == true) ?? currentNode;
  }

  @override
  FocusNode? findFirstFocusInDirection(FocusNode currentNode, TraversalDirection direction) {
    switch (direction) {
      case TraversalDirection.up:
        return backButtonNode;
      case TraversalDirection.down:
        return pageSelectorNode;
      case TraversalDirection.left:
      case TraversalDirection.right:
        return null;
    }
  }

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    final arrowNodes = descendants
        .where((node) =>
            node.debugLabel?.contains('left_skip_node') == true || node.debugLabel?.contains('right_skip_node') == true)
        .toList();

    mergeSort<FocusNode>(arrowNodes, compare: (a, b) {
      final aIsLeft = a.debugLabel?.contains('left_skip_node') == true;
      final bIsLeft = b.debugLabel?.contains('left_skip_node') == true;
      return aIsLeft ? -1 : 1;
    });

    return arrowNodes;
  }

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    final nodes = currentNode.nearestScope!.traversalDescendants;
    final leftNode = nodes.firstWhereOrNull((node) => node.debugLabel?.contains('left_skip_node') == true);
    final rightNode = nodes.firstWhereOrNull((node) => node.debugLabel?.contains('right_skip_node') == true);

    switch (direction) {
      case TraversalDirection.left:
        if (currentNode == rightNode && leftNode != null) {
          requestFocusCallback(leftNode);
          return true;
        }
        return false;
      case TraversalDirection.right:
        if (currentNode == leftNode && rightNode != null) {
          requestFocusCallback(rightNode);
          return true;
        }
        return false;
      case TraversalDirection.up:
        if ((currentNode == leftNode || currentNode == rightNode) && backButtonNode.canRequestFocus) {
          requestFocusCallback(backButtonNode);
          return true;
        }
        return false;
      case TraversalDirection.down:
        if ((currentNode == leftNode || currentNode == rightNode) && pageSelectorNode.canRequestFocus) {
          requestFocusCallback(pageSelectorNode);
          return true;
        }
        return false;
    }
  }
}

class PortraitModeFocusTraversalPolicy extends FocusTraversalPolicy {
  final FocusNode backButtonNode;
  final FocusNode switchQuranNode;
  final FocusNode pageSelectorNode;
  final FocusNode switchToPlayQuranFocusNode;

  const PortraitModeFocusTraversalPolicy({
    super.requestFocusCallback,
    required this.backButtonNode,
    required this.switchQuranNode,
    required this.pageSelectorNode,
    required this.switchToPlayQuranFocusNode,
  });

  @override
  FocusNode? findFirstFocus(FocusNode currentNode, {bool ignoreCurrentFocus = false}) {
    return backButtonNode;
  }

  @override
  FocusNode findLastFocus(FocusNode currentNode, {bool ignoreCurrentFocus = false}) {
    return pageSelectorNode;
  }

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    print('Current Node: ${currentNode.debugLabel}, Direction: $direction, || FocusNode: ${currentNode}');

    if (currentNode == backButtonNode) {
      switch (direction) {
        case TraversalDirection.right:
          if (_canFocusNode(switchQuranNode)) {
            _requestFocus(switchQuranNode);
            return true;
          }
          break;
        case TraversalDirection.down:
          if (_canFocusNode(pageSelectorNode)) {
            _requestFocus(pageSelectorNode);
            return true;
          }
          break;
        default:
          return false;
      }
    } else if (currentNode == switchQuranNode) {
      switch (direction) {
        case TraversalDirection.left:
          if (_canFocusNode(backButtonNode)) {
            _requestFocus(backButtonNode);
            return true;
          }
          break;
        case TraversalDirection.right:
          if (_canFocusNode(pageSelectorNode)) {
            _requestFocus(pageSelectorNode);
            return true;
          }
          break;
        case TraversalDirection.down:
          if (_canFocusNode(pageSelectorNode)) {
            _requestFocus(pageSelectorNode);
            return true;
          }
          break;
        default:
          break;
      }
    } else if (currentNode == pageSelectorNode) {
      switch (direction) {
        case TraversalDirection.up:
          if (_canFocusNode(switchQuranNode)) {
            _requestFocus(switchQuranNode);
            return true;
          }
          break;
        case TraversalDirection.down:
          if (_canFocusNode(backButtonNode)) {
            _requestFocus(backButtonNode);
            return true;
          }
          break;
        case TraversalDirection.left:
          if (_canFocusNode(switchQuranNode)) {
            _requestFocus(switchQuranNode);
            return true;
          }
          break;
        case TraversalDirection.right:
          print('Current Node: Right test');
          if (_canFocusNode(switchToPlayQuranFocusNode)) {
            _requestFocus(switchToPlayQuranFocusNode);
            return true;
          }
          break;
        default:
          break;
      }
    } else if (currentNode == switchToPlayQuranFocusNode) {
      switch (direction) {
        case TraversalDirection.up:
          if (_canFocusNode(switchQuranNode)) {
            _requestFocus(switchQuranNode);
            return true;
          }
          break;
        case TraversalDirection.left:
          if (_canFocusNode(switchQuranNode)) {
            _requestFocus(switchQuranNode);
            return true;
          }
          break;

        default:
          break;
      }
    }
    return false;
  }

  bool _canFocusNode(FocusNode node) {
    return node.canRequestFocus;
  }

  void _requestFocus(FocusNode node) {
    requestFocusCallback.call(node);
  }

  @override
  FocusNode? findFirstFocusInDirection(FocusNode currentNode, TraversalDirection direction) {
    return null;
  }

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    return [backButtonNode, switchQuranNode, pageSelectorNode].where((node) => descendants.contains(node));
  }
}
