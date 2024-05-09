import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/domain/repository/announcement_repository.dart';
import 'package:mawaqit/src/models/address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../const/constants.dart';
import '../../helpers/SharedPref.dart';
import '../../helpers/connectivity_provider.dart';
import '../../models/announcement.dart';
import '../data_source/announcement_local_data_source.dart';
import '../data_source/announcement_remote_data_source.dart';

class AnnouncementImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource _remoteDataSource;
  final AnnouncementLocalDataSource _localDataSource;
  final SharedPreferences _sharedPreferences;

  AnnouncementImpl({
    required AnnouncementRemoteDataSource remoteDataSource,
    required AnnouncementLocalDataSource localDataSource,
    required Ref ref,
    required SharedPreferences sharedPreferences,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _sharedPreferences = sharedPreferences;

  @override
  Stream<List<Announcement>> getAnnouncementsStream([String? mosqueUUID]) {
    /// get the uuid of the mosque
    mosqueUUID ??= jsonDecode(_sharedPreferences.getString('mosqueUUId') ?? '{}');

    if (mosqueUUID == null || mosqueUUID.isEmpty) {
      throw Exception('No mosque id found');
    }

    return _remoteDataSource.getAnnouncementStream(mosqueUUID).handleError((error) {
      if (error is DioException) {
        if (error.type == DioExceptionType.connectionError) {
          throw Exception('No internet connection available');
        }
      }
      throw Exception('Error occurred while fetching announcement data: $error');
    });
  }

  @override
  Future<List<Announcement>> getAnnouncements([String? mosqueUUID]) async {
    /// get the uuid of the mosque
    mosqueUUID ??= jsonDecode(_sharedPreferences.getString('mosqueUUId') ?? '{}');

    log('announcement: AnnouncementImpl: getAnnouncements - mosqueId: $mosqueUUID');

    if (mosqueUUID == null || mosqueUUID.isEmpty) {
      throw Exception('No mosque id found');
    }
    log('announcement: AnnouncementImpl: getAnnouncements - mosqueId: $mosqueUUID');
    try {
      final remoteAnnouncements = await _remoteDataSource.getAnnouncement(mosqueUUID);
      await _localDataSource.cacheAnnouncements(remoteAnnouncements);
      log('announcement: AnnouncementImpl: getAnnouncements - online: $remoteAnnouncements');
      return remoteAnnouncements;
    } catch (e) {
      log('announcement: AnnouncementImpl: getAnnouncements - error: $e');
      try {
        final cachedAnnouncements = await _localDataSource.getAllCachedAnnouncements();
        log('announcement: AnnouncementImpl: getAnnouncements - offline: $cachedAnnouncements');
        return cachedAnnouncements;
      } catch (e) {
        rethrow;
      }
    }
  }
}

final announcementRepositoryProvider = FutureProvider<AnnouncementRepository>((ref) async {
  final remoteDataSource = ref.read(announcementRemoteDataSourceProvider);
  final localDataSource = await ref.read(announcementLocalDataSourceProvider.future);
  final sharedPreferences = await SharedPreferences.getInstance();
  return AnnouncementImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    ref: ref,
    sharedPreferences: sharedPreferences,
  );
});
