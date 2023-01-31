import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/time_utils.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../../../helpers/StringUtils.dart';
import '../../../services/mosque_manager.dart';
import '../../../widgets/TimePeriodWidget.dart';

const kSalahItemWidgetWidth = 135.0;

class SalahItemWidget extends StatelessWidget {
  SalahItemWidget({
    Key? key,
    required this.time,
    this.title,
    this.iqama,
    this.active = false,
    this.removeBackground = false,
    this.withDivider = true,
  }) : super(key: key);

  final String? title;
  final String time;
  final String? iqama;

  /// show divider only when both time and iqama exists
  final bool withDivider;
  final bool active;
  final bool removeBackground;

  @override
  Widget build(BuildContext context) {
    double bigFont = 4.5.vw;
    double smallFont = 3.6.vw;

    final mosqueProvider = context.watch<MosqueManager>();
    final mosqueConfig = mosqueProvider.mosqueConfig;
    bool? isIqamaEnabled = mosqueConfig?.iqamaEnabled!;
    bool? isIqamaMoreImportant = mosqueConfig!.iqamaMoreImportant! && isIqamaEnabled!;
    final timeDate = time.toTimeOfDay()?.toDate();
    final iqamaDate = iqama?.toTimeOfDay()?.toDate();
    // print(isIqamaEnabled);
    final isArabic = context.read<AppLanguage>().isArabic();

    final is12period = mosqueConfig.timeDisplayFormat == "12";
    final DateFormat dateTimeConverter = is12period ? DateFormat("hh:mm", "en-En") : DateFormat("HH:mm", "en");

    return Container(
      width: 16.vw,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.vw),
        color: active
            ? mosqueProvider.getColorTheme().withOpacity(.7)
            : removeBackground
            ? null
            : Colors.black.withOpacity(.70),
      ),
      padding: isArabic
          ? EdgeInsets.only(bottom: 1.vh, right: 1.vw, left: 1.vw)
          : EdgeInsets.symmetric(vertical: 1.6.vh, horizontal: 1.vw),
      child: Directionality(
        textDirection: isArabic?TextDirection.rtl:TextDirection.ltr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              FittedBox(
                child: Text(
                  maxLines: 1,
                  title!,
                  style: TextStyle(
                      fontSize: 3.vw,
                      shadows: kHomeTextShadow,
                      color: Colors.white,
                      fontFamily: StringManager.getFontFamily(context)),
                ),
              ),
            SizedBox(height: isArabic ? 0.1.vh : 1.vh),
            if (time.trim().isEmpty) Icon(Icons.dnd_forwardslash, size: 6.vw),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      timeDate == null ? time : dateTimeConverter.format(timeDate),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: isIqamaMoreImportant ? smallFont : bigFont,
                        fontWeight: FontWeight.w700,
                        shadows: kHomeTextShadow,
                        color: Colors.white,
                        // fontFamily: StringManager.getFontFamily(context),
                      ),
                    ),
                  ),
                ),
                if (timeDate != null && is12period)
                  SizedBox(
                    // width: 2.vw,
                    child: TimePeriodWidget(
                      dateTime: timeDate,
                      style: TextStyle(
                        height: .9,
                        letterSpacing: 9,
                        fontSize: 1.6.vw,
                        fontWeight: FontWeight.w300,
                        shadows: kIqamaCountDownTextShadow,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            if (iqama != null && isIqamaEnabled!)
              SizedBox(
                height: isArabic ? 1.5.vh : 1.3.vw,
                width: double.infinity,
                child: Divider(
                  thickness: 1,
                  color: withDivider ? Colors.white : Colors.transparent,
                ),
              ),
            if (iqama != null && isIqamaEnabled!)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    iqamaDate == null ? iqama! : dateTimeConverter.format(iqamaDate),
                    // '$iqama${iqama!.startsWith('+') ? "\'" : ""}',
                    style: TextStyle(
                      fontSize: isIqamaMoreImportant ? bigFont : smallFont,
                      fontWeight: FontWeight.bold,
                      shadows: kHomeTextShadow,
                      letterSpacing: 1,
                      color: Colors.white,

                      // fontFamily: StringManager.getFontFamily(context)
                    ),
                  ),
                  if (iqamaDate != null && is12period)
                    SizedBox(
                      width: 1.vw,
                      child: TimePeriodWidget(
                        dateTime: iqamaDate,
                        style: TextStyle(
                          height: .9,
                          letterSpacing: 9,
                          fontSize: 1.4.vw,
                          fontWeight: FontWeight.w300,
                          shadows: kIqamaCountDownTextShadow,
                          // fontFamily: StringManager.getFontFamily(context),
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
