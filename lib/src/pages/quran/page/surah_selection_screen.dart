import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/helpers/DateUtils.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/widget/surah_card.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:provider/provider.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/pages/quran/widget/side_menu.dart';

class SurahSelectionScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState createState() => _SurahSelectionScreenState();
}

class _SurahSelectionScreenState extends ConsumerState<SurahSelectionScreen> {
  int selectedIndex = 0;
  final int _crossAxisCount = 4;
  final ScrollController _scrollController = ScrollController();
  late FocusNode _searchFocusNode;

  @override
  Widget build(BuildContext context) {
    final timeNow = context.select<MosqueManager, DateTime>((value) => value.mosqueDate());
    final mosqueCountryCode = context.select<MosqueManager, String>((value) => value.mosque?.countryCode ?? '');
    final lang = Localizations.localeOf(context).languageCode;
    final georgianDate = timeNow.formatIntoMawaqitFormat(local: '${lang}_$mosqueCountryCode');
    final quranState = ref.watch(quranNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF181C3F), Color(0xFF490094)],
            stops: [0.0, 1.0],
            transform: GradientRotation(170.31 * 3.14159 / 180),
          ),
        ),
        child: Row(
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
                    Focus(
                      debugLabel: 'Search Surahs',
                      focusNode: _searchFocusNode,
                      child: TextField(
                        readOnly: true,
                        autofocus: false,
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: 'Search surahs...',
                          hintStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 16),
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
                                surahNumber: index + 1,
                                isSelected: index == selectedIndex,
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
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
                        loading: () => Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SideMenu(),
          ],
        ),
      ),
    );
  }

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

      }
    }
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
