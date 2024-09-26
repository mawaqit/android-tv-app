import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/home/widgets/orientation_widget.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:mawaqit/src/widgets/time_widget.dart';
import 'package:provider/provider.dart';

import '../../../../services/mosque_manager.dart';

class SalahItemWidget extends StatelessOrientationWidget {
  SalahItemWidget({
    Key? key,
    required this.time,
    this.title,
    this.iqama,
    this.active = false,
    this.removeBackground = false,
    this.withDivider = true,
    this.showIqama = true,
    this.isIqamaMoreImportant = false,
  }) : super(key: key);

  final String? title;
  final String time;
  final String? iqama;

  /// show divider only when both time and iqama exists
  final bool withDivider;
  final bool active;
  final bool removeBackground;
  final bool showIqama;

  /// make iqama larger than the time
  final bool isIqamaMoreImportant;

  @override
  Widget buildLandscape(BuildContext context) {
    double titleFont = 3.vwr;
    double bigFont = 4.5.vwr;
    double smallFont = 3.6.vwr;

    final mosqueProvider = context.watch<MosqueManager>();
    final mosqueConfig = mosqueProvider.mosqueConfig;
    // print(isIqamaEnabled);
    final isArabic = context.read<AppLanguage>().isArabic();

    final is12period = mosqueConfig?.timeDisplayFormat == "12";

    return Container(
      margin: EdgeInsets.all(1.vw),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.vw),
        color: active
            ? mosqueProvider.getColorTheme().withOpacity(.5)
            : removeBackground
                ? null
                : Colors.black.withOpacity(.5),
      ),
      padding: EdgeInsets.symmetric(vertical: 1.6.vr, horizontal: 1.vwr),
      child: FittedBox(
        alignment: Alignment.topCenter,
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null && title!.trim().isNotEmpty)
              Text(
                maxLines: 1,
                title ?? "",
                style: TextStyle(
                  fontSize: titleFont,
                  shadows: kHomeTextShadow,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            SizedBox(height: 1.vr),
            if (time.trim().isEmpty)
              Icon(Icons.dnd_forwardslash, size: 6.vwr)
            else
              Container(
                decoration: (iqama != null && showIqama && withDivider)
                    ? BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.white, width: 1)),
                      )
                    : null,
                child: TimeWidget.fromString(
                  show24hFormat: !is12period,
                  time: time,
                  style: TextStyle(
                    fontSize: isIqamaMoreImportant ? smallFont : bigFont,
                    fontWeight: FontWeight.w700,
                    shadows: kHomeTextShadow,
                    color: Colors.white,
                    height: 1,
                    // fontFamily: StringManager.getFontFamily(context),
                  ),
                ),
              ),
            if (iqama != null && showIqama)
              TimeWidget.fromString(
                show24hFormat: !is12period,
                time: iqama!,
                style: TextStyle(
                  fontSize: isIqamaMoreImportant ? bigFont : smallFont,
                  fontWeight: FontWeight.bold,
                  shadows: kHomeTextShadow,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildPortrait(BuildContext context) {
    double titleFont = 3.5.vwr;
    double bigFont = 4.vwr;
    double smallFont = 3.vwr;

    final mosqueProvider = context.watch<MosqueManager>();
    final mosqueConfig = mosqueProvider.mosqueConfig;
    // print(isIqamaEnabled);
    final isArabic = context.read<AppLanguage>().isArabic();

    final is12period = mosqueConfig?.timeDisplayFormat == "12";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.vw),
        color: active
            ? mosqueProvider.getColorTheme().withOpacity(.5)
            : removeBackground
                ? null
                : Colors.black.withOpacity(.5),
      ),
      padding: EdgeInsets.symmetric(vertical: 1.vr, horizontal: 1.vwr),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null && title!.trim().isNotEmpty)
              Text(
                maxLines: 1,
                title ?? "",
                style: TextStyle(
                  fontSize: titleFont,
                  shadows: kHomeTextShadow,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            SizedBox(height: 0.5.vh),
            if (time.trim().isEmpty)
              Icon(Icons.dnd_forwardslash, size: 6.vwr)
            else
              TimeWidget.fromString(
                show24hFormat: !is12period,
                time: time,
                style: TextStyle(
                  fontSize: isIqamaMoreImportant ? smallFont : bigFont,
                  fontWeight: FontWeight.w700,
                  shadows: kHomeTextShadow,
                  color: Colors.white,
                  // fontFamily: StringManager.getFontFamily(context),
                ),
              ),
            if (iqama != null && showIqama)
              SizedBox(
                height: isArabic ? 1.5.vr : 1.3.vwr,
                child: Divider(
                  thickness: 1,
                  color: withDivider ? Colors.white : Colors.transparent,
                ),
              ),
            if (iqama != null && showIqama)
              TimeWidget.fromString(
                show24hFormat: !is12period,
                time: iqama!,
                style: TextStyle(
                  fontSize: isIqamaMoreImportant ? bigFont : smallFont,
                  fontWeight: FontWeight.bold,
                  shadows: kHomeTextShadow,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
