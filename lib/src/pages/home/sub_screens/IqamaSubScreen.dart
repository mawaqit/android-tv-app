import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/FlashAnimation.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/state_management/prayer_audio/prayer_audio_notifier.dart';
import 'package:mawaqit/src/state_management/prayer_audio/prayer_audio_state.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

import 'dart:async';
import 'dart:developer';

class IqamaSubScreen extends ConsumerStatefulWidget {
  const IqamaSubScreen({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  ConsumerState<IqamaSubScreen> createState() => _IqamaSubScreenState();
}

class _IqamaSubScreenState extends ConsumerState<IqamaSubScreen> {
  bool _audioStarted = false;

  @override
  void initState() {
    super.initState();
    log('IqamaSubScreen: initState');
    _playIqamaBipIfNeeded();
  }

  void _playIqamaBipIfNeeded() {
    log('IqamaSubScreen: _playIqamaBipIfNeeded');

    // Assume MosqueManager is available via context.read (provider package)
    final mosqueManager = context.read<MosqueManager>();
    final mosqueConfig = mosqueManager.mosqueConfig!;

    if (mosqueConfig.iqamaBip) {
      log('IqamaSubScreen: Will play iqama bip (enabled in config)');
      _audioStarted = true;

      // Trigger playback on the next frame to ensure build completes first
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        try {
          log('IqamaSubScreen: Calling playIqamaBip via provider');
          ref.read(prayerAudioProvider.notifier).playIqamaBip(mosqueManager.mosqueConfig);
        } catch (e) {
          log('IqamaSubScreen: Error calling playIqamaBip', error: e);
        }
      });
    } else {
      log('IqamaSubScreen: Bip not enabled in config, not playing');
    }
  }

  @override
  void dispose() {
    log('IqamaSubScreen: Disposing');

    // Stop any potentially playing bip sound if screen is disposed early
    if (_audioStarted) {
      log('IqamaSubScreen: Stopping audio in dispose');
      try {
        // Use Future.microtask to avoid calling during build/layout
        Future.microtask(() {
          ref.read(prayerAudioProvider.notifier).stop();
        });
      } catch (e) {
        log('IqamaSubScreen: Error stopping audio in dispose', error: e);
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('IqamaSubScreen: Building UI');

    // Set up audio error listener
    ref.listen<PrayerAudioState>(prayerAudioProvider, (previous, next) {
      // Don't act on the initial state
      if (previous == null) return;

      // Log state transitions for debugging
      log('IqamaSubScreen: Audio state changed - previous: ${previous.processingState}, '
          'next: ${next.processingState}');

      // Detect completion: if the new state is completed
      if (next.processingState == ProcessingState.completed) {
        log('IqamaSubScreen: Playback COMPLETED detected - closing screen');
        widget.onDone?.call();
      }
    });

    // Debug current audio state
    final audioStateValue = ref.watch(prayerAudioProvider);

    // Log the state in a useful format
    log('IqamaSubScreen: Current audio state - processingState: ${audioStateValue.processingState}, duration: ${audioStateValue.duration}');

    final theme = Theme.of(context);
    final tr = S.of(context);

    // UI doesn't depend on audio state
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            tr.iqama,
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              shadows: kAfterAdhanTextShadow,
            ),
            textAlign: TextAlign.center,
          ).animate().slide(begin: Offset(0, -1)).fade().addRepaintBoundary(),
        ),
        Expanded(
          child: FlashAnimation(
            child: SvgPicture.asset(
              R.ASSETS_SVG_NO_PHONE_SVG,
              width: 50.vr,
            ),
          ).animate().scale(delay: .2.seconds).addRepaintBoundary(),
        ),
        SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.vw, vertical: 2.vw),
          child: Text(
            tr.turnOfPhones,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 4.vwr,
              color: Colors.white,
              shadows: kAfterAdhanTextShadow,
            ),
          ).animate().slide(begin: Offset(0, 1)).fade().addRepaintBoundary(),
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
