import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/quran/page/reading_screen.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/widget/quran_background.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';
import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';
import 'package:sizer/sizer.dart';

import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';

class QuranModeSelection extends ConsumerStatefulWidget {
  const QuranModeSelection({super.key});

  @override
  ConsumerState createState() => _QuranModeSelectionState();
}

class _QuranModeSelectionState extends ConsumerState<QuranModeSelection> {
  int _selectedIndex = 0;
  late FocusNode _readingFocusNode;
  late FocusNode _listeningFocusNode;

  @override
  void initState() {
    super.initState();
    _readingFocusNode = FocusNode();
    _listeningFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _readingFocusNode.dispose();
    _listeningFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          _selectedIndex = 0;
        });
        _readingFocusNode.requestFocus();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          _selectedIndex = 1;
        });
        _listeningFocusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _handleKeyEvent,
      child: QuranBackground(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        screen: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Text(
              S.of(context).selectMode,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModeButton(
                  context: context,
                  text: S.of(context).readingMode,
                  icon: Icons.book,
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                    ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.reading);
                    log('Reading mode selected');
                    /// it navigates already by the menu at
                  },
                  isSelected: _selectedIndex == 0,
                  focusNode: _readingFocusNode,
                ),
                _buildModeButton(
                  context: context,
                  text: S.of(context).listeningMode,
                  icon: Icons.headset,
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                    ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.listening);
                    // Navigate to the listening mode screen
                    /// it navigates already by the menu at
                  },
                  isSelected: _selectedIndex == 1,
                  focusNode: _listeningFocusNode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isSelected,
    required FocusNode focusNode,
  }) {
    return Focus(
      focusNode: focusNode,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 50.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isNavigating = false;

  void _navigateToReadingScreen(BuildContext context) {
    if (_isNavigating) return;
    _isNavigating = true;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReadingScreen()),
    ).then((_) {
      _isNavigating = false;
    });
  }
}
