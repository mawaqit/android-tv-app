@Deprecated('replace with [HomeActiveWorkflow]')
enum HomeActiveScreen {
  normal,
  adhan,
  afterAdhanHadith,
  iqamaaCountDown,
  iqamaa,
  randomHadith,
  jumuaaHadith,
  jumuaaLiveScreen,
  salahDurationBlackScreen,
  afterSalahAzkar,
  announcementScreen,

  /// todo add other screens
}

///
enum HomeActiveWorkflow {
  /// normal times screen, announcements, random hadith
  normal,

  /// all salah related screens
  /// adhan,after adhan duaa, iqama countdown, iqama, salah screen(not exists yet),after salah duaa
  salah,

  /// workflow made specifically for jumuaa to handle the mosque behaviour of the jumuaa
  jumuaa,
}

enum JumuaaWorkflowScreens {
  /// during the jumuaa hadith
  jumuaaTime,

  /// during the jumuaa salah
  jumuaaSalahTime,

  /// after jumuaa pray
  jumuaaAzkar
}

enum NormalWorkflowScreens { normal, announcement, randomHadith }

enum SalahWorkflowScreens {
  normal,
  adhan,
  afterAdhanDuaa,
  /// this will be shown after the [adhan] and [afterAdhanDuaa] and before the [iqamaaCountDown]
  duaaBetweenAdhanAndIqamaa,
  iqamaaCountDown,
  iqamaa,
  salahTime,
  afterSalahAzkar,
}
