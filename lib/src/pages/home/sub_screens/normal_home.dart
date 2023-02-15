import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundires.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahItem.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahTimesBar.dart';
import 'package:mawaqit/src/pages/home/widgets/ShurukWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/TimeWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_header.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../widgets/footer.dart';

class NormalHomeSubScreen extends StatelessWidget {
  NormalHomeSubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.read<MosqueManager>();
    final mosque = mosqueProvider.mosque!;
    final mosqueConfig = mosqueProvider.mosqueConfig;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosqueHeader(mosque: mosque),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.vw).copyWith(top: 1.5.vw),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShurukWidget().animate().slideX().fadeIn().addRepaintBoundary(),
              HomeTimeWidget()
                  .animate()
                  .slideY(delay: Duration(milliseconds: 500))
                  .fadeIn().addRepaintBoundary(),
              SalahItemWidget(
                title: S.of(context).jumua,
                time: mosqueProvider.jumuaTime ?? "",
                iqama: mosqueProvider.times!.jumua2,
                active: mosqueProvider.nextIqamaIndex() == 1 &&
                    mosqueProvider.mosqueDate().weekday == DateTime.friday,
                removeBackground: true,
              ).animate().slideX(begin: 1).fadeIn().addRepaintBoundary(),
            ],
          ),
        ),
        Spacer(),
        SalahTimesBar(),
        Spacer(),
        mosqueConfig!.footer == true ? Footer() : SizedBox(height: 2.vw),
      ],
    );
  }
}
