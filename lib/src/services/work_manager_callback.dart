// lib/src/services/work_manager_callback.dart

import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == 'scheduleAudioTask') {
        return await handleScheduleAudioTask(inputData);
      }
      return true;
    } catch (e) {
      print('Background task error: $e');
      return false;
    }
  });
}

Future<bool> handleScheduleAudioTask(Map<String, dynamic>? inputData) async {
  if (inputData == null) return false;

  final prefs = await SharedPreferences.getInstance();
  final isEnabled = prefs.getBool('kScheduleEnabled') ?? false;
  if (!isEnabled) return true;

  final now = DateTime.now();
  final currentMinutes = now.hour * 60 + now.minute;
  final startMinutes = inputData['startMinutes'] as int;
  final endMinutes = inputData['endMinutes'] as int;

  if (currentMinutes >= startMinutes && currentMinutes <= endMinutes) {
    final isRandomEnabled = inputData['isRandomEnabled'] as bool;

    if (isRandomEnabled) {
      final urls = prefs.getStringList('kRandomUrls') ?? [];
      if (urls.isEmpty) return true;
      await playAudio(urls);
    } else {
      final url = prefs.getString('kSelectedSurahUrl');
      if (url == null) return true;
      await playAudio([url]);
    }
  }

  return true;
}

Future<void> playAudio(List<String> urls) async {
  final session = await AudioSession.instance;
  await session.configure(
    AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ),
  );

  final player = AudioPlayer();
  final playlist = ConcatenatingAudioSource(
    children: urls.map((url) => AudioSource.uri(Uri.parse(url))).toList(),
  );

  try {
    await player.setAudioSource(playlist);
    await player.setLoopMode(LoopMode.all);
    await player.play();
  } catch (e) {
    print('Error playing audio in background: $e');
  }
}
