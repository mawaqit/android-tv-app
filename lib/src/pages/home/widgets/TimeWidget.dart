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
    this.showSalahIn = true,
    this.showOuterBackground = false,
    super.refreshRate = const Duration(seconds: 1),
  }) : super(key: key);

  final bool showSalahIn;
  final bool showOuterBackground;

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final isArabicLang = context.read<AppLanguage>().isArabic();

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.vwr),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  color: Color.lerp(Colors.black, mosqueManager.getColorTheme(), 0.9)!.withOpacity(.7),
                  backgroundBlendMode: BlendMode.screen,
                ),
                padding: EdgeInsets.symmetric(vertical: showOuterBackground ? 4.47.vw : 2.5.vw, horizontal: 5.vw),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //clock timer
                    CurrentTimeWidget(),

                    // date time
                    HomeDateWidget(),
                  ],
                ),
              ),
              if (showSalahIn) Padding(padding: EdgeInsets.all(1.vwr), child: Center(child: SalahInWidget())),
            ],
          ),
        ),
      ),
    );
  }
}
