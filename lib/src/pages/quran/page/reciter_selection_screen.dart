import 'dart:async';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/pages/quran/page/schedule_screen.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';
import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';
import 'package:mawaqit/src/state_management/quran/recite/recite_state.dart';
import 'package:mawaqit/src/state_management/quran/schedule_listening/audio_control_notifier.dart';
import 'package:mawaqit/src/state_management/quran/schedule_listening/audio_control_state.dart';
import 'package:mawaqit/src/state_management/quran/schedule_listening/schedule_listening_notifier.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/quran/widget/reciter_list_view.dart';
import '../reading/quran_reading_screen.dart';
import 'package:mawaqit/src/routes/routes_constant.dart';

class AudioControlWidget extends ConsumerWidget {
  final double buttonSize;
  final double iconSize;

  const AudioControlWidget({
    Key? key,
    required this.buttonSize,
    required this.iconSize,
  }) : super(key: key);

  bool _isWithinScheduledTime(TimeOfDay startTime, TimeOfDay endTime) {
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }
    return currentMinutes >= startMinutes || currentMinutes < endMinutes;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(audioControlProvider).when(
          data: (state) {
            final scheduleState = ref.watch(scheduleProvider);

            return scheduleState.when(
              data: (schedule) {
                final isWithinTime = _isWithinScheduledTime(schedule.startTime, schedule.endTime);
                final shouldShow = schedule.isScheduleEnabled && isWithinTime;

                if (!shouldShow) return const SizedBox.shrink();

                return SizedBox(
                  width: buttonSize,
                  height: buttonSize,
                  child: FloatingActionButton(
                    focusColor: Theme.of(context).primaryColor,
                    backgroundColor: state.status == AudioStatus.playing ? Colors.red : Colors.black.withOpacity(.5),
                    child: Icon(
                      color: Colors.white,
                      state.status == AudioStatus.playing ? Icons.pause : Icons.play_arrow,
                      size: iconSize,
                    ),
                    onPressed: () {
                      ref.read(audioControlProvider.notifier).togglePlayback();
                    },
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, _) => Text('Error: $error'),
        );
  }
}

class ReciterSelectionScreen extends ConsumerStatefulWidget {
  final String surahName;
  static double horizontalPadding = 3.w;

  const ReciterSelectionScreen({super.key, required this.surahName});

  const ReciterSelectionScreen.withoutSurahName({super.key}) : surahName = '';

  @override
  createState() => _ReciterSelectionScreenState();
}

class _ReciterSelectionScreenState extends ConsumerState<ReciterSelectionScreen> with SingleTickerProviderStateMixin {
  bool isKeyboardVisible = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _reciterScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  late FocusScopeNode favoritesListFocusNode;
  late FocusScopeNode allRecitersListFocusNode;
  late FocusScopeNode changeReadingModeFocusNode;
  late FocusScopeNode searchListFocusNode;
  late FocusNode searchFocusScopeNode;

  late StreamSubscription<bool> keyboardSubscription;

  bool _isSearching = false;
  bool _foundReciters = false;

  @override
  void initState() {
    super.initState();
    _initializeFocusNodes();
    _setupKeyboardListener();
  }

  @override
  void dispose() {
    _disposeFocusNodes();
    keyboardSubscription.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeFocusNodes() {
    searchFocusScopeNode = FocusNode(debugLabel: 'search_focus_node');
    favoritesListFocusNode = FocusScopeNode(debugLabel: 'favorites_list_focus_scope_node');
    allRecitersListFocusNode = FocusScopeNode(debugLabel: 'all_reciters_list_focus_scope_node');
    searchListFocusNode = FocusScopeNode(debugLabel: 'search_list_focus_scope_node');
    changeReadingModeFocusNode = FocusScopeNode(debugLabel: 'change_reading_mode_focus_scope_node');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reciteNotifierProvider.notifier);
      _setInitialFocus();
    });
  }

  void _disposeFocusNodes() {
    searchFocusScopeNode.dispose();
    favoritesListFocusNode.dispose();
    allRecitersListFocusNode.dispose();
    changeReadingModeFocusNode.dispose();
    searchListFocusNode.dispose();
  }

  void _setupKeyboardListener() {
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
    });
  }

  void _setInitialFocus() {
    if (!mounted) return; // Check if the widget is still mounted
    if (_hasFavorites()) {
      favoritesListFocusNode.requestFocus();
    } else {
      allRecitersListFocusNode.requestFocus();
    }
  }

  bool _hasFavorites() {
    return ref.read(reciteNotifierProvider).maybeWhen(
          data: (reciterState) => reciterState.favoriteReciters.isNotEmpty,
          orElse: () => false,
        );
  }

  void _navigateToReading() {
    ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.reading);
    Navigator.pushReplacementNamed(context, Routes.quranReading);
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = MediaQuery.of(context).size.width * 0.07;
    final iconSize = buttonSize * 0.5;
    final spacerWidth = buttonSize * 0.25;

    _setupFocusNodeCallbacks();

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      floatingActionButton: _buildFloatingColumn(spacerWidth, buttonSize, iconSize, context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  void _setupFocusNodeCallbacks() {
    favoritesListFocusNode.onKey = _handleFavoritesListKeyEvent;
    allRecitersListFocusNode.onKey = _handleAllRecitersListKeyEvent;
    changeReadingModeFocusNode.onKey = _handleChangeReadingModeKeyEvent;
    searchListFocusNode.onKey = _handleSearchListKeyEvent;
  }

  KeyEventResult _handleFavoritesListKeyEvent(FocusNode node, RawKeyEvent event) {
    if (!mounted) return KeyEventResult.ignored; // Check if the widget is still mounted
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        allRecitersListFocusNode.requestFocus();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        searchFocusScopeNode.requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleAllRecitersListKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_hasFavorites()) {
          favoritesListFocusNode.requestFocus();
        } else {
          searchFocusScopeNode.requestFocus();
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        changeReadingModeFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleChangeReadingModeKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (_foundReciters && !ref.read(reciteNotifierProvider.notifier).isQueryEmpty) {
          searchListFocusNode.requestFocus();
        } else {
          if (_hasFavorites()) {
            favoritesListFocusNode.requestFocus();
          } else {
            allRecitersListFocusNode.requestFocus();
          }
        }
        return KeyEventResult.handled;
      } else if(event.logicalKey == LogicalKeyboardKey.arrowUp) {
        final changeReadingFloatingActionFocusNode = changeReadingModeFocusNode.children.toList()[0];
        if(!_foundReciters && changeReadingFloatingActionFocusNode.hasFocus){
          searchFocusScopeNode.requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleSearchListKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        searchFocusScopeNode.requestFocus();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        changeReadingModeFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 40,
      backgroundColor: Color(0xFF28262F),
      elevation: 0,
      title: AutoSizeText(
        S.of(context).chooseReciter,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        minFontSize: 6.sp.roundToDouble(),
        maxFontSize: 20.sp.roundToDouble(),
        stepGranularity: 1,
      ),
      centerTitle: true,
      leading: IconButton(
        splashRadius: 14.sp,
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(R.ASSETS_BACKGROUNDS_QURAN_BACKGROUND_PNG),
          fit: BoxFit.cover,
        ),
        gradient: ThemeNotifier.quranBackground(),
      ),
      child: Column(
        children: [
          SizedBox(height: 8.h, child: _buildSearchField()),
          isKeyboardVisible
              ? const SizedBox.shrink()
              : Expanded(
                  child: ref.watch(reciteNotifierProvider).when(
                        data: (reciterState) => _buildReciterList(reciterState),
                        loading: () => Column(
                          children: [
                            _buildReciterListShimmer(true),
                            SizedBox(height: 20),
                            _buildReciterListShimmer(true),
                          ],
                        ),
                        error: (error, stackTrace) => Center(
                          child: Text(
                            'Error: $error',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                ),
        ],
      ),
    );
  }

  Widget _buildReciterList(ReciteState reciterState) {
    final hasFavorites = reciterState.favoriteReciters.isNotEmpty;

    if (_isSearching) {
      return _buildSearchResults(reciterState);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasFavorites) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildFavoriteSection(reciterState),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildAllRecitersSection(reciterState),
            ),
          ),
        ] else ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildAllRecitersSection(reciterState),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildFavoriteSection(reciterState),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchResults(ReciteState reciterState) {
    if (reciterState.filteredReciters.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ReciterSelectionScreen.horizontalPadding),
            child: Text(
              S.of(context).noReciterSearchResult,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 2.h),
        FocusScope(
          node: searchListFocusNode,
          child: ReciterListView(
            reciters: reciterState.filteredReciters,
            isAtBottom: false,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFavoriteSection(ReciteState reciterState) {
    return [
      SizedBox(height: 1.h),
      _buildFavoritesHeader(),
      SizedBox(height: 1.h),
      if (reciterState.favoriteReciters.isEmpty)
        _buildEmptyFavorites()
      else
        Expanded(
          child: FocusScope(
            node: favoritesListFocusNode,
            child: ReciterListView(
              reciters: reciterState.favoriteReciters,
              isAtBottom: !_hasFavorites(),
            ),
          ),
        ),
      SizedBox(height: 2.h),
    ];
  }

  List<Widget> _buildAllRecitersSection(ReciteState reciterState) {
    return [
      SizedBox(height: 1.h),
      _buildAllRecitersHeader(),
      SizedBox(height: 1.h),
      Expanded(
        child: FocusScope(
          node: allRecitersListFocusNode,
          child: ReciterListView(
            reciters: reciterState.reciters,
            isAtBottom: _hasFavorites(),
          ),
        ),
      ),
    ];
  }

  Widget _buildFloatingColumn(double spacerWidth, double buttonSize, double iconSize, BuildContext context) {
    return FocusScope(
      node: changeReadingModeFocusNode,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ref.watch(reciteNotifierProvider).whenOrNull(
                    data: (reciter) => Padding(
                      padding: EdgeInsets.only(bottom: spacerWidth),
                      child: SizedBox(
                        width: buttonSize,
                        height: buttonSize,
                        child: FloatingActionButton(
                          autofocus: changeReadingModeFocusNode.hasFocus, // it is used here because at change_reading_mode it will break due to up keybind when no result in the search
                          heroTag: 'schedule',
                          backgroundColor: Colors.black.withOpacity(.5),
                          child: Icon(
                            Icons.schedule,
                            color: Colors.white,
                            size: iconSize,
                          ),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => ScheduleScreen(reciterList: reciter.reciters),
                            );
                          },
                        ),
                      ),
                    ),
                  ) ??
              const SizedBox.shrink(),
          Padding(
            padding: EdgeInsets.only(bottom: spacerWidth),
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: FloatingActionButton(
                heroTag: 'change_reading_mode',
                focusColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.black.withOpacity(.5),
                child: Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: iconSize,
                ),
                onPressed: () async {
                  _navigateToReading();
                },
              ),
            ),
          ),
          AudioControlWidget(
            buttonSize: buttonSize,
            iconSize: iconSize,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ReciterSelectionScreen.horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite,
            color: Theme.of(context).primaryColor,
            size: 16.sp,
          ),
          SizedBox(width: 12),
          Text(
            S.of(context).favorites,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllRecitersHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ReciterSelectionScreen.horizontalPadding),
      child: Row(
        children: [
          SizedBox(width: 8),
          Text(
            S.of(context).allReciters,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return Container(
      height: 12.h,
      margin: EdgeInsets.symmetric(horizontal: ReciterSelectionScreen.horizontalPadding, vertical: 10),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            color: Colors.white54,
            size: 22.sp,
          ),
          SizedBox(height: 12),
          Text(
            S.of(context).noFavoriteReciters,
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'Roboto',
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ReciterSelectionScreen.horizontalPadding, vertical: 10),
      child: TextField(
        focusNode: searchFocusScopeNode,
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _isSearching = value.isNotEmpty;
          });
          ref.read(reciteNotifierProvider.notifier).setSearchQuery(value);
        },
        onSubmitted: (value) {
          if (value.isEmpty) {
            setState(() {
              _isSearching = false;
              _foundReciters = false;
            });
            _setInitialFocus();
            return;
          }

          final state = ref.read(reciteNotifierProvider);
          state.maybeWhen(
            data: (reciterState) {
              setState(() {
                _foundReciters = reciterState.filteredReciters.isNotEmpty;
              });

              if (_foundReciters) {
                searchListFocusNode.requestFocus();
              } else {
                // No results found - focus should stay on change reading mode button
                changeReadingModeFocusNode.requestFocus();
              }
            },
            orElse: () {
              setState(() {
                _foundReciters = false;
              });
              changeReadingModeFocusNode.requestFocus();
            },
          );
        },
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: S.of(context).searchForReciter,
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white24,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildReciterListShimmer(bool isDarkMode) {
    return Container(
      height: 16.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        itemBuilder: (context, index) {
          return Container(
            width: 25.w,
            margin: EdgeInsets.only(right: 16),
            child: Shimmer.fromColors(
              baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
