import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/pages/quran/widget/quran_background.dart';
import 'package:mawaqit/src/pages/quran/widget/surah_card.dart';
import 'package:mawaqit/src/state_management/quran/favorite/quran_favorite_notifier.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';

import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';
import 'package:shimmer/shimmer.dart';

import 'package:mawaqit/src/state_management/quran/recite/quran_audio_player_notifier.dart';
import 'package:mawaqit/src/pages/quran/page/quran_player_screen.dart';
import 'package:sizer/sizer.dart';

class SurahSelectionScreen extends ConsumerStatefulWidget {
  final int reciterId;
  final int riwayatId;

  const SurahSelectionScreen({
    super.key,
    required this.reciterId,
    required this.riwayatId,
  });

  @override
  ConsumerState createState() => _SurahSelectionScreenState();
}

class _SurahSelectionScreenState extends ConsumerState<SurahSelectionScreen> {
  int selectedIndex = 0;
  final int _crossAxisCount = 4;
  final ScrollController _scrollController = ScrollController();
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    RawKeyboard.instance.addListener(_handleKeyEvent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quranFavoriteNotifierProvider.notifier).getFavoriteSuwar(
            riwayatId: widget.riwayatId,
            reciterId: widget.reciterId,
          );
    });
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    _searchFocusNode = FocusNode();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranState = ref.watch(quranNotifierProvider);
    return QuranBackground(
      isSwitch: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      screen: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: quranState.when(
                    data: (data) {

                      return GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        controller: _scrollController,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _crossAxisCount,
                          childAspectRatio: 1.8,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: data.suwar.length,
                        itemBuilder: (context, index) {
                          return SurahCard(
                            onFavoriteTap: () {
                              log('quran: favorite: Favorite tap on index: $index');
                              ref.read(quranFavoriteNotifierProvider.notifier).saveFavoriteSuwar(
                                    reciterId: widget.reciterId,
                                    surahId: data.suwar[index].id,
                                    riwayatId: widget.riwayatId,
                                  );
                            },
                            isFavorite: ref.watch(quranFavoriteNotifierProvider).maybeWhen(
                                  orElse: () => false,
                                  data: (favoriteData) {
                                    if (favoriteData.favoriteMoshafs == null ||
                                        favoriteData.favoriteMoshafs!.moshafType != widget.riwayatId) {
                                      return false;
                                    } else {
                                      log('quran: favorite: Favorite tap on data: ${index} ${favoriteData.favoriteMoshafs} || ${widget.riwayatId} || ${favoriteData.favoriteMoshafs!.surahList.contains(index + 1)}');
                                      return favoriteData.favoriteMoshafs!.surahList.contains(data.suwar[index].id);
                                    }
                                  },
                                ),
                            surahName: data.suwar[index].name,
                            surahNumber: data.suwar[index].id,
                            isSelected: index == selectedIndex,
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                              final moshaf = ref.read(reciteNotifierProvider).maybeWhen(
                                    orElse: () => null,
                                    data: (data) => data.selectedMoshaf,
                                  );
                              log('Selected moshaf: $moshaf');
                              ref.read(quranPlayerNotifierProvider.notifier).initialize(
                                    moshaf: moshaf!,
                                    surah: data.suwar[index],
                                    suwar: data.suwar,
                                  );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuranPlayerScreen(),
                                ),
                              );
                              _scrollToSelectedItem();
                            },
                          );
                        },
                      );
                    },
                    error: (error, stack) {
                      log('Error: $error\n$stack');
                      return Center(
                        child: Text(
                          'Error: $error',
                        ),
                      );
                    },
                    loading: () => _buildShimmerGrid(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleKeyEvent(RawKeyEvent event) {
    final surahs = ref.read(quranNotifierProvider).maybeWhen(orElse: () => [], data: (data) => data.suwar);

    if (event is RawKeyDownEvent) {
      log('Key pressed: ${event.logicalKey}');
      if (event.logicalKey == LogicalKeyboardKey.select) {
        _searchFocusNode.requestFocus();
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          selectedIndex = (selectedIndex + 1) % surahs.length;
        });
        _scrollToSelectedItem();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          selectedIndex = (selectedIndex - 1 + surahs.length) % surahs.length;
        });
        _scrollToSelectedItem();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (selectedIndex < _crossAxisCount) {
          // _searchFocusNode.requestFocus();
        } else {
          setState(() {
            selectedIndex = (selectedIndex - _crossAxisCount + surahs.length) % surahs.length;
          });
          _scrollToSelectedItem();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          selectedIndex = (selectedIndex + _crossAxisCount) % surahs.length;
        });
        _scrollToSelectedItem();
      } else if (event.logicalKey == LogicalKeyboardKey.select) {
        final moshaf = ref.read(quranNotifierProvider).maybeWhen(
              orElse: () => null,
              data: (data) => data.suwar,
            );
        // String reciterServer = '${moshaf!.server}/00$selectedIndex.mp3';
        // AudioSource source = AudioSource.uri(Uri.parse(reciterServer));
      }
    }
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        childAspectRatio: 1.8,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: 20, // Adjust the count as needed
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[700]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  void _scrollToSelectedItem() {
    final surahs = ref.read(quranNotifierProvider).maybeWhen(orElse: () => [], data: (data) => data.suwar);
    final int rowIndex = selectedIndex ~/ _crossAxisCount;
    final double itemHeight = _scrollController.position.maxScrollExtent / ((surahs.length - 1) / _crossAxisCount);
    final double targetOffset = rowIndex * itemHeight;
    _scrollController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }
}
