import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/home/widgets/CurrentTimeWidget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';
import 'package:timeago_flutter/timeago_flutter.dart';

import 'HomeDateWidget.dart';
import 'SalahInWidget.dart';

class HomeTimeWidget extends TimerRefreshWidget {
  const HomeTimeWidget({
    Key? key,
    super.refreshRate = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final isArabicLang = context.read<AppLanguage>().isArabic();

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.25.vw),
        child: Container(
          clipBehavior: Clip.antiAlias,
          width: 40.vw,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.70),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 25.vh,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                    color: mosqueManager.getColorTheme().withOpacity(.7),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 1.5.vw, horizontal: 5.vw),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //clock timer
                      CurrentTimeWidget(),
                      // date time

                      HomeDateWidget(),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(isArabicLang ? 0.1.vw : 2.vh),
                    child: SalahInWidget()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
