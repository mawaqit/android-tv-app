import 'dart:developer';
import 'dart:isolate';
import 'package:meta/meta.dart';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/module/dio_module.dart';

import 'package:mawaqit/src/domain/error/recite_exception.dart';

import '../../../domain/model/quran/audio_file_model.dart';

class _DownloadParams {
  final String url;
  final SendPort sendPort;

  _DownloadParams(this.url, this.sendPort);
}

class ReciteRemoteDataSource {
  final Dio _dio;

  ReciteRemoteDataSource(this._dio);

  /// this is for getting the recitation types of each reciter
  Future<List<ReciterModel>> getReciters({
    required String language,
  }) async {
    try {
      final reciters = await _fetchReciters(
        language: language,
      );
      return reciters;
    } catch (e) {
      rethrow;
    }
  }

  @visibleForTesting
  Future<List<ReciterModel>> fetchReciters({
    required String language,
    int? reciterId,
    int? rewayaId,
    int? surahId,
    String? lastUpdatedDate,
  }) =>
      _fetchReciters(
        language: language,
        reciterId: reciterId,
        lastUpdatedDate: lastUpdatedDate,
        rewayaId: rewayaId,
        surahId: surahId,
      );

  Future<List<ReciterModel>> _fetchReciters({
    required String language,
    int? reciterId,
    int? rewayaId,
    int? surahId,
    String? lastUpdatedDate,
  }) async {
    try {
      final response = await _dio.get(
        'reciters',
        queryParameters: {
          'language': language,
          if (reciterId != null) 'reciter': reciterId,
          if (rewayaId != null) 'rewaya': rewayaId,
          if (surahId != null) 'sura': surahId,
          if (lastUpdatedDate != null) 'last_updated_date': lastUpdatedDate,
        },
      );

      if (response.statusCode == 200) {
        var data = response.data;
        data['reciters'].forEach((reciter) {
          reciter['moshaf'].forEach((moshaf) {
            moshaf['surah_list'] = _convertSurahListToIntegers(moshaf['surah_list']);
          });
        });

        final reciters = List<ReciterModel>.from(data['reciters'].map((reciter) => ReciterModel.fromJson(reciter)));
        return reciters;
      } else {
        throw FetchRecitersFailedException('Failed to fetch reciters', 'FETCH_RECITERS_ERROR');
      }
    } catch (e) {
      throw FetchRecitersFailedException(e.toString(), 'FETCH_RECITERS_ERROR');
    }
  }

  static List<int> _convertSurahListToIntegers(String surahList) {
    return surahList.split(',').map(int.parse).toList();
  }

  static void _downloadAudioFileIsolate(_DownloadParams params) async {
    final dio = Dio();
    try {
      final response = await dio.get<List<int>>(
        params.url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total) * 100;
            params.sendPort.send({'progress': progress});
          }
        },
      );

      if (response.statusCode == 200) {
        params.sendPort.send({'data': response.data!});
      } else {
        params.sendPort.send({'error': 'Failed to fetch audio file'});
      }
    } catch (e) {
      params.sendPort.send({'error': e.toString()});
    }

    Isolate.exit();
  }

  Future<List<int>> downloadAudioFile(
    AudioFileModel audioFile,
    Function(double) onProgress,
  ) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_downloadAudioFileIsolate, _DownloadParams(audioFile.url, receivePort.sendPort));

    List<int> downloadedList = [];
    await for (final message in receivePort) {
      if (message is Map) {
        if (message.containsKey('progress')) {
          onProgress(message['progress']);
        } else if (message.containsKey('data')) {
          downloadedList = message['data'];
          break;
        } else if (message.containsKey('error')) {
          throw (message['error']);
        }
      }
    }

    return downloadedList;
  }
}

final reciteRemoteDataSourceProvider = Provider<ReciteRemoteDataSource>((ref) {
  final dio = ref.watch(
    dioProvider(
      DioProviderParameter(
        baseUrl: QuranConstant.kQuranBaseUrl,
        interceptor: LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (l) => log('$l', name: 'API'),
        ),
      ),
    ),
  );
  return ReciteRemoteDataSource(dio.dio);
});
