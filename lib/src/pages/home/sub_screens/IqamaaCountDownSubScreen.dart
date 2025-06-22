import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/pages/home/widgets/WeatherWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/offline_widget.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../../../helpers/time_utils.dart';
import '../widgets/salah_items/responsive_mini_salah_bar_turkish_widget.dart';

class IqamaaCountDownSubScreen extends StatefulWidget {
  const IqamaaCountDownSubScreen({
    Key? key,
    this.onDone,
    this.isDebug = false,
    this.currentSalahIndex = 0,
  }) : super(key: key);
  final bool isDebug;
  final int currentSalahIndex;
  final VoidCallback? onDone;

  @override
  State<IqamaaCountDownSubScreen> createState() => _IqamaaCountDownSubScreenState();
}

class _IqamaaCountDownSubScreenState extends State<IqamaaCountDownSubScreen> {
  /// The remaining time for the countdown, used for both debug and normal modes
  Duration _remainingTime = Duration.zero;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    final mosqueManager = context.read<MosqueManager>();

    if (widget.isDebug) {
      // In debug mode, start with a fixed 5 minute countdown
      _remainingTime = Duration(minutes: 5);
      _startCountdown();
    } else {
      // In normal mode, calculate the time remaining until iqama
      var currentSalahTime = mosqueManager.actualTimes()[widget.currentSalahIndex];
      var currentIqamaTime = mosqueManager.actualIqamaTimes()[widget.currentSalahIndex];
      final now = mosqueManager.mosqueDate();

    /// if the iqama is comming the next day then add one day to the iqama time
    if (currentIqamaTime.isBefore(currentSalahTime)) currentIqamaTime = currentIqamaTime.add(Duration(days: 1));

      _remainingTime = currentIqamaTime.difference(now);

      // Schedule the onDone callback to be called when countdown finishes
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Future.delayed(_remainingTime, widget.onDone);
      });
    }
  }

  /// Start the countdown timer
  void _startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - Duration(seconds: 1);
        } else {
          _countdownTimer?.cancel();
          widget.onDone?.call();
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();

    final tr = S.of(context);

    if (mosqueManager.mosqueConfig?.iqamaFullScreenCountdown == false) return NormalHomeSubScreen();

    return Column(
      children: [
        Row(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OfflineWidget(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.vw, vertical: 1.vh),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: WeatherWidget(),
              ),
            )
          ],
        ),
        Spacer(),
        Text(
          tr.iqamaIn,
          style: TextStyle(
            fontSize: 7.vwr,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: kIqamaCountDownTextShadow,
            height: 1,
          ),
        ).animate().slide(delay: .5.seconds).fade().addRepaintBoundary(),
        SizedBox(height: 1.vh),
        StreamBuilder(
            stream: Stream.periodic(Duration(seconds: 1)),
            builder: (context, snapshot) {
              // For normal mode, we need to update the remaining time on each tick
              if (!widget.isDebug) {
                _remainingTime = mosqueManager.nextIqamaaAfter();
                if (_remainingTime <= Duration.zero) {
                  Future.delayed(Duration(milliseconds: 80), widget.onDone);
                }
              }

              // Format the remaining time into a string
              final minutes = _remainingTime.inMinutes;
              final seconds = _remainingTime.inSeconds % 60;
              final formattedTime = timeTwoDigit(
                seconds: seconds,
                minutes: minutes,
              );

              return Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 25.vw,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  shadows: kIqamaCountDownTextShadow,
                ),
              ).animate().fadeIn(delay: .7.seconds, duration: 2.seconds).addRepaintBoundary();
            }),
        Spacer(),
        mosqueManager.times!.isTurki ? ResponsiveMiniSalahBarTurkishWidget() : ResponsiveMiniSalahBarWidget(),
        SizedBox(height: 1.vh),
      ],
    );
  }
}
