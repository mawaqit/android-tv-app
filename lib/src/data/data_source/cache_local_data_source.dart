import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mawaqit/src/const/constants.dart';

class CacheLocalDataSource {
  static Box<dynamic>? _box;

  // Initialization method
  Future<void> init() async {
    if (_box != null) return;
    final directory = await getApplicationDocumentsDirectory();
    _box = await Hive.openBox(CacheKey.kHttpRequests, path: directory.path);
  }

  Box<dynamic> get box {
    if (_box == null) {
      throw Exception('CacheLocalDataSource not initialized');
    }
    return _box!;
  }

  Future<void> cacheResponse(String cacheKey, Response response) async {
    final cacheData = {
      'data': json.encode(response.data),
      'lastModified': response.headers.value(HttpHeaderConstant.kHeaderLastModified),
    };
    await box.put(cacheKey, cacheData);
  }

  dynamic getCachedData(String cacheKey) async {
    return await box.get(cacheKey);
  }
}

final cacheLocalDataSourceProvider = FutureProvider<CacheLocalDataSource>((ref) async {
  final cacheLocalDataSource = CacheLocalDataSource();
  await cacheLocalDataSource.init();
  return cacheLocalDataSource;
});
