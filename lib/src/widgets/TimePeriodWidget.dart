import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

class TimePeriodWidget extends StatelessWidget {
  const TimePeriodWidget({
    Key? key,
    required this.dateTime,
    this.style,
  }) : super(key: key);

  final DateTime dateTime;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.read<AppLanguage>();
    final isArabic = appLanguage.isArabic();
    final value = DateFormat("a").format(dateTime).trim().split('').join('\n');

    final defaultStyle = TextStyle(
      shadows: kHomeTextShadow,
      height: .9,
      fontSize: 1.2.vw,
      color: Colors.white,
      fontWeight: FontWeight.w300,
    );

    return Text(
      maxLines: 2,
      value,
      style: (style ?? defaultStyle).apply(
        fontSizeFactor: isArabic ? 1.5 : 1,
        fontFamily: StringManager.getFontFamilyByString(value),
      ),
    );
  }
}
