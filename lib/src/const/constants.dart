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

/// [kStorageLimit] limit for the app to work correctly
const double kStorageLimit = 200;

abstract class AudioConstant {
  String adhanLink = "$kStaticFilesUrl/mp3/adhan-afassy.mp3";
  String bipLink = "$kStaticFilesUrl/mp3/bip.mp3";
  String bipAsset = "assets/voices/bip.mp3";
  String duaAfterAdhanAsset = 'assets/voices/duaa-after-adhan.mp3';
  String duaAfterAdhanLink = "$kStaticFilesUrl/mp3/duaa-after-adhan.mp3";
}
