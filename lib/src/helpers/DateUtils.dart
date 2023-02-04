import 'package:intl/intl.dart';

extension MawaqitDateUtils on DateTime {
  String formatIntoMawaqitFormat({
    String local = 'en',
  }) {
    var formatter = local == 'ar' || local == 'fr'
        ? DateFormat('EEEE, dd MMMM, yyyy')
        : DateFormat('EEEE, MMMM dd, yyyy');
    formatter.useNativeDigits = false;
    return formatter.format(this);
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
