import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
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
    final value = DateFormat(
      "a",
      Localizations.localeOf(context).languageCode,
    ).format(dateTime).trim().split('').join('\n');

    final defaultStyle = DefaultTextStyle.of(context).style;

    return Text(
      maxLines: 2,
      value,
      style: (style ?? defaultStyle).apply(
        fontFamily: StringManager.getFontFamilyByString(value),
        fontSizeFactor: isArabic ? .7 : .4,
      ),
    );
  }
}
