import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahItem.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahTimesBar.dart';
import 'package:mawaqit/src/pages/home/widgets/ShurukWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/TimeWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_header.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../widgets/footer.dart';

class NormalHomeSubScreen extends StatelessWidget {
  const NormalHomeSubScreen({Key? key}) : super(key: key);

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
              ShurukWidget(),
              HomeTimeWidget(),
              Center(
                child: SalahItemWidget(
                  title: S.of(context).jumua,
                  time: mosqueProvider.times!.jumua ?? "",
                  iqama: mosqueProvider.times!.jumua2,
                  active: mosqueProvider.nextSalahIndex() == 2 &&
                      mosqueProvider.mosqueDate().weekday == DateTime.friday,
                  removeBackground: true,
                ),
              ),
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
