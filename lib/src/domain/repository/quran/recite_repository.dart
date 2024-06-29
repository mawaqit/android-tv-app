import 'dart:io';

import 'package:mawaqit/src/domain/model/quran/audio_file_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

abstract class ReciteRepository {
  Future<List<ReciterModel>> getRecitersBySurah({
    required int surahId,
    required String language,
  });

  Future<String> downloadAudio(AudioFileModel audioFile, Function(double) onProgress);

  Future<String> getAudioPath(AudioFileModel audioFile);

  Future<List<File>> getDownloadedSurahByReciterAndRiwayah({
    required String reciterId,
    required String riwayahId,
  });

  Future<bool> isSurahDownloaded({
    required String reciterId,
    required String riwayahId,
    required int surahNumber,
  });

  Future<String> getLocalSurahPath({
    required String reciterId,
    required String riwayahId,
    required String surahNumber,
  });
}
