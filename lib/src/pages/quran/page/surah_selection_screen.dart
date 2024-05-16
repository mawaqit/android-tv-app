import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/helpers/DateUtils.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/quran/widget/quran_background.dart';
import 'package:mawaqit/src/pages/quran/widget/surah_card.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:provider/provider.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/pages/quran/widget/side_menu.dart';

import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';
import 'package:shimmer/shimmer.dart';

import 'package:mawaqit/src/state_management/quran/recite/quran_audio_player_notifier.dart';
import 'package:mawaqit/src/pages/quran/page/quran_player_screen.dart';

class SurahSelectionScreen extends ConsumerStatefulWidget {
  const SurahSelectionScreen({
    super.key,
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
    final timeNow = context.select<MosqueManager, DateTime>((value) => value.mosqueDate());
    final mosqueCountryCode = context.select<MosqueManager, String>((value) => value.mosque?.countryCode ?? '');
    final lang = Localizations.localeOf(context).languageCode;
    final georgianDate = timeNow.formatIntoMawaqitFormat(local: '${lang}_$mosqueCountryCode');
    final quranState = ref.watch(quranNotifierProvider);
    return QuranBackground(
      screen: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      georgianDate,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 2.7.vwr,
                        height: .8,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  // Focus(
                  //   debugLabel: 'Search Surahs',
                  //   focusNode: _searchFocusNode,
                  //   child: TextField(
                  //     readOnly: true,
                  //     autofocus: false,
                  //     cursorColor: Colors.white,
                  //     decoration: InputDecoration(
                  //       hintText: 'Search surahs...',
                  //       hintStyle: TextStyle(color: Colors.white70),
                  //       filled: true,
                  //       fillColor: Colors.white.withOpacity(0.2),
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(30),
                  //         borderSide: BorderSide.none,
                  //       ),
                  //       focusedBorder: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(30),
                  //         borderSide: BorderSide(color: Colors.white),
                  //       ),
                  //     ),
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  // ),
                  Expanded(
                    child: quranState.when(
                      data: (data) {
                        return GridView.builder(
                          controller: _scrollController,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _crossAxisCount,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: data.suwar.length,
                          itemBuilder: (context, index) {
                            return SurahCard(
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
          ),
          SideMenu(),
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
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
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
