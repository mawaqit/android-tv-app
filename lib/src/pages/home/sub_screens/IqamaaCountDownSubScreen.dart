import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahTimesBar.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../../../helpers/time_utils.dart';

class IqamaaCountDownSubScreen extends StatelessWidget {
  const IqamaaCountDownSubScreen({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();

    final nextIqamaIndex = mosqueManager.nextIqamaIndex();
    var nextIqamaTime = mosqueManager.actualIqamaTimes()[nextIqamaIndex];

    if (nextIqamaTime.isBefore(mosqueManager.mosqueDate())) {
      nextIqamaTime = nextIqamaTime.add(Duration(days: 1));
    }

    if (mosqueManager.mosqueConfig?.iqamaFullScreenCountdown == false)
      return FutureBuilder(
        future: Future.delayed(nextIqamaTime.difference(mosqueManager.mosqueDate()), onDone),
        builder: (context, snapshot) => NormalHomeSubScreen(),
      );

    return Column(
      children: [
        SizedBox(height: 50),
        Text(
          S.of(context).iqamaIn,
          style: TextStyle(
            fontSize: 70,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: FittedBox(
            alignment: Alignment.center,
            fit: BoxFit.scaleDown,
            child: StreamBuilder(
                stream: Stream.periodic(Duration(seconds: 1)),
                builder: (context, snapshot) {
                  final remaining = nextIqamaTime.difference(mosqueManager.mosqueDate());
                  if (remaining <= Duration.zero) onDone?.call();

                  int seconds = remaining.inSeconds % 60;
                  int minutes = remaining.inMinutes;
                  String _timeTwoDigit = timeTwoDigit(
                    seconds: seconds,
                    minutes: minutes,
                  );
                  return Text(
                    _timeTwoDigit,
                    style: TextStyle(
                      fontSize: 200,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      shadows: kHomeTextShadow,
                    ),
                  );
                }),
          ),
        ),
        SizedBox(height: 50),
        SalahTimesBar(miniStyle: true),
        SizedBox(height: 10),
      ],
    );
  }
}
