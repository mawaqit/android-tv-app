import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';
import 'package:mawaqit/src/pages/quran/page/quran_mode_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/page/quran_player_screen.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/page/surah_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/reading/quran_reading_screen.dart';
import 'package:mawaqit/src/pages/quran/widget/favorite_overlay.dart';
import 'package:mawaqit/src/routes/routes_constant.dart';
import 'package:mawaqit/src/pages/SplashScreen.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Special handling for QuranModeSelection
    if (settings.name == Routes.quranModeSelection) {
      return MaterialPageRoute(
        builder: (context) => const QuranModeSelection(),
      );
    }

    // Check if the route is a Quran screen
    if (Routes.quranScreens.contains(settings.name)) {
      return MaterialPageRoute(
        builder: (context) {
          return Consumer(
            builder: (context, ref, child) {
              final quranState = ref.watch(quranNotifierProvider);
              if (quranState.value?.mode == QuranMode.none) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Get the navigator state
                  final navigator = Navigator.of(context);
                  // Pop until we reach the root or can't pop anymore
                  while (navigator.canPop()) {
                    // Pop both dialog and screen if in listening mode
                    if (Routes.quranScreens.contains(settings.name)) {
                      navigator.pop();
                    }
                  }
                });
                return const SizedBox(); // Return empty widget while popping
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

      case Routes.quranReciterFavorite:
        final args = settings.arguments as Map<String, dynamic>;
        return OverlayPage(
          reciter: args['reciter'] as ReciterModel,
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

  // Add this new method for handling the reciter favorite route specifically
  static Route<dynamic> buildReciterFavoriteRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>;
    final reciter = args['reciter'] as ReciterModel;

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => OverlayPage(
        reciter: reciter,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
