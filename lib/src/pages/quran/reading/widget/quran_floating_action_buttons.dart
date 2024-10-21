import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';

import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';

class QuranFloatingActionButtons extends ConsumerWidget {
  final UserPreferencesManager userPrefs;
  final FocusNode switchScreenViewFocusNode;
  final FocusNode switchQuranModeNode;

  const QuranFloatingActionButtons({
    super.key,
    required this.userPrefs,
    required this.switchScreenViewFocusNode,
    required this.switchQuranModeNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        return isPortrait ? _buildPortraitButtons(context, ref) : _buildLandscapeButtons(context, ref);
      },
    );
  }

  Widget _buildPortraitButtons(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FloatingActionButton(
          heroTag: "switchScreenView",
          focusNode: switchScreenViewFocusNode,
          onPressed: () {
            userPrefs.orientationLandscape = !userPrefs.orientationLandscape;
          },
          child: const Icon(Icons.screen_rotation),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: "switchQuranMode",
          focusNode: switchQuranModeNode,
          onPressed: () {
            ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.listening);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ReciterSelectionScreen.withoutSurahName(),
              ),
            );
          },
          child: const Icon(Icons.menu_book),
        ),
      ],
    );
  }

  Widget _buildLandscapeButtons(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FloatingActionButton(
          heroTag: "switchScreenView",
          focusNode: switchScreenViewFocusNode,
          onPressed: () {
            userPrefs.orientationLandscape = !userPrefs.orientationLandscape;
          },
          child: const Icon(Icons.screen_rotation),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: "switchQuranMode",
          focusNode: switchQuranModeNode,
          onPressed: () {
            ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.listening);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ReciterSelectionScreen.withoutSurahName(),
              ),
            );
          },
          child: const Icon(Icons.menu_book),
        ),
      ],
    );
  }
}
