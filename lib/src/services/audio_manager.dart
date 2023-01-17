import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';

class AudioManager extends ChangeNotifier {
  String adhanLink = "https://mawaqit.net/static/mp3/adhan-afassy.mp3";
  String bipLink = "https://mawaqit.net/static/mp3/bip.mp3";
  String duaAfterAdhanLink = "https://mawaqit.net/static/mp3/duaa-after-adhan.mp3";
  late Audio adhan;
  late Audio duaAfterAdhan;
  late Audio bip;

  void loadAndPlayAdhanVoice(MosqueConfig? mosqueConfig, {VoidCallback? onDone}) {
    if (mosqueConfig!.adhanVoice != null && mosqueConfig.adhanVoice!.isNotEmpty) {
      adhanLink = "https://mawaqit.net/static/mp3/${mosqueConfig.adhanVoice!}.mp3";
    }
    adhan = Audio.loadFromRemoteUrl(
      adhanLink,
      onComplete: () {
        adhan.dispose();
        adhan.pause();
        onDone?.call();
      },
      onError: (message) {
        print("error$message");
        onDone?.call();
      },
    )!;
    adhan.play();
  }

  void loadAndPlayIqamaBipVoice(MosqueConfig? mosqueConfig, {VoidCallback? onDone}) {
    if (mosqueConfig!.iqamaBip) {
      adhanLink = "https://mawaqit.net/static/mp3/${mosqueConfig.adhanVoice!}.mp3";
      bip = Audio.loadFromRemoteUrl(
        bipLink,
        onComplete: () {
          bip.dispose();
          bip.pause();
          onDone?.call();
        },
        onError: (message) {
          print("error$message");
          onDone?.call();
        },
      )!;
      bip.play();
    }
  }

  void loadAndPlayDuaAfterAdhanVoice(MosqueConfig? mosqueConfig, {VoidCallback? onDone}) {
    duaAfterAdhan = Audio.loadFromRemoteUrl(
      duaAfterAdhanLink,
      onComplete: () {
        duaAfterAdhan.dispose();
        duaAfterAdhan.pause();
        onDone?.call();
      },
      onError: (message) {
        print("error$message");
        onDone?.call();
      },
    )!;
    duaAfterAdhan.play();
  }

  void playAdhan() {
    adhan.play();
  }

  void playDuaAfterAdhan() {
    duaAfterAdhan.play();
  }

  void stopAdhan() {
    adhan.pause();
    adhan.dispose();
  }
}
