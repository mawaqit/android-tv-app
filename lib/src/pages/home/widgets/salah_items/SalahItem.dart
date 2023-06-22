import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:mawaqit/src/widgets/time_widget.dart';
import 'package:provider/provider.dart';

import '../../../../services/mosque_manager.dart';

class SalahItemWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    double titleFont = 3.vw;
    double bigFont = 4.5.vw;
    double smallFont = 3.6.vw;

    final mosqueProvider = context.watch<MosqueManager>();
    final mosqueConfig = mosqueProvider.mosqueConfig;
    // print(isIqamaEnabled);
    final isArabic = context.read<AppLanguage>().isArabic();

    final is12period = mosqueConfig?.timeDisplayFormat == "12";

    return Container(
      width: 16.vw,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.vw),
        color: active
            ? mosqueProvider.getColorTheme().withOpacity(.5)
            : removeBackground
                ? null
                : Colors.black.withOpacity(.5),
      ),
      padding: isArabic
          ? EdgeInsets.only(bottom: 1.vh, right: 1.vw, left: 1.vw)
          : EdgeInsets.symmetric(vertical: 1.6.vh, horizontal: 1.vw),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null && title!.trim().isNotEmpty)
            FittedBox(
              child: Text(
                maxLines: 1,
                title ?? "",
                style: TextStyle(
                  fontSize: titleFont,
                  shadows: kHomeTextShadow,
                  color: Colors.white,
                ),
              ),
            ),
          SizedBox(height: isArabic ? 0.1.vh : 1.vh),
          if (time.trim().isEmpty)
            Icon(Icons.dnd_forwardslash, size: 6.vw)
          else
            FittedBox(
              fit: BoxFit.scaleDown,
              child: TimeWidget.fromString(
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
            ),
          if (iqama != null && showIqama)
            SizedBox(
              height: isArabic ? 1.5.vh : 1.3.vw,
              width: double.infinity,
              child: Divider(
                thickness: 1,
                color: withDivider ? Colors.white : Colors.transparent,
              ),
            ),
          if (iqama != null && showIqama)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: TimeWidget.fromString(
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
            ),
        ],
      ),
    );
  }
}
