// prayer_audio_service.dart
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mawaqit/src/services/notification/notification_service.dart';

class PrayerAudioService {
  static AudioPlayer? _audioPlayer;

  static Future<void> playPrayer(String adhanAsset, bool adhanFromAssets) async {
    _audioPlayer = AudioPlayer();
    final session = await _configureAudioSession();
    await session.setActive(true);

    try {
      if (adhanFromAssets) {
        await _audioPlayer?.setAsset(adhanAsset);
        Future.delayed(const Duration(minutes: 1), () {
          NotificationService.dismissNotification();
        });
      } else {
        await _audioPlayer?.setUrl(adhanAsset);
      }

      await _audioPlayer?.play();

      _audioPlayer?.playbackEventStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          session.setActive(false);
          if (!adhanFromAssets) {
            NotificationService.dismissNotification();
          }
        }
      });
    } catch (e) {
      await session.setActive(false);
    }
  }

  static Future<void> stopAudio() async {
    await _audioPlayer?.stop();
  }

  static Future<AudioSession> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.audibilityEnforced,
        usage: AndroidAudioUsage.alarm,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    return session;
  }
}
