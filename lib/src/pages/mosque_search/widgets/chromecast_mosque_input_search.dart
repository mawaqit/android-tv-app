import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/state_management/on_boarding/v2/search_selection_type_provider.dart';
import 'package:mawaqit/src/widgets/mosque_simple_tile.dart';
import 'package:provider/provider.dart' as Provider;
import '../../../../i18n/AppLanguage.dart';
import '../../../helpers/AppRouter.dart';
import '../../../helpers/SharedPref.dart';
import '../../../helpers/keyboard_custom.dart';
import '../../../state_management/random_hadith/random_hadith_notifier.dart';
import '../../home/OfflineHomeScreen.dart';
import 'package:fpdart/fpdart.dart' as fp;

class ChromeCastMosqueInputSearch extends ConsumerStatefulWidget {
  const ChromeCastMosqueInputSearch({
    Key? key,
    this.onDone,
    this.selectedNode = const fp.None(),
  }) : super(key: key);

  final void Function()? onDone;
  final fp.Option<FocusNode> selectedNode;

  @override
  ConsumerState<ChromeCastMosqueInputSearch> createState() => _ChromeCastMosqueInputSearchState();
}

class _ChromeCastMosqueInputSearchState extends ConsumerState<ChromeCastMosqueInputSearch> {
  final inputController = TextEditingController();
  final scrollController = ScrollController();
  SharedPref sharedPref = SharedPref();

  List<Mosque> results = [];
  bool loading = false;
  bool noMore = false;
  String? error;
  
  // Focus nodes
  final FocusNode _searchFocusNode = FocusNode(debugLabel: 'chromecast_search_node');
  final FocusNode _loadMoreFocusNode = FocusNode(debugLabel: 'chromecast_load_more_node');
  final FocusNode _mainFocusNode = FocusNode(debugLabel: 'chromecast_main_focus_node');
  
  // Create focus nodes for each result item
  List<FocusNode> _resultFocusNodes = [];

  // Current focused index in the result list
  int _currentFocusIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mosqueManagerProvider.notifier).state = None();
      _searchFocusNode.requestFocus();
    });
    
    // Add listener to load more focus node
    _loadMoreFocusNode.addListener(_onLoadMoreFocus);
  }
  
  void _onLoadMoreFocus() {
    if (_loadMoreFocusNode.hasFocus && !loading && !noMore && loadMore != null) {
      loadMore?.call();
      scrollToTheEndOfTheList();
    }
  }
  
  // Create or update focus nodes for result items
  void _updateFocusNodes() {
    // Clear old focus nodes
    for (var node in _resultFocusNodes) {
      node.dispose();
    }
    
    // Create new focus nodes for each result
    _resultFocusNodes = List.generate(
      results.length,
      (index) => FocusNode(debugLabel: 'chromecast_result_${index}_node'),
    );
    
    // Add listeners to each node
    for (int i = 0; i < _resultFocusNodes.length; i++) {
      _resultFocusNodes[i].addListener(() {
        if (_resultFocusNodes[i].hasFocus) {
          setState(() {
            _currentFocusIndex = i;
          });
        }
      });
    }
  }

  void Function()? loadMore;

  onboardingWorkflowDone() {
    sharedPref.save('boarding', 'true');
    AppRouter.pushReplacement(OfflineHomeScreen());
  }

  void scrollToTheEndOfTheList() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: 200.milliseconds,
      curve: Curves.ease,
    );
  }

  void _searchMosque(String mosque, int page) async {
    if (loading) return;
    loadMore = () => _searchMosque(mosque, page + 1);

    if (mosque.isEmpty) {
      setState(() {
        error = S.of(context).mosqueNameError;
        loading = false;
      });
      return;
    }

    setState(() {
      error = null;
      loading = true;
    });
    
    final mosqueManager = Provider.Provider.of<MosqueManager>(context, listen: false);
    await mosqueManager
        .searchMosques(mosque, page: page)
        .then((value) => setState(() {
              loading = false;

              if (page == 1) {
                results = [];
                _currentFocusIndex = -1;
              }

              // Check if the current batch of results is empty
              noMore = value.isEmpty;
              
              // Save current results length before adding new results
              final oldResultsLength = results.length;
              
              results = [...results, ...value];
              
              // Update focus nodes for the new result list
              _updateFocusNodes();
              
              // If we load more and were on the last item, 
              // update to focus on the first new item
              if (page > 1 && _currentFocusIndex == oldResultsLength - 1 && value.isNotEmpty) {
                _currentFocusIndex = oldResultsLength;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _resultFocusNodes[_currentFocusIndex].requestFocus();
                  _ensureItemVisible(_currentFocusIndex);
                });
              }
            }))
        .catchError((e, stack) => setState(() {
              logger.w(e.toString(), stackTrace: stack);
              loading = false;
              error = S.of(context).backendError;
            }));
  }

  /// handle on mosque tile clicked
  Future<void> _selectMosque(Mosque mosque) {
    return context.read<MosqueManager>().setMosqueUUid(mosque.uuid.toString()).then((value) {
      // !context.read<MosqueManager>().typeIsMosque ? onboardingWorkflowDone() : widget.onDone?.call();
      if (context.read<MosqueManager>().typeIsMosque) {
        // Home flow
        ref.read(mosqueManagerProvider.notifier).state = Option.fromNullable(SearchSelectionType.mosque);
      } else {
        ref.read(mosqueManagerProvider.notifier).state = Option.fromNullable(SearchSelectionType.home);
      }
    }).catchError((e, stack) {
      if (e is InvalidMosqueId) {
        setState(() {
          loading = false;
          error = S.of(context).slugError;
        });
      } else {
        setState(() {
          loading = false;
          error = S.of(context).backendError;
        });
      }
    });
  }

  // Handle key events for the entire search component
  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // If there are no results, no special handling is needed
    if (results.isEmpty) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_searchFocusNode.hasFocus) {
        // If search field is focused and user presses up, move to the last result
        if (results.isNotEmpty) {
          setState(() {
            _currentFocusIndex = results.length - 1;
          });
          _resultFocusNodes[_currentFocusIndex].requestFocus();
          _ensureItemVisible(_currentFocusIndex);
        }
        return KeyEventResult.handled;
      } else if (_currentFocusIndex == 0) {
        // If at first result and user presses up, move focus to search field
        setState(() {
          _currentFocusIndex = -1;
        });
        _searchFocusNode.requestFocus();
        return KeyEventResult.handled;
      } else if (_currentFocusIndex > 0) {
        // Normal upward navigation within the list
        setState(() {
          _currentFocusIndex--;
        });
        _resultFocusNodes[_currentFocusIndex].requestFocus();
        _ensureItemVisible(_currentFocusIndex);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_searchFocusNode.hasFocus) {
        // If search field is focused and user presses down, move to the first result
        if (results.isNotEmpty) {
          setState(() {
            _currentFocusIndex = 0;
          });
          _resultFocusNodes[_currentFocusIndex].requestFocus();
          _ensureItemVisible(_currentFocusIndex);
        }
        return KeyEventResult.handled;
      } else if (_currentFocusIndex == results.length - 1) {
        // If at last result and user presses down
        if (!noMore && loadMore != null) {
          // Load more results when reaching the end and there are more to load
          loadMore?.call();
          
          // Keep the focus on the last item until new results load
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToTheEndOfTheList();
          });
          
          return KeyEventResult.handled;
        } else {
          // If no more results, wrap around to search field
          setState(() {
            _currentFocusIndex = -1;
          });
          _searchFocusNode.requestFocus();
          return KeyEventResult.handled;
        }
      } else if (_currentFocusIndex >= 0 && _currentFocusIndex < results.length - 1) {
        // Normal downward navigation within the list
        setState(() {
          _currentFocusIndex++;
        });
        
        _resultFocusNodes[_currentFocusIndex].requestFocus();
        
        // Auto-scroll to make sure the focused item is visible
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _ensureItemVisible(_currentFocusIndex);
        });
        
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.space) {
      // If Enter/Space is pressed and we're on a result item, select it
      if (_currentFocusIndex >= 0 && _currentFocusIndex < results.length) {
        _selectMosque(results[_currentFocusIndex]);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.goBack) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
  
  // Helper method to ensure the item at the given index is visible
  void _ensureItemVisible(int index) {
    if (index < 0 || index >= results.length || !scrollController.hasClients) return;
    
    // Approximate item height (adjust as needed)
    final double itemHeight = 80.0;
    final double listViewHeight = MediaQuery.of(context).size.height * 0.6;
    
    // Calculate the approximate position of the item
    double itemPosition = index * itemHeight;
    
    // Ensure item is visible
    if (itemPosition < scrollController.offset || 
        itemPosition > scrollController.offset + listViewHeight) {
      scrollController.animateTo(
        itemPosition - (listViewHeight / 2) + (itemHeight / 2),
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _mainFocusNode.dispose();
    _loadMoreFocusNode.dispose();
    
    // Dispose all result focus nodes
    for (var node in _resultFocusNodes) {
      node.dispose();
    }
    
    inputController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      child: Focus(
        focusNode: _mainFocusNode,
        onKey: _handleKeyEvent,
        child: Align(
          alignment: Alignment(0, -.3),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.symmetric(vertical: 80, horizontal: 10),
            cacheExtent: 99999,
            children: [
              Text(
                S.of(context).searchMosque,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w700,
                  color: theme.brightness == Brightness.dark ? null : theme.primaryColor,
                ),
              ).animate().slideY(begin: -1).fade(),
              SizedBox(height: 20),
              searchField(theme).animate().slideX(begin: 1, delay: 200.milliseconds).fadeIn(),
              SizedBox(height: 20),
              for (var i = 0; i < results.length; i++)
                MosqueSimpleTile(
                  key: Key('mosque_tile_${results[i].uuid}'),
                  autoFocus: false,
                  mosque: results[i],
                  selectedNode: widget.selectedNode,
                  focusNode: _resultFocusNodes.isNotEmpty ? _resultFocusNodes[i] : null,
                  hasFocus: _currentFocusIndex == i, // Pass the focus state for visual indication
                  onTap: () => _selectMosque(results[i]),
                ).animate().slideX(delay: 70.milliseconds * (i % 5)).fade(),
              // to allow user to scroll to the end of list
              if (results.isNotEmpty)
                Focus(
                  focusNode: _loadMoreFocusNode,
                  child: Center(
                    child: SizedBox(
                      height: 40,
                      child: Builder(
                        builder: (context) {
                          if (loading) return CircularProgressIndicator();
                          if (noMore && results.isEmpty) return Text(S.of(context).mosqueNoResults);
                          if (noMore) return Text(S.of(context).mosqueNoMore);
                          return GestureDetector(
                            onTap: () {
                              if (!noMore && loadMore != null) {
                                loadMore?.call();
                                scrollToTheEndOfTheList();
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white10
                                    : theme.primaryColor.withOpacity(0.1),
                              ),
                              child: Text(
                                'load more',
                                style: TextStyle(
                                  color: theme.brightness == Brightness.dark ? Colors.white70 : theme.primaryColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchField(ThemeData theme) {
    return TextFormField(
      controller: inputController,
      style: GoogleFonts.inter(
        color: theme.brightness == Brightness.dark ? null : theme.primaryColor,
      ),
      onFieldSubmitted: (val) => _searchMosque(val, 1),
      cursorColor: theme.brightness == Brightness.dark ? null : theme.primaryColor,
      keyboardType: TextInputType.none,
      autofocus: true,
      focusNode: _searchFocusNode,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        filled: true,
        errorText: error,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        hintText: S.of(context).searchForMosque,
        hintStyle: TextStyle(
          fontWeight: FontWeight.normal,
          color: theme.brightness == Brightness.dark ? null : theme.primaryColor.withOpacity(0.4),
        ),
        suffixIcon: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _searchMosque(inputController.text, 1),
          child: Icon(Icons.search_rounded),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(width: 0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(width: 0),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 2,
          horizontal: 20,
        ),
      ),
    );
  }
}
