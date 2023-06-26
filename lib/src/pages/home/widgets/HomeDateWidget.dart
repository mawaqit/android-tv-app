import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mawaqit/src/helpers/DateUtils.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/pages/home/widgets/FadeInOut.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

class HomeDateWidget extends StatelessWidget {
  const HomeDateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final now = mosqueManager.mosqueDate();
    final lang = Localizations.localeOf(context).languageCode;

    var hijriDate = mosqueManager.mosqueHijriDate();
    var hijriDateFormatted = hijriDate.formatMawaqitType();

    final georgianDate = now.formatIntoMawaqitFormat(local: '${lang}_${mosqueManager.mosque?.countryCode}');

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        constraints: BoxConstraints(
          minWidth: 1,
          minHeight: 1,
        ),
        child: FadeInOutWidget(
          duration: Duration(seconds: 10),
          disableSecond: mosqueManager.mosqueConfig!.hijriDateEnabled == false,
          first: Text(
            georgianDate,
            style: TextStyle(
              color: Colors.white,
              fontSize: 2.7.vwr,
              shadows: kHomeTextShadow,
              height: .8,
            ),
          ),
          secondDuration: Duration(seconds: 10),
          second: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                hijriDateFormatted,
                textDirection: hijriDateFormatted.isArabic() ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 2.5.vwr,
                  height: .8,
                  shadows: kHomeTextShadow,
                ),
              ),
              if (hijriDate.isInLunarDays)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: .5.vwr,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.solidMoon,
                    size: 1.8.vwr,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
