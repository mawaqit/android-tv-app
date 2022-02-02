import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initialization;

  AdState(this.initialization);

  String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/6300978111';

  AdListener get adListener => _adListener;

  AdListener _adListener = AdListener(
    onAdLoaded: (ad) => print(
      'AdMod_ loaded: ${ad.adUnitId}',
    ),
    onAdClosed: (ad) => print(
      'AdMod_ closed: ${ad.adUnitId}',
    ),
    onAdFailedToLoad: (ad, error) => print(
      'AdMod_ failed to load: ${ad.adUnitId}, $error.',
    ),
    onAdOpened: (ad) => print(
      'AdMod_ opened: ${ad.adUnitId}.',
    ),
    onAppEvent: (ad, name, data) => print(
      'AdMod_ App event : ${ad.adUnitId}, $name, $data.',
    ),
    onApplicationExit: (ad) => print(
      'AdMod_ App Exit: ${ad.adUnitId}',
    ),
    onNativeAdClicked: (nativeAd) => print(
      'AdMod_ Native ad clicked: ${nativeAd.adUnitId}.',
    ),
    onNativeAdImpression: (nativeAd) => print(
      "AdMod_ Native ad impression: ${nativeAd.adUnitId}",
    ),
    onRewardedAdUserEarnedReward: (ad, reward) => print(
      'AdMod_ User rewarded: ${ad.adUnitId}, ${reward.amount} ${reward.type}.',
    ),
  );
}
