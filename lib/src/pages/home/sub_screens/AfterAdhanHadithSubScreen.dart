import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/widgets/display_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

import 'dart:async';
import 'dart:developer';

import '../../../const/constants.dart';
import '../../../services/mosque_manager.dart';
import '../../../state_management/prayer_audio/prayer_audio_notifier.dart';
import '../../../state_management/prayer_audio/prayer_audio_state.dart';
import '../../../themes/UIShadows.dart';

class AfterAdhanSubScreen extends ConsumerStatefulWidget {
  const AfterAdhanSubScreen({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  ConsumerState<AfterAdhanSubScreen> createState() => _AfterAdhanSubScreenState();
}

class _AfterAdhanSubScreenState extends ConsumerState<AfterAdhanSubScreen> {
  final arTranslation = AppLocalizationsAr();
  static const _minimumScreenDuration = Duration(seconds: 20);

  Timer? _completionTimer;
  bool _audioStarted = false;
  bool _audioCompleted = false;
  bool _closeCalled = false;

  @override
  void initState() {
    super.initState();
    log('AfterAdhanSubScreen: initState');
    _initializeScreen();
  }

  /// the main flow of the ui
  Future<void> _initializeScreen() async {
    log('AfterAdhanSubScreen: _initializeScreen');
    if (!mounted) return;

    final mosqueManager = context.read<MosqueManager>();
    final mosqueConfig = mosqueManager.mosqueConfig!;

    if (mosqueConfig.duaAfterAzanEnabled!) {
      if (mosqueManager.adhanVoiceEnable() && !mosqueManager.typeIsMosque) {
        // Mark audio as started to enable listener in build
        _audioStarted = true;

        // Play Dua after a small delay to ensure widget is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          try {
            log('AfterAdhanSubScreen: Triggering playDuaAfterAdhan');
            // Trigger playback
            ref.read(prayerAudioProvider.notifier).playDuaAfterAdhan(mosqueConfig);
          } catch (e) {
            log('AfterAdhanSubScreen: Error triggering dua playback', error: e);
          }
        });

        // Start minimum duration timer immediately
        _startMinimumDurationTimer();
      } else {
        // Fixed delay if Dua enabled but audio conditions not met
        log('AfterAdhanSubScreen: Using fixed delay (adhanVoiceEnable=${mosqueManager.adhanVoiceEnable()}, typeIsMosque=${mosqueManager.typeIsMosque})');
        _startFixedDelayTimer(30.seconds);
      }
    } else {
      // Close immediately if Dua is not enabled
      log('AfterAdhanSubScreen: Closing immediately (duaAfterAzanEnabled=false)');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _closeScreenSafely();
        }
      });
    }
  }

  void _startMinimumDurationTimer() {
    log('AfterAdhanSubScreen: Starting minimum duration timer (${_minimumScreenDuration.inSeconds}s)');
    _completionTimer = Timer(_minimumScreenDuration, () {
      log('AfterAdhanSubScreen: Minimum screen duration elapsed');
      _completionTimer = null; // Mark timer as finished

      // Only close if audio has also completed (or errored)
      if (_audioCompleted) {
        log('AfterAdhanSubScreen: Audio already completed, closing screen');
        _closeScreenSafely();
      } else {
        log('AfterAdhanSubScreen: Audio not yet completed, waiting for completion');
      }
    });
  }

  void _startFixedDelayTimer(Duration delay) {
    log('AfterAdhanSubScreen: Starting fixed delay timer (${delay.inSeconds}s)');
    _completionTimer = Timer(delay, () {
      log('AfterAdhanSubScreen: Fixed delay timer elapsed');
      _completionTimer = null;
      _closeScreenSafely();
    });
  }

  void _closeScreenSafely() {
    if (_closeCalled) {
      log('AfterAdhanSubScreen: Close already called, ignoring');
      return;
    }

    _closeCalled = true;
    log('AfterAdhanSubScreen: Closing screen safely');

    _cancelTimers();

    if (mounted) {
      log('AfterAdhanSubScreen: Calling onDone callback');
      widget.onDone?.call();
    } else {
      log('AfterAdhanSubScreen: Widget no longer mounted, not calling onDone');
    }
  }

  void _cancelTimers() {
    log('AfterAdhanSubScreen: Cancelling timers');
    if (_completionTimer != null) {
      _completionTimer!.cancel();
      _completionTimer = null;
    }
  }

  @override
  void dispose() {
    log('AfterAdhanSubScreen: Disposing');

    // Stop audio playback when the screen is disposed prematurely
    if (_audioStarted) {
      log('AfterAdhanSubScreen: Stopping audio in dispose');
      try {
        // Use Future.microtask to avoid calling during build/layout
        Future.microtask(() {
          ref.read(prayerAudioProvider.notifier).stop();
        });
      } catch (e) {
        log('AfterAdhanSubScreen: Error stopping audio in dispose', error: e);
      }
    }

    _cancelTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('AfterAdhanSubScreen: Building UI');

    // Set up audio completion listener
    if (_audioStarted && !_closeCalled) {
      ref.listen<PrayerAudioState>(prayerAudioProvider, (previous, next) {
        // Don't act on the initial state
        if (previous == null) return;

        // Log state transitions for debugging
        log('AfterAdhanSubScreen: Audio state changed - previous: ${previous.processingState}, '
            'next: ${next.processingState}');

        // Detect completion: if the new state is completed
        if (next.processingState == ProcessingState.completed) {
          log('AfterAdhanSubScreen: Playback COMPLETED detected - closing screen');
          _closeScreenSafely();
        }
      });
    }
    // Debug current audio state
    final audioStateValue = ref.watch(prayerAudioProvider);

    // Log the state in a useful format
    log('AfterAdhanSubScreen: Current audio state - processingState: ${audioStateValue.processingState}, duration: ${audioStateValue.duration}');

    // UI doesn't depend on audio state here, just displays text
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(R.ASSETS_BACKGROUNDS_ISLAMIC_CONTENT_BACKGROUND_WEBP),
          fit: BoxFit.cover,
        ),
      ),
      child: DisplayTextWidget.normal(
        maxHeight: 35,
        title: arTranslation.afterAdhanHadithTitle,
        arabicText: arTranslation.afterSalahHadith,
        translatedTitle: S.of(context).afterAdhanHadithTitle,
        translatedText: S.of(context).afterSalahHadith,
      ),
    );
  }
}
