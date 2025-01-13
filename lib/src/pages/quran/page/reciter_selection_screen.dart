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

  // final FocusNode scheduleListeningFocusNode;

  const AudioControlWidget({
    Key? key,
    required this.buttonSize,
    required this.iconSize,
    // required this.scheduleListeningFocusNode,
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

                if (!shouldShow) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  width: buttonSize, // Set the desired width
                  height: buttonSize, // Set the desired height
                  child: FloatingActionButton(
                    // focusNode: scheduleListeningFocusNode,
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _reciterScrollController = ScrollController();
  double sizeOfContainerReciter = 15.w;
  double marginOfContainerReciter = 16;

  late FocusScopeNode favoritesListFocusNode;
  late FocusScopeNode allRecitersListFocusNode;
  late FocusScopeNode changeReadingModeFocusNode;
  late FocusScopeNode searchListFocusNode;
  late FocusNode searchFocusScopeNode;

  // late FocusNode scheduleListeningFocusNode;
  //
  // late FocusScopeNode reciteTypeFocusScopeNode;
  // late FocusScopeNode reciteFocusScopeNode;

  final TextEditingController _searchController = TextEditingController();
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reciteNotifierProvider.notifier);
    });

    // Set initial focus to favorites list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasFavorites()) {
        favoritesListFocusNode.requestFocus();
      } else {
        allRecitersListFocusNode.requestFocus();
      }
    });

    var keyboardVisibilityController = KeyboardVisibilityController();
    // Setup keyboard listener
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        if (_hasFavorites()) {
          favoritesListFocusNode.requestFocus();
        } else {
          allRecitersListFocusNode.requestFocus();
        }
      }
    });

    // Initialize focus nodes
    searchFocusScopeNode = FocusNode(debugLabel: 'search_focus_scope');
    favoritesListFocusNode = FocusScopeNode(debugLabel: 'favorites_list_focus_node');
    allRecitersListFocusNode = FocusScopeNode(debugLabel: 'all_reciters_list_focus_node');
    searchListFocusNode = FocusScopeNode(debugLabel: 'search_list_focus_node');
    changeReadingModeFocusNode = FocusScopeNode(debugLabel: 'change_reading_mode_focus_node');
  }

  @override
  void dispose() {
    searchFocusScopeNode.dispose();
    favoritesListFocusNode.dispose();
    allRecitersListFocusNode.dispose();
    changeReadingModeFocusNode.dispose();
    keyboardSubscription.cancel();
    searchListFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool _isSearching = false;
  bool _foundReciters = false;

  void _navigateToReading() {
    ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.reading);
    Navigator.pushReplacementNamed(context, Routes.quranReading);
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = MediaQuery.of(context).size.width * 0.07;
    final iconSize = buttonSize * 0.5;
    final spacerWidth = buttonSize * 0.25;

    favoritesListFocusNode.onKey = (node, event) {
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
    };

    allRecitersListFocusNode.onKey = (node, event) {
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
    };

    changeReadingModeFocusNode.onKey = (node, event) {
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
        }
      }
      return KeyEventResult.ignored;
    };

    searchListFocusNode.onKey = (node, event) {
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
    };

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: buildFloatingColumn(spacerWidth, buttonSize, iconSize, context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
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
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(R.ASSETS_BACKGROUNDS_QURAN_BACKGROUND_PNG),
            fit: BoxFit.cover,
          ),
          gradient: ThemeNotifier.quranBackground(),
        ),
        child: ListView(
          children: [
            SizedBox(
              height: 8.h,
              child: _buildSearchField(),
            ),
            ref.watch(reciteNotifierProvider).when(
                  data: (reciterState) {
                    final hasFavorites = reciterState.favoriteReciters.isNotEmpty;
                    if (_isSearching) {
                      // if no reciters found
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

                      final searchedRecitersSection = [
                        SizedBox(height: 2.h),
                        SizedBox(
                          height: 16.h,
                          child: FocusScope(
                            node: searchListFocusNode,
                            child: ReciterListView(
                              reciters: reciterState.filteredReciters,
                              isAtBottom: false, // Bottom if favorites exist
                            ),
                          ),
                        ),
                      ];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...searchedRecitersSection,
                        ],
                      );
                    }
                    final favoriteSection = [
                      SizedBox(height: 1.h),
                      _buildFavoritesHeader(),
                      SizedBox(height: 1.h),
                      if (reciterState.favoriteReciters.isEmpty)
                        _buildEmptyFavorites()
                      else
                        SizedBox(
                          height: 16.h,
                          child: FocusScope(
                            node: favoritesListFocusNode,
                            child: ReciterListView(
                              reciters: reciterState.favoriteReciters,
                              isAtBottom: !hasFavorites, // Only bottom if empty
                            ),
                          ),
                        ),
                      SizedBox(height: 2.h),
                    ];

                    final allRecitersSection = [
                      SizedBox(height: 1.h),
                      _buildAllRecitersHeader(),
                      SizedBox(height: 1.h),
                      SizedBox(
                        height: 16.h,
                        child: FocusScope(
                          node: allRecitersListFocusNode,
                          child: ReciterListView(
                            reciters: reciterState.reciters,
                            isAtBottom: hasFavorites, // Bottom if favorites exist
                          ),
                        ),
                      ),
                    ];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: hasFavorites
                          ? [
                              ...favoriteSection,
                              ...allRecitersSection,
                            ]
                          : [
                              ...allRecitersSection,
                              ...favoriteSection,
                            ],
                    );
                  },
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
          ],
        ),
      ),
    );
  }

  FocusScope buildFloatingColumn(double spacerWidth, double buttonSize, double iconSize, BuildContext context) {
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
                  ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.reading);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuranReadingScreen(),
                    ),
                  );
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
      padding: EdgeInsets.symmetric(
        horizontal: ReciterSelectionScreen.horizontalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Aligns items to the start of the row
        crossAxisAlignment: CrossAxisAlignment.center, // Vertically centers items
        children: [
          Icon(
            Icons.favorite,
            color: Theme.of(context).primaryColor,
            size: 18.sp, // Slightly larger icon for better emphasis
          ),
          SizedBox(width: 12), // Increased spacing for a cleaner layout
          Text(
            S.of(context).favorites,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
              fontSize: 16.sp, // Slightly larger text for better readability
              fontWeight: FontWeight.w600, // Semi-bold for a polished look
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
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return Container(
      height: 16.h,
      margin: EdgeInsets.symmetric(horizontal: ReciterSelectionScreen.horizontalPadding, vertical: 10),
      padding: EdgeInsets.all(16),
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
          SizedBox(
            height: 12,
          ),
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
            _isSearching = false;
            _foundReciters = false;
            if (_hasFavorites()) {
              favoritesListFocusNode.requestFocus();
              print('No reciters found 2');
            } else {
              allRecitersListFocusNode.requestFocus();
            }
            return;
          }
          final state = ref.read(reciteNotifierProvider);
          state.maybeWhen(
            data: (reciterState) {
              if (reciterState.filteredReciters.isNotEmpty) {
                searchListFocusNode.requestFocus();
                _foundReciters = true;
              } else {
                print('No reciters found');
                if (_hasFavorites()) {
                  print('No reciters found 1');
                  favoritesListFocusNode.requestFocus();
                } else {
                  print('No reciters found 3');
                  allRecitersListFocusNode.requestFocus();
                }
              }
            },
            orElse: () {},
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
            margin: EdgeInsets.only(right: marginOfContainerReciter),
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

  bool _hasFavorites() {
    return ref.read(reciteNotifierProvider).maybeWhen(
          data: (reciterState) => reciterState.favoriteReciters.isNotEmpty,
          orElse: () => false,
        );
  }
}
