import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/FlashAnimation.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_background_screen.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/state_management/prayer_audio/prayer_audio_notifier.dart';
import 'package:mawaqit/src/state_management/prayer_audio/prayer_audio_state.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/recite/quran_audio_player_notifier.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

import '../widgets/mosque_header.dart';
import '../widgets/salah_items/responsive_mini_salah_bar_turkish_widget.dart';

class AdhanSubScreen extends ConsumerStatefulWidget {
  const AdhanSubScreen({Key? key, this.onDone, this.forceAdhan = false}) : super(key: key);

  final VoidCallback? onDone;

  /// used for before fajr alert
  final bool forceAdhan;

  @override
  ConsumerState<AdhanSubScreen> createState() => _AdhanSubScreenState();
}

class _AdhanSubScreenState extends ConsumerState<AdhanSubScreen> {
  Timer? _fallbackTimer;
  Timer? _noAdhanDisplayTimer;
  bool _audioStarted = false;
  bool _closeCalled = false;

  @override
  void initState() {
    super.initState();
    log('AdhanSubScreen: initState');
    _initializeAdhan();
    _startFallbackTimer();
  }

  void _initializeAdhan() {
    log('AdhanSubScreen: _initializeAdhan');
    // Access MosqueManager via provider
    final mosqueManager = context.read<MosqueManager>();
    final mosqueConfig = mosqueManager.mosqueConfig;

    // Stop Quran player if running
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      log('AdhanSubScreen: Stopping quran player if running');
      ref.read(quranPlayerNotifierProvider.notifier).pause();
      ref.read(quranNotifierProvider.notifier).exitQuranMode();
    });

    // Trigger Adhan playback via Riverpod notifier
    if (widget.forceAdhan || mosqueManager.adhanVoiceEnable()) {
      log('AdhanSubScreen: Starting adhan playback');
      _audioStarted = true;

      // Ensure ref is accessed on the next frame after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        try {
          // Use ref.read here as we only need to call the method once
          log('AdhanSubScreen: Calling playAdhan via provider');
          ref.read(prayerAudioProvider.notifier).playAdhan(
                mosqueConfig,
                useFajrAdhan: mosqueManager.salahIndex == 0,
              );
        } catch (e) {
          log('AdhanSubScreen: Error calling playAdhan', error: e);
        }
      });
    } else {
      // No Adhan audio will be played. Start a 150-second timer to close the screen.
      log('AdhanSubScreen: No Adhan audio activated. Starting 150-second display timer.');
      _noAdhanDisplayTimer?.cancel(); // Cancel any existing one
      _noAdhanDisplayTimer = Timer(const Duration(seconds: 150), () {
        log('AdhanSubScreen: 150-second display timer elapsed. Closing screen.');
        _closeScreenSafely();
      });
    }
  }

  void _startFallbackTimer() {
    log('AdhanSubScreen: Starting fallback timer (5 min)');
    _fallbackTimer = Timer(const Duration(minutes: 5), () {
      log('AdhanSubScreen: Fallback timer triggered');
      _closeScreenSafely();
    });
  }

  void _closeScreenSafely() {
    if (_closeCalled) {
      log('AdhanSubScreen: Close already called, ignoring');
      return;
    }

    _closeCalled = true;
    log('AdhanSubScreen: Closing screen safely');

    // Cancel timers/subscriptions
    _cancelTimers();

    if (mounted) {
      log('AdhanSubScreen: Calling onDone callback');
      widget.onDone?.call();
    } else {
      log('AdhanSubScreen: Widget no longer mounted, not calling onDone');
    }
  }

  void _cancelTimers() {
    log('AdhanSubScreen: Cancelling timers');
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    _noAdhanDisplayTimer?.cancel(); // Cancel the no-Adhan display timer as well
    _noAdhanDisplayTimer = null;
  }

  @override
  void dispose() {
    log('AdhanSubScreen: Disposing');

    // Stop audio playback when the screen is disposed prematurely
    if (_audioStarted) {
      log('AdhanSubScreen: Stopping audio in dispose');
      try {
        // Use Future.microtask to avoid calling during build/layout
        Future.microtask(() {
          ref.read(prayerAudioProvider.notifier).stop();
        });
      } catch (e) {
        log('AdhanSubScreen: Error stopping audio in dispose', error: e);
      }
    }

    _cancelTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('AdhanSubScreen: Building UI');

    // Set up audio completion listener
    if (_audioStarted && !_closeCalled) {
      ref.listen<PrayerAudioState>(prayerAudioProvider, (previous, next) {
        // Don't act on the initial state
        if (previous == null) return;

        // Log state transitions for debugging
        log('AdhanSubScreen: Audio state changed - previous: ${previous.processingState}, '
            'next: ${next.processingState}');

        // Detect completion: if the new state is completed
        if (next.processingState == ProcessingState.completed) {
          log('AdhanSubScreen: Playback COMPLETED detected - closing screen');
          _closeScreenSafely();
        }
      });
    }

    // Watch MosqueManager for UI updates
    final mosqueProvider = context.watch<MosqueManager>();
    final mosque = mosqueProvider.mosque!;

    // Debug current audio state
    final audioStateValue = ref.watch(prayerAudioProvider);

    // Log the state in a useful format
    log('AdhanSubScreen: Current audio state - processingState: ${audioStateValue.processingState}, duration: ${audioStateValue.duration}');

    // Build UI
    return MosqueBackgroundScreen(
      child: Column(
        children: [
          Directionality(textDirection: TextDirection.ltr, child: MosqueHeader(mosque: mosque)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.vw),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Icon(MawaqitIcons.icon_adhan, size: 12.vw)
                        .animate()
                        .slideX(begin: -1, delay: .5.seconds)
                        .fadeIn()
                        .addRepaintBoundary(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.vw),
                      child: Text(
                        S.of(context).alAdhan,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.vw,
                          color: Colors.white,
                          shadows: kHomeTextShadow,
                        ),
                      ),
                    ).animate().moveY(begin: -120).fade().addRepaintBoundary(),
                    Icon(MawaqitIcons.icon_adhan, size: 12.vw)
                        .animate()
                        .slideX(begin: 1, delay: .5.seconds)
                        .fadeIn()
                        .addRepaintBoundary(),
                  ],
                ).flashAnimation(),
              ),
            ),
          ),
          mosqueProvider.times!.isTurki
              ? ResponsiveMiniSalahBarTurkishWidget(activeItem: mosqueProvider.salahIndex)
              : ResponsiveMiniSalahBarWidget(activeItem: mosqueProvider.salahIndex),
          SizedBox(height: 2.vh),
        ],
      ),
    );
  }
}
