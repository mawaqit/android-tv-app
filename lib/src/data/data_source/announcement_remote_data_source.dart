import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../const/constants.dart';
import '../../helpers/image_helper.dart';
import '../../models/announcement.dart';

class AnnouncementRemoteDataSource {
  final Dio dio;

  AnnouncementRemoteDataSource(this.dio);

  /// [getAnnouncementIds] fetches the announcement ids from the remote data source
  Future<List<int>> getAnnouncementIds(String mosqueUUID) async {
    try {
      final response = await dio.get(
        '/3.0/mosque/$mosqueUUID/messages',
      );
      log('announcement: AnnouncementRemoteDataSource: getAnnouncementIds');

      final events = response.data['events'];
      final announcements = response.data['announcements'];

      List<int> announcementAndEventIds = [];

      for (Map<String, dynamic> announcement in announcements) {
        log('announcement: AnnouncementRemoteDataSource: parse getAnnouncementIds ${announcement['id']}');
        announcementAndEventIds.add(
          announcement['id'],
        );
      }

      for (Map<String, dynamic> event in events) {
        log('announcement: AnnouncementRemoteDataSource: parse getAnnouncementIds ${event['id']}');
        announcementAndEventIds.add(event['id']);
      }
      log('announcement: AnnouncementRemoteDataSource: getAnnouncementIds ${announcementAndEventIds.length}');
      return announcementAndEventIds;
    } catch (e) {
      throw Exception('Error occurred while fetching announcements ids: $e');
    }
  }

  Future<List<Announcement>> getAnnouncement(String mosqueUUID) async {
    try {
      final response = await dio.get(
        '/3.0/mosque/$mosqueUUID/messages',
      );
      log('announcement: AnnouncementRemoteDataSource: getAnnouncement');

      final events = response.data['events'];
      final announcements = response.data['announcements'];

      List<Announcement> announcementAndEvents = [];

      for (Map<String, dynamic> announcement in announcements) {
        Announcement announcementModified;
        announcement['imageFile'] = await ImageHelper.loadImageFromUrl(announcement['image'] ?? '');
        announcementModified = Announcement.fromMap(announcement);
        log('announcement: AnnouncementRemoteDataSource: parse announcement ${announcementModified.id}');
        announcementAndEvents.add(
          announcementModified,
        );
      }

      for (Map<String, dynamic> event in events) {
        event['imageFile'] = await ImageHelper.loadImageFromUrl(event['image']);
        final eventModified = Announcement.fromMap(event);
        log('announcement: AnnouncementRemoteDataSource: parse announcement ${eventModified.id}');
        announcementAndEvents.add(eventModified);
      }
      log('announcement: AnnouncementRemoteDataSource: getAnnouncement ${announcementAndEvents.length}');
      return announcementAndEvents;
    } catch (e) {
      throw Exception('Error occurred while fetching announcements: $e');
    }
  }

  Stream<List<Announcement>> getAnnouncementStream(String mosqueUUID) async* {
    List<Announcement> cachedAnnouncement = [];
    Duration cacheExpiration = Duration(minutes: 1);

    Stream<List<Announcement>> updateStream = Stream.periodic(cacheExpiration).asyncMap((_) async {
      log('announcement: AnnouncementRemoteDataSource: getAnnouncementStream $mosqueUUID');
      List<Announcement> newAnnouncement = await getAnnouncement(mosqueUUID);
      if (newAnnouncement != cachedAnnouncement) {
        cachedAnnouncement = newAnnouncement;
        log('announcement: AnnouncementRemoteDataSource: getAnnouncementStream $mosqueUUID: new announcement received');
        return newAnnouncement;
      }
      return cachedAnnouncement;
    });
    yield* updateStream;
  }
}

final announcementRemoteDataSourceProvider = Provider(
  (ref) => AnnouncementRemoteDataSource(
    ref.read(dioProvider),
  ),
);

final dioProvider = Provider(
  (ref) => Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      headers: {
        'Api-Access-Token': kApiToken,
        'accept': 'application/json',
        'mawaqit-device': 'android-tv',
      },
    ),
  ),
);
