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

  late FocusNode reciterFocusNode;

  late FocusNode changeReadingModeFocusNode;

  // late FocusNode scheduleListeningFocusNode;
  //
  // late FocusScopeNode reciteTypeFocusScopeNode;
  // late FocusScopeNode reciteFocusScopeNode;

  final TextEditingController _searchController = TextEditingController();
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();

    changeReadingModeFocusNode = FocusNode(debugLabel: 'change_reading_mode_focus_node');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reciteNotifierProvider.notifier);
    });
    var keyboardVisibilityController = KeyboardVisibilityController();

    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        final isEmptyList = ref.read(reciteNotifierProvider).maybeWhen(
              data: (reciter) => reciter.filteredReciters.isEmpty,
              orElse: () => false,
            );
        if (isEmptyList) {
          // FocusScope.of(context).requestFocus(changeReadingModeFocusNode);
        } else {
          // FocusScope.of(context).requestFocus(reciteFocusScopeNode);
          // if (reciteFocusScopeNode.children.isNotEmpty) {
          //   reciteFocusScopeNode.children.first.requestFocus();
          // }
        }
      }
    });

    reciterFocusNode = FocusNode(debugLabel: 'reciter_focus_node');

    changeReadingModeFocusNode = FocusNode(debugLabel: 'change_reading_mode_focus_node');
    // scheduleListeningFocusNode = FocusNode(debugLabel: 'scheduleListeningFocusNode');
    // favoriteFocusNode = FocusNode(debugLabel: 'favorite_focus_node');
    //
    // reciteTypeFocusScopeNode = FocusScopeNode(debugLabel: 'reciter_type_focus_scope_node');
    // reciteFocusScopeNode = FocusScopeNode(debugLabel: 'reciter_focus_scope_node');

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _reciterScrollController.dispose();

    reciterFocusNode.dispose();
    // favoriteFocusNode.dispose();
    // changeReadingModeFocusNode.dispose();

    // reciteTypeFocusScopeNode.dispose();
    // reciteFocusScopeNode.dispose();
    // scheduleListeningFocusNode.dispose();

    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final isAllReciters = true;
    ref.read(reciteNotifierProvider.notifier).setSearchQuery(_searchController.text, isAllReciters);
  }

  void _navigateToReading() {
    ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.reading);
    Navigator.pushReplacementNamed(context, Routes.quranReading);
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioControlProvider);
    final buttonSize = MediaQuery.of(context).size.width * 0.07;
    final iconSize = buttonSize * 0.5;
    final spacerWidth = buttonSize * 0.25;

    reciterFocusNode.onKey = (node, event) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        reciterFocusNode.unfocus();
        changeReadingModeFocusNode.requestFocus();
        return KeyEventResult.handled;
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
                    log('hasFavorites: $hasFavorites || ${reciterState.favoriteReciters.map((e) => e.name)}');
                    final favoriteSection = [
                      _buildFavoritesHeader(),
                      if (reciterState.favoriteReciters.isEmpty)
                        _buildEmptyFavorites()
                      else
                        SizedBox(
                          height: 16.h,
                          child: ReciterListView(
                            reciters: reciterState.favoriteReciters,
                            isAtBottom: !hasFavorites, // Only bottom if empty
                          ),
                        ),
                      SizedBox(height: 2.h),
                    ];

                    final allRecitersSection = [
                      _buildAllRecitersHeader(),
                      SizedBox(
                        height: 16.h,
                        child: Focus(
                          focusNode: reciterFocusNode,
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

  Column buildFloatingColumn(double spacerWidth, double buttonSize, double iconSize, BuildContext context) {
    return Column(
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
              focusNode: changeReadingModeFocusNode,
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
    );
  }

  Widget _buildFavoritesHeader() {
    return Row(
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
    );
  }

  Widget _buildAllRecitersHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
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
      margin: EdgeInsets.symmetric(horizontal: 16),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              S.of(context).noFavoriteReciters,
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'Roboto',
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) {
          final isEmptyList = ref.read(reciteNotifierProvider).maybeWhen(
                data: (reciter) => reciter.filteredReciters.isEmpty,
                orElse: () => false,
              );
          // if (isEmptyList) {
          //   FocusScope.of(context).requestFocus(favoriteFocusNode);
          // } else {
          //   FocusScope.of(context).requestFocus(reciteFocusScopeNode);
          //   if (reciteFocusScopeNode.children.isNotEmpty) {
          //     reciteFocusScopeNode.children.first.requestFocus();
          //   }
          // }
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
}
