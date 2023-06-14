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
  /// show the normal screen 5 minutes before the jumuaa time
  /// without any interruption from [announcements, random hadith]
  normal,

  /// during the jumuaa hadith
  jumuaaTime,

  /// during the jumuaa salah
  jumuaaSalahTime,

  /// after jumuaa pray
  jumuaaAzkar
}
