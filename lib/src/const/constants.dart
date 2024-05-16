/// this file will has all the constant values of the app

const kAppName = 'MAWAQIT for TV';
const kAppId = 'com.mawaqit.androidtv';

const kDeviceInfo = 'device_info';

const kBaseUrl = 'https://mawaqit.net/api';
const kStagingUrl = 'https://staging.mawaqit.net/api';
const kStaticFilesUrl = 'https://mawaqit.net/static';
const kStagingStaticFilesUrl = 'https://staging.mawaqit.net/static';

const kApiToken = String.fromEnvironment('mawaqit.api.key');
const kSentryDns = String.fromEnvironment('mawaqit.sentry.dns');

const kGooglePlayId = 'com.mawaqit.androidtv';

class CacheKey {
  static const String kMosqueBackgroundScreen = 'mosque_background_screen';
  static const String kLastPopupDisplay = 'last_popup_display';
  static const String kAutoUpdateChecking = 'auto_update_checking';
  static const String kIsUpdateDismissed = 'is_update_dismissed';
  static const String kUpdateDismissedVersion = 'update_dismissed_version';
}

abstract class RandomHadithConstant {
  static const String kLastHadithXMLFetchDate = "last_hadith_xml_fetch_date";
  static const String kBoxName = "random_hadith_list";
  static const String kHadithLanguage = "hadith_language";
  static const String kLastHadithXMLFetchLanguage = "last_hadith_xml_language";
}

class TurnOnOffTvConstant {
  static const String kLastEventDate = "lastEventDate";
  static const String kIsEventsSet = "isEventsSet";
  static const String kActivateToggleFeature = "activateToggleFeature";
  static const String kScheduledTimersKey = "scheduledTimers";

  /// native methods calls
  static const String kNativeMethodsChannel = "nativeMethodsChannel";
  static const String kCheckRoot = "checkRoot";
  static const String kToggleBoxScreenOff = "toggleBoxScreenOff";
  static const String kToggleBoxScreenOn = "toggleBoxScreenOn";

  static const String kMinuteBeforeKey = 'selectedMinuteBefore';
  static const String kMinuteAfterKey = 'selectedMinuteAfter';
}

abstract class AnnouncementConstant {
  static const String kBoxName = "announcement";
}

abstract class MosqueManagerConstant {
  static const String kMosqueUUID = "mosqueUUID";
}

abstract class QuranConstant {
  static const String kQuranVersionLink = "'https://mawaqit.github.io/mawaqit-announcements/public/quran/config.json'";
  static const String kQuranLocalVersion = 'quran_local_version';
  static const String kQuranBaseUrl = 'https://mp3quran.net/api/v3/';
  static const String kSurahBox = 'surah_box';
  static const String kReciterBox = 'reciter_box';
}
