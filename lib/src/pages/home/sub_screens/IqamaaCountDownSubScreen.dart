import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahTimesBar.dart';
import 'package:mawaqit/src/pages/home/widgets/WeatherWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_header.dart';
import 'package:mawaqit/src/pages/home/widgets/offline_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../../../enum/connectivity_status.dart';
import '../../../helpers/time_utils.dart';

class IqamaaCountDownSubScreen extends StatelessWidget {
  const IqamaaCountDownSubScreen({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    final isArabic = context.read<AppLanguage>().isArabic();
    final nextIqamaIndex = mosqueManager.nextIqamaIndex();
    var nextIqamaTime = mosqueManager.actualIqamaTimes()[nextIqamaIndex];
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    bool isOffline = connectionStatus == ConnectivityStatus.Offline;
    final tr = S.of(context);
    if (nextIqamaTime.isBefore(mosqueManager.mosqueDate())) {
      nextIqamaTime = nextIqamaTime.add(Duration(days: 1));
    }

    if (mosqueManager.mosqueConfig?.iqamaFullScreenCountdown == false)
      return FutureBuilder(
        future: Future.delayed(
            nextIqamaTime.difference(mosqueManager.mosqueDate()), onDone),
        builder: (context, snapshot) => NormalHomeSubScreen(),
      );

    return Stack(
      children: [
        Row(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OfflineWidget(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.vw, vertical: 1.vh),
              child: Directionality(
                  textDirection: TextDirection.ltr, child: WeatherWidget()),
            )
          ],
        ),
        Column(
          children: [
            SizedBox(height: isArabic ? 1.vh : 4.vh),
            Text(
              tr.iqamaIn,
              style: TextStyle(
                  fontSize: 7.vw,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: kIqamaCountDownTextShadow,
                  fontFamily: StringManager.getFontFamilyByString(tr.iqamaIn)),
            ).animate().slide(delay: .5.seconds).fade().addRepaintBoundary(),
            Expanded(
              child: StreamBuilder(
                  stream: Stream.periodic(Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    final remaining =
                        nextIqamaTime.difference(mosqueManager.mosqueDate());
                    if (remaining <= Duration.zero) {
                      Future.delayed(Duration(milliseconds: 80), onDone);
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
        ),
      ],
    );
  }
}
