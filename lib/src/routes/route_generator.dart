import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';
import 'package:mawaqit/src/pages/quran/page/quran_mode_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/page/quran_player_screen.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/page/surah_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/reading/quran_reading_screen.dart';
import 'package:mawaqit/src/routes/routes_constant.dart';
import 'package:mawaqit/src/pages/SplashScreen.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Check if the route is a Quran screen
    if (Routes.quranScreens.contains(settings.name)) {
      return MaterialPageRoute(
        builder: (context) {
          return Consumer(
            builder: (context, ref, child) {
              final quranState = ref.watch(quranNotifierProvider);
              if (quranState.value?.mode == QuranMode.none) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                });
              }
              return _buildQuranScreen(settings, context);
            },
          );
        },
      );
    }

    // Handle non-Quran routes
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Splash());
      default:
        return _errorRoute();
    }
  }

  static Widget _buildQuranScreen(RouteSettings settings, BuildContext context) {
    switch (settings.name) {
      case Routes.quranModeSelection:
        return const QuranModeSelection();

      case Routes.quranReading:
        return const QuranReadingScreen();

      case Routes.quranReciter:
        return const ReciterSelectionScreen.withoutSurahName();

      case Routes.quranSurah:
        final args = settings.arguments as Map<String, dynamic>;
        return SurahSelectionScreen(
          selectedMoshaf: args['selectedMoshaf'] as MoshafModel,
          reciterId: args['reciterId'] as String,
        );

      case Routes.quranPlayer:
        final args = settings.arguments as Map<String, dynamic>;
        return QuranPlayerScreen(
          reciterId: args['reciterId'] as String,
          selectedMoshaf: args['selectedMoshaf'] as MoshafModel,
          surah: args['surah'] as SurahModel,
        );

      default:
        return const SizedBox();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Route not found')),
      ),
    );
  }
}
