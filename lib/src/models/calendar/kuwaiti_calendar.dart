class KuwaitiCalendar {
  late final int day;
  late final int month;
  late final int year;
  late final int julianDay;
  late final int weekDay;
  late final int islamicDate;
  late final int islamicMonth;
  late final int islamicYear;

  KuwaitiCalendar({
    required this.day,
    required this.month,
    required this.year,
    required this.julianDay,
    required this.weekDay,
    required this.islamicDate,
    required this.islamicMonth,
    required this.islamicYear,
  });

  /// Returns a KuwaitiCalendar based on the date and the adjust time
  ///
  /// `today` [DateTime] from which the KuwaitiCalendar will be generated
  /// `dayShift` [int] the shifted day of the date
  KuwaitiCalendar.generate(DateTime today, int dayShift, bool force30) {
    if (dayShift > 0) {
      today = today.add(
        Duration(days: dayShift),
      );
    } else if (dayShift < 0) {
      today = today.subtract(
        Duration(days: -dayShift),
      );
    }

    int day = today.day;
    int month = today.month;
    int year = today.year;

    int m = month++;
    int y = year;

    if (m < 3) {
      y--;
      m += 12;
    }

    int a = (y / 100).floor();
    int b = 2 - a + (a / 4).floor();

    if (y < 1583) b = 0;

    if (y == 1582) {
      if (m > 10) b = -10;
      if (m == 10) {
        b = 0;
        if (day > 4) b = -10;
      }
    }

    int jd = (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + day + b - 1524;

    b = 0;
    if (jd > 2299160) {
      a = ((jd - 1867216.25) / 36524.25).floor();
      b = 1 + a - (a / 4).floor();
    }

    int bb = jd + b + 1524;
    int cc = ((bb - 122.1) / 365.25).floor();
    int dd = (365.25 * cc).floor();
    int ee = ((bb - dd) / 30.6001).floor();
    day = (bb - dd) - (30.6001 * ee).floor();
    month = ee - 1;

    if (ee > 13) {
      cc += 1;
      month = ee - 13;
    }
    year = cc - 4716;

    int wd = dayShift != 0 ? gmod(jd + 1 - dayShift, 7) + 1 : gmod(jd + 1, 7) + 1;

    double iyear = 10631 / 30;
    int epochastro = 1948084;
    // int epochcivil = 1948085; useless ?

    double shift1 = 8.01 / 60;

    int z = jd - epochastro;
    int cyc = (z / 10631).floor();
    z = z - 10631 * cyc;
    int j = ((z - shift1) / iyear).floor();
    int iy = 30 * cyc + j;
    z = z - (j * iyear + shift1).floor();
    int im = ((z + 28.5001) / 29.5).floor();
    if (im == 13) im = 12;
    int id = z - (29.5001 * im - 29).floor();

    this.day = day;
    this.month = month - 1;
    this.year = year;
    this.julianDay = jd - 1;
    this.weekDay = wd - 1;
    this.islamicDate = force30 ? 30 : id;
    this.islamicMonth = im - 1;
    this.islamicYear = iy;
  }

  /// Basic Constructor
  KuwaitiCalendar.fromCalendar(KuwaitiCalendar calendar)
      : this(
          day: calendar.day,
          month: calendar.month,
          year: calendar.year,
          julianDay: calendar.julianDay,
          weekDay: calendar.weekDay,
          islamicDate: calendar.islamicYear,
          islamicMonth: calendar.islamicMonth,
          islamicYear: calendar.islamicYear,
        );

  /// Generator for using the actual system [DateTime.now()]
  ///
  /// optional `dayShift` [int] the shifted day of the date
  KuwaitiCalendar.fromNow({
    int dayShift = 0,
    bool force30 = false,
  }) : this.generate(DateTime.now(), dayShift, force30);

  /// Generator for using another DateTime
  ///
  /// `today` [DateTime] from which the KuwaitiCalendar will be generated
  /// optional `dayShift` [int] the shifted day of the date
  KuwaitiCalendar.fromDatetime(
    DateTime dateTime, {
    int dayShift = 0,
    bool force30 = false,
  }) : this.generate(dateTime, dayShift, force30);

  /// gmod implementation from https://www.al-habib.info/islamic-calendar/hijricalendartext.htm
  static int gmod(int n, int m) {
    return ((n % m) + m) % m;
  }
}
