import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/quran/reading/quran_reading_screen.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/widget/quran_background.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';
import 'package:sizer/sizer.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/routes/routes_constant.dart';

class QuranModeSelection extends ConsumerStatefulWidget {
  const QuranModeSelection({super.key});

  @override
  ConsumerState createState() => _QuranModeSelectionState();
}

class _QuranModeSelectionState extends ConsumerState<QuranModeSelection> {
  int _selectedIndex = 0;
  late FocusNode _readingFocusNode;
  late FocusNode _listeningFocusNode;
  late FocusNode _mainFocusNode;

  @override
  void initState() {
    super.initState();
    _readingFocusNode = FocusNode();
    _listeningFocusNode = FocusNode();
    _mainFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _readingFocusNode.dispose();
    _listeningFocusNode.dispose();
    _mainFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleKeyEvent(RawKeyEvent event) async {
    if (event is RawKeyDownEvent) {
      final isLtr = Directionality.of(context) == TextDirection.ltr;

      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          _selectedIndex = isLtr ? 0 : 1;
        });
        if (isLtr) {
          _readingFocusNode.requestFocus();
        } else {
          _listeningFocusNode.requestFocus();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          _selectedIndex = isLtr ? 1 : 0;
        });
        if (isLtr) {
          _listeningFocusNode.requestFocus();
        } else {
          _readingFocusNode.requestFocus();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.select) {
        if (_selectedIndex == 0) {
          await ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.reading);
          if(mounted){
            Navigator.pushReplacementNamed(context, Routes.quranReading);
          }
        } else {
          await ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.listening);
          if(mounted) {
            Navigator.pushReplacementNamed(context, Routes.quranReciter);
          }
        }
      }
    }
  }

  void _handleNavigation(int index) {
    if (index == 0) {
      ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.reading);
      Navigator.pushReplacementNamed(context, Routes.quranReading);
    } else {
      ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.listening);
      Navigator.pushReplacementNamed(context, Routes.quranReciter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _mainFocusNode,
      onKey: _handleKeyEvent,
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: QuranBackground(
          screen: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                alignment: AlignmentDirectional.centerStart,
                child: ExcludeFocus(
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildModeButton(
                    context: context,
                    text: S.of(context).readingMode,
                    icon: Icons.menu_book,
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                      _handleNavigation(0);
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
                      _handleNavigation(1);
                    },
                    isSelected: _selectedIndex == 1,
                    focusNode: _listeningFocusNode,
                  ),
                ],
              ),
            ],
          ),
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
        onTap: () => _handleNavigation(isSelected ? 0 : 1),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 50.w,
          padding: EdgeInsets.all(16),
          height: 20.h,
          decoration: ShapeDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isSelected ? 90 : 80,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  text,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSelected ? 18.sp : 16.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
