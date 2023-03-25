import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahTimesBar.dart';
import 'package:mawaqit/src/pages/home/widgets/WeatherWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/offline_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../../../helpers/time_utils.dart';

class IqamaaCountDownSubScreen extends StatefulWidget {
  const IqamaaCountDownSubScreen({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  State<IqamaaCountDownSubScreen> createState() =>
      _IqamaaCountDownSubScreenState();
}

class _IqamaaCountDownSubScreenState extends State<IqamaaCountDownSubScreen> {
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    final mosqueManager = context.read<MosqueManager>();
    final nextIqamaa = mosqueManager.nextIqamaaAfter();

    if (nextIqamaa <= Duration.zero || nextIqamaa > Duration(minutes: 30)) {
      Future.delayed(Duration(milliseconds: 80), widget.onDone);
    } else {
      Future.delayed(nextIqamaa, widget.onDone);
    }

    _streamSubscription = Stream.periodic(Duration(seconds: 1)).listen((event) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    final nextIqama = mosqueManager.nextIqamaaAfter();

    final tr = S.of(context);

    if (mosqueManager.mosqueConfig?.iqamaFullScreenCountdown == false)
      return NormalHomeSubScreen();

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
        Text(
          tr.iqamaIn,
          style: TextStyle(
              fontSize: 7.vw,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: kIqamaCountDownTextShadow,
              height: 1,
              fontFamily: StringManager.getFontFamilyByString(tr.iqamaIn)),
        ).animate().slide(delay: .5.seconds).fade().addRepaintBoundary(),
        Expanded(
          child: StreamBuilder(
              stream: Stream.periodic(Duration(seconds: 1)),
              builder: (context, snapshot) {
                final remaining = nextIqama;
                if (remaining <= Duration.zero) {
                  Future.delayed(Duration(milliseconds: 80), widget.onDone);
                }

                int seconds = remaining.inSeconds % 60;
                int minutes = remaining.inMinutes;
                String _timeTwoDigit = timeTwoDigit(
                  seconds: seconds,
                  minutes: minutes,
                );
                return Text(
                  _timeTwoDigit,
                  style: TextStyle(
                    fontSize: 25.vw,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    shadows: kIqamaCountDownTextShadow,
                  ),
                )
                    .animate()
                    .fadeIn(delay: .7.seconds, duration: 2.seconds)
                    .addRepaintBoundary();
              }),
        ),
        SalahTimesBar(miniStyle: true),
        SizedBox(height: 10),
      ],
    );
  }
}
