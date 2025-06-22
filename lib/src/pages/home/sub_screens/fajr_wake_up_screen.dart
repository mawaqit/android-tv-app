import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/FlashAnimation.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_background_screen.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_header.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/state_management/prayer_audio/prayer_audio_notifier.dart';
import 'package:mawaqit/src/state_management/prayer_audio/prayer_audio_state.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

import 'dart:async';
import 'dart:developer';

import '../widgets/salah_items/responsive_mini_salah_bar_turkish_widget.dart';

class FajrWakeUpSubScreen extends ConsumerStatefulWidget {
  const FajrWakeUpSubScreen({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  ConsumerState<FajrWakeUpSubScreen> createState() => _FajrWakeUpSubScreenState();
}

class _FajrWakeUpSubScreenState extends ConsumerState<FajrWakeUpSubScreen> {
  Timer? _fallbackTimer;
  bool _audioStarted = false;
  bool _closeCalled = false;

  @override
  void initState() {
    super.initState();
    log('FajrWakeUpSubScreen: initState');
    _playFajrAdhan();
    _startFallbackTimer();
  }

  void _playFajrAdhan() {
    log('FajrWakeUpSubScreen: _playFajrAdhan');
    final mosqueManager = context.read<MosqueManager>();

    // Mark audio as started to enable the listener
    _audioStarted = true;

    // Trigger playback on the next frame to ensure build completes first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        log('FajrWakeUpSubScreen: Calling playAdhan via provider');
        // Trigger playback via Riverpod notifier
        ref.read(prayerAudioProvider.notifier).playAdhan(
              mosqueManager.mosqueConfig!,
              useFajrAdhan: true, // Always true for this screen
            );
      } catch (e) {
        log('FajrWakeUpSubScreen: Error calling playAdhan', error: e);
      }
    });
  }

  void _startFallbackTimer() {
    log('FajrWakeUpSubScreen: Starting fallback timer (5 min)');
    _fallbackTimer = Timer(const Duration(minutes: 5), () {
      log('FajrWakeUpSubScreen: Fallback timer triggered');
      _closeScreenSafely();
    });
  }

  void _closeScreenSafely() {
    if (_closeCalled) {
      log('FajrWakeUpSubScreen: Close already called, ignoring');
      return;
    }

    _closeCalled = true;
    log('FajrWakeUpSubScreen: Closing screen safely');

    // Cancel timers
    _cancelTimers();

    if (mounted) {
      log('FajrWakeUpSubScreen: Calling onDone callback');
      widget.onDone?.call();
    } else {
      log('FajrWakeUpSubScreen: Widget no longer mounted, not calling onDone');
    }
  }

  void _cancelTimers() {
    log('FajrWakeUpSubScreen: Cancelling timers');
    if (_fallbackTimer != null) {
      _fallbackTimer!.cancel();
      _fallbackTimer = null;
    }
  }

  @override
  void dispose() {
    log('FajrWakeUpSubScreen: Disposing');

    // Stop audio playback when the screen is disposed prematurely
    if (_audioStarted) {
      log('FajrWakeUpSubScreen: Stopping audio in dispose');
      try {
        // Use Future.microtask to avoid calling during build/layout
        Future.microtask(() {
          ref.read(prayerAudioProvider.notifier).stop();
        });
      } catch (e) {
        log('FajrWakeUpSubScreen: Error stopping audio in dispose', error: e);
      }
    }

    _cancelTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('FajrWakeUpSubScreen: Building UI');

    // Set up audio completion listener
    if (_audioStarted && !_closeCalled) {
      ref.listen<PrayerAudioState>(prayerAudioProvider, (previous, next) {
        // Don't act on the initial state
        if (previous == null) return;

        // Log state transitions for debugging
        log('FajrWakeUpSubScreen: Audio state changed - previous: ${previous.processingState}, '
            'next: ${next.processingState}');

        // Detect completion: if the new state is completed
        if (next.processingState == ProcessingState.completed) {
          log('FajrWakeUpSubScreen: Playback COMPLETED detected - closing screen');
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
    log('FajrWakeUpSubScreen: Current audio state - processingState: ${audioStateValue.processingState}, duration: ${audioStateValue.duration}');

    // Build UI
    return MosqueBackgroundScreen(
      child: Column(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: MosqueHeader(mosque: mosque),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.vw),
              child: FlashAnimation(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      MawaqitIcons.icon_adhan,
                      size: 12.vw,
                      shadows: kHomeTextShadow,
                      color: Colors.white,
                    ).animate().slideX(begin: -2).addRepaintBoundary(),
                    Flexible(
                      fit: FlexFit.loose,
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.vw),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isHeightConstrained = constraints.maxHeight < 300;

                            double fontSize =
                                isHeightConstrained ? constraints.maxWidth * 0.07 : constraints.maxWidth * 0.12;

                            int maxLines = isHeightConstrained ? 1 : 2;

                            return Center(
                              child: Text(
                                S.of(context).salatKhayrMinaNawm,
                                maxLines: maxLines,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                  height: isHeightConstrained ? 1.0 : 1.3,
                                  color: Colors.white,
                                  shadows: kHomeTextShadow,
                                ),
                                softWrap: true,
                                overflow: isHeightConstrained ? TextOverflow.ellipsis : TextOverflow.visible,
                              ).animate().slideY(begin: -1, delay: .5.seconds).fadeIn().addRepaintBoundary(),
                            );
                          },
                        ),
                      ),
                    ),
                    Icon(
                      MawaqitIcons.icon_adhan,
                      size: 12.vw,
                      shadows: kHomeTextShadow,
                      color: Colors.white,
                    ).animate().slideX(begin: 2).addRepaintBoundary(),
                  ],
                ),
              ),
            ),
          ),
          mosqueProvider.times!.isTurki ? ResponsiveMiniSalahBarTurkishWidget() : ResponsiveMiniSalahBarWidget()
        ],
      ),
    );
  }
}
