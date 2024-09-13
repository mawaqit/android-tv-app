import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/data/data_source/quran/recite_remote_data_source.dart';
import 'package:mawaqit/src/data/data_source/quran/reciter_local_data_source.dart';

import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

import 'package:mawaqit/src/domain/repository/quran/recite_repository.dart';

import '../../../domain/model/quran/audio_file_model.dart';

class ReciteImpl implements ReciteRepository {
  final ReciteRemoteDataSource _remoteDataSource;
  final ReciteLocalDataSource _localDataSource;

  ReciteImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<ReciterModel>> getAllReciters({required String language}) async {
    try {
      final reciters = await _remoteDataSource.getReciters(language: language);
      reciters.sort((a, b) => a.name.compareTo(b.name));
      await _localDataSource.saveReciters(reciters);
      return reciters;
    } catch (e) {
      final reciters = await _localDataSource.getReciters();
      reciters.sort((a, b) => a.name.compareTo(b.name));
      return reciters;
    }
  }

  @override
  Future<String> getLocalSurahPath({
    required String reciterId,
    required String riwayahId,
    required String surahNumber,
  }) async {
    return await _localDataSource.getSurahPathWithExtension(
      riwayahId: riwayahId,
      surahNumber: surahNumber,
      reciterId: reciterId,
    );
  }

  @override
  Future<bool> isSurahDownloaded({
    required String reciterId,
    required String riwayahId,
    required int surahNumber,
  }) async {
    return await _localDataSource.isSurahDownloaded(
      reciterId: reciterId,
      riwayahId: riwayahId,
      surahNumber: surahNumber,
    );
  }

  @override
  Future<String> downloadAudio(AudioFileModel audioFile, Function(double p1) onProgress) async {
    final downloadedList = await _remoteDataSource.downloadAudioFile(audioFile, onProgress);
    final path = await _localDataSource.saveAudioFile(audioFile, downloadedList);
    return path;
  }

  @override
  Future<List<File>> getDownloadedSuwarByReciterAndRiwayah({
    required String reciterId,
    required String riwayahId,
  }) async {
    return _localDataSource.getDownloadedSurahByReciterAndRiwayah(
      riwayahId: riwayahId,
      reciterId: reciterId,
    );
  }
}

final reciteImplProvider = FutureProvider<ReciteImpl>((ref) async {
  final remoteDataSource = ref.read(reciteRemoteDataSourceProvider);
  final localDataSource = await ref.read(reciteLocalDataSourceProvider.future);
  return ReciteImpl(remoteDataSource, localDataSource);
});
