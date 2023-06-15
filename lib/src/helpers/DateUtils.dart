import 'package:intl/intl.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';

const _maghrebMonthNames = [
  'جانفي',
  'فيفري',
  'مارس',
  'أفريل',
  'ماي',
  'جوان',
  'جويلية',
  'أوت',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر'
];

const _maghrebMonthsLocales = [
  'AR_TN',
  'AR_DZ',
];

extension MawaqitDateUtils on DateTime {
  String formatIntoMawaqitFormat({String local = 'en'}) {
    var formatter = local == 'ar' || local == 'fr'
        ? DateFormat('EEEE, dd MMMM, yyyy', local)
        : DateFormat('EEEE, MMMM dd, yyyy', local);

    if (_maghrebMonthsLocales.contains(local.toUpperCase())) {
      formatter.dateSymbols.MONTHS = _maghrebMonthNames;
    }

    formatter.useNativeDigits = false;
    return formatter.format(this).capitalizeFirstOfEach();
  }

  ///
  String convertToHijri({
    bool force30Days = false,
    int daysAdjustment = 0,
  }) {
    var formatter = DateFormat('EEEE, dd MMMM, yyyy');
    formatter.useNativeDigits = false;

    return formatter.format(this);
  }
}
