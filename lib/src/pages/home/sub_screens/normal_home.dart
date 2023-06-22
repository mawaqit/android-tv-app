import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/FlashWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/ShurukWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/TimeWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_header.dart';
import 'package:mawaqit/src/pages/home/widgets/orientation_widget.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/SalahItem.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_salah_bar_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../widgets/footer.dart';

/// prayer times screen
/// the main home screen on the app
class NormalHomeSubScreen extends StatelessOrientationWidget {
  NormalHomeSubScreen({Key? key}) : super(key: key);

  @override
  Widget buildLandscape(BuildContext context) {
    final mosqueProvider = context.read<MosqueManager>();
    final mosque = mosqueProvider.mosque!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Directionality(textDirection: TextDirection.ltr, child: MosqueHeader(mosque: mosque)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.vw).copyWith(top: 1.5.vw),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShurukWidget().animate().slideX().fadeIn().addRepaintBoundary(),
              HomeTimeWidget().animate().slideY(delay: Duration(milliseconds: 500)).fadeIn().addRepaintBoundary(),
              SalahItemWidget(
                title: S.of(context).jumua,
                time: mosqueProvider.jumuaTime ?? "",
                iqama: mosqueProvider.times!.jumua2,
                active: mosqueProvider.nextIqamaIndex() == 1 && mosqueProvider.mosqueDate().weekday == DateTime.friday,
                removeBackground: true,
              ).animate().slideX(begin: 1).fadeIn().addRepaintBoundary(),
            ],
          ),
        ),
        ResponsiveSalahBarWidget(),
        Footer(),
      ],
    );
  }

  @override
  Widget buildPortrait(BuildContext context) {
    final mosqueProvider = context.read<MosqueManager>();
    final mosque = mosqueProvider.mosque!;

    return Column(
      children: [
        Directionality(textDirection: TextDirection.ltr, child: MosqueHeader(mosque: mosque)),
        Spacer(flex: 2),
        HomeTimeWidget().animate().slideY(delay: Duration(milliseconds: 500)).fadeIn().addRepaintBoundary(),
        Column(
          children: [
            ResponsiveSalahBarWidget(),
            SizedBox(height: 2.vwr),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShurukWidget().animate().slideX().fadeIn().addRepaintBoundary(),
                SalahItemWidget(
                  title: S.of(context).jumua,
                  time: mosqueProvider.jumuaTime ?? "",
                  iqama: mosqueProvider.times!.jumua2,
                  active:
                      mosqueProvider.nextIqamaIndex() == 1 && mosqueProvider.mosqueDate().weekday == DateTime.friday,
                  removeBackground: true,
                ).animate().slideX(begin: 1).fadeIn().addRepaintBoundary(),
              ],
            ),
          ],
        ),
        Spacer(),
        Column(
          children: [
            if (mosque.flash != null)
              Container(
                color: Colors.black26,
                height: 5.vh,
                child: FlashWidget(),
              ),
            Footer(hideMessage: true),
          ],
        ),
      ],
    );
  }
}
