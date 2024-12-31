import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/src/data/data_source/quran/recite_remote_data_source.dart';
import 'package:mawaqit/src/data/data_source/quran/reciter_local_data_source.dart';
import 'package:mawaqit/src/domain/error/recite_exception.dart';

import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

import 'package:mawaqit/src/domain/repository/quran/recite_repository.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';

import '../../../domain/model/quran/audio_file_model.dart';

class ReciteImpl implements ReciteRepository {
  final ReciteRemoteDataSource _remoteDataSource;
  final ReciteLocalDataSource _localDataSource;

  ReciteImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<ReciterModel>> getAllReciters({required String language}) async {
    try {
      // Check if reciters are cached locally
      final cachedReciters = await _localDataSource.getReciters();
      final lastUpdatedOption = _localDataSource.getLastUpdatedTimestamp();

      // Check if the cached data is still valid (within 1 month)
      final isCacheValid = lastUpdatedOption.match(
        () => false, // No timestamp available, cache is invalid
        (lastUpdated) {
          final oneMonthAgo = DateTime.now().subtract(Duration(days: 30)); // 1 month ago
          return lastUpdated.isAfter(oneMonthAgo); // Check if the cache is within the retention period
        },
      );

      if (cachedReciters.isNotEmpty && isCacheValid) {
        log('ReciteImpl: Returning reciters from cache (last updated: ${lastUpdatedOption.getOrElse(
          () => DateTime.now(),
        )})');
        cachedReciters.sort((a, b) => a.name.compareTo(b.name));
        return cachedReciters;
      } else {
        log('ReciteImpl: Cached reciters are outdated or not available');
        await _localDataSource.clearAllReciters(); // Clear outdated cache
      }

      // If not cached or cache is outdated, fetch from the remote API
      log('ReciteImpl: Fetching reciters from remote API');
      final reciters = await _remoteDataSource.getReciters(language: language);
      reciters.sort((a, b) => a.name.compareTo(b.name));

      // Save the fetched reciters to the local cache
      await _localDataSource.saveReciters(reciters);

      return reciters;
    } catch (e) {
      // If an error occurs, try to return cached data as a fallback
      log('ReciteImpl: Error fetching reciters: $e');
      final cachedReciters = await _localDataSource.getReciters();
      if (cachedReciters.isNotEmpty) {
        log('ReciteImpl: Returning cached reciters as fallback');
        return cachedReciters;
      }

      // If no cached data is available, rethrow the error
      throw FetchRecitersFailedException(e.toString(), 'FETCH_RECITERS_ERROR');
    }
  }

  @override
  Future<void> addFavoriteReciter(int reciterId) async {
    await _localDataSource.addFavoriteReciter(reciterId);
  }

  @override
  Future<void> removeFavoriteReciter(int reciterId) async {
    await _localDataSource.removeFavoriteReciter(reciterId);
  }

  @override
  Future<List<ReciterModel>> getFavoriteReciters() async {
    return await _localDataSource.getFavoriteReciters();
  }

  @override
  bool isFavoriteReciter(int reciterId) {
    return _localDataSource.isFavoriteReciter(reciterId);
  }

  @override
  Future<void> clearAllReciters() async {
    await _localDataSource.clearAllReciters();
  }

  @override
  Future<String> getLocalSurahPath({
    required String reciterId,
    required String moshafId,
    required String surahNumber,
  }) async {
    return await _localDataSource.getSurahPathWithExtension(
      moshafId: moshafId,
      surahNumber: surahNumber,
      reciterId: reciterId,
    );
  }

  @override
  Future<bool> isSurahDownloaded({
    required String reciterId,
    required String moshafId,
    required int surahNumber,
  }) async {
    return await _localDataSource.isSurahDownloaded(
      reciterId: reciterId,
      moshafId: moshafId,
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
    required String moshafId,
  }) async {
    return _localDataSource.getDownloadedSurahByReciterAndRiwayah(
      moshafId: moshafId,
      reciterId: reciterId,
    );
  }
}

final reciteImplProvider = FutureProvider<ReciteImpl>((ref) async {
  final remoteDataSource = ref.read(reciteRemoteDataSourceProvider);
  final localDataSource = await ref.read(reciteLocalDataSourceProvider.future);
  return ReciteImpl(remoteDataSource, localDataSource);
});
