import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/pages/quran/page/quran_reading_screen.dart';
import 'package:mawaqit/src/pages/quran/widget/recite_type_grid_view.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';
import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:mawaqit/i18n/l10n.dart';

import 'package:mawaqit/src/pages/quran/widget/reciter_list_view.dart';

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

  late FocusNode favoriteFocusNode;
  late FocusNode changeReadingModeFocusNode;

  late FocusScopeNode reciteTypeFocusScopeNode;
  late FocusScopeNode reciteFocusScopeNode;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reciteNotifierProvider.notifier);
    });

    changeReadingModeFocusNode = FocusNode(debugLabel: 'change_reading_mode_focus_node');
    favoriteFocusNode = FocusNode(debugLabel: 'favorite_focus_node');

    reciteTypeFocusScopeNode = FocusScopeNode(debugLabel: 'reciter_type_focus_scope_node');
    reciteFocusScopeNode = FocusScopeNode(debugLabel: 'reciter_focus_scope_node');

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _reciterScrollController.dispose();

    favoriteFocusNode.dispose();
    changeReadingModeFocusNode.dispose();

    reciteTypeFocusScopeNode.dispose();
    reciteFocusScopeNode.dispose();

    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('ReciterSelectionScreen build');
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: SizedBox(
        width: 40.sp, // Set the desired width
        height: 40.sp, // Set the desired height
        child: FloatingActionButton(
          focusNode: changeReadingModeFocusNode,
          focusColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.black.withOpacity(.5),
          child: Icon(
            Icons.menu_book,
            color: Colors.white,
            size: 15.sp,
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
      appBar: AppBar(
        backgroundColor: Color(0xFF28262F),
        elevation: 0,
        title: Text(
          S.of(context).chooseReciter,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            focusNode: favoriteFocusNode,
            focusColor: Theme.of(context).primaryColor,
            splashRadius: 14.sp,
            icon: Icon(
              favoriteFocusNode.hasFocus ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              ref.read(reciteNotifierProvider).maybeWhen(
                    data: (reciterState) {
                      return reciterState.selectedReciter.fold(
                        () => null,
                        (selectedReciter) async {
                          final notifier = ref.read(reciteNotifierProvider.notifier);

                          if (notifier.isReciterFavorite(selectedReciter)) {
                            await notifier.removeFavoriteReciter(selectedReciter);
                            Fluttertoast.showToast(
                              msg: S.of(context).reciterRemovedFromFavorites(selectedReciter.name),
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 10.sp,
                            );
                          } else {
                            await notifier.addFavoriteReciter(selectedReciter);
                            Fluttertoast.showToast(
                              msg: S.of(context).reciterAddedToFavorites(selectedReciter.name),
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 10.sp,
                            );
                          }
                        },
                      );
                    },
                    orElse: () => [],
                  );
            },
          ),
        ],
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: S.of(context).allReciters,
              icon: Icon(Icons.list),
            ),
            Tab(
              text: S.of(context).favorites,
              icon: Icon(Icons.favorite),
            ),
          ],
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
        // padding: EdgeInsets.only(top: 5.h),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildReciterList(isAllReciters: true),
            _buildReciterList(isAllReciters: false),
          ],
        ),
      ),
    );
  }

  Widget _buildReciterList({required bool isAllReciters}) {
    print('ReciterSelectionScreen isAllReciters: $isAllReciters');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FocusScope(
                  node: reciteFocusScopeNode,
                  onKeyEvent: _handleReciteFocusScopeKeyEvent,
                  child: ref.watch(reciteNotifierProvider).when(
                        data: (reciter) {
                          final displayReciters = isAllReciters ? reciter.reciters : reciter.favoriteReciters;
                          return ReciterListView(
                            reciters: displayReciters,
                          );
                        },
                        loading: () => _buildReciterListShimmer(true),
                        error: (error, stackTrace) => Text('Error: $error'),
                      ),
                ),
                Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      FocusScope(
                        node: reciteTypeFocusScopeNode,
                        onKeyEvent: _handleReciteTypeFocusScopeKeyEvent,
                        child: ref.watch(reciteNotifierProvider).when(
                              data: (reciterState) {
                                if (reciterState.favoriteReciters.isEmpty && !isAllReciters) {
                                  return Container(
                                    margin: EdgeInsets.only(top: 2.h),
                                    child: Text(
                                      S.of(context).noFavoriteReciters,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  );
                                }
                                return Column(
                                  children: [
                                    SizedBox(height: 3.h),
                                    Text(
                                      S.of(context).reciteType,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    reciterState.selectedReciter.fold(
                                      () => Container(),
                                      (selectedReciter) => ReciteTypeGridView(
                                        reciterTypes: selectedReciter.moshaf,
                                      ),
                                    )
                                  ],
                                );
                              },
                              loading: () {
                                return Column(children: [
                                  SizedBox(height: 3.h),
                                  Text(
                                    S.of(context).reciteType,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  _buildReciteTypeGridShimmer(true),
                                ]);
                              },
                              error: (error, stackTrace) => Text('Error: $error'),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildReciteTypeGridShimmer(bool isDarkMode) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }

  KeyEventResult _handleReciteFocusScopeKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        reciteFocusScopeNode.unfocus();
        reciteTypeFocusScopeNode.requestFocus();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        reciteFocusScopeNode.unfocus();
        favoriteFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleReciteTypeFocusScopeKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
      reciteTypeFocusScopeNode.unfocus();
      reciteFocusScopeNode.requestFocus();
      return KeyEventResult.handled;
    } else if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
      reciteTypeFocusScopeNode.unfocus();
      changeReadingModeFocusNode.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
