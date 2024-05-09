import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mawaqit/src/models/announcement.dart';

import '../../const/constants.dart';

class AnnouncementLocalDataSource {
  final Box box;

  AnnouncementLocalDataSource({
    required this.box,
  });

  /// [cacheAnnouncements] caches the provided announcements
  ///
  /// Throws an exception if an error occurs while caching the announcements
  Future<void> cacheAnnouncements(List<Announcement> announcements) async {
    try {
      log('announcement: AnnouncementLocalDataSource: cacheAnnouncements - start');
      await box.clear();
      for (final announcement in announcements) {
        if (announcement.isCacheable()) {
          await box.put(announcement.id, announcement);
          log('announcement: AnnouncementLocalDataSource: cacheAnnouncements - is cached ${announcement.id}');
        }
      }
    } catch (e) {
      throw Exception('Error occurred while caching announcements: $e');
    }
  }

  /// [cacheAnnouncement] caches the provided announcement
  Future<void> cacheAnnouncement(Announcement announcement) async {
    try {
      log('announcement: AnnouncementLocalDataSource: cacheAnnouncement - start');
      if (announcement.isCacheable()) {
        await box.put(announcement.id, announcement);
        log('announcement: AnnouncementLocalDataSource: cacheAnnouncement - ${announcement.id}');
      }
    } catch (e) {
      throw Exception('Error occurred while caching announcement: $e');
    }
  }

  /// [getAllCachedAnnouncements] returns a list of all cached announcements
  Future<List<Announcement>> getAllCachedAnnouncements() async {
    try {
      final List<Announcement> announcements = [];
      for (var i = 0; i < box.length; i++) {
        final announcement = box.getAt(i);
        if (announcement != null) {
          announcements.add(announcement);
        }
      }
      return announcements;
    } catch (e) {
      throw Exception('Error occurred while fetching cached announcements: $e');
    }
  }

  /// [getCachedAnnouncement] returns the announcement with the provided id
  Future<Announcement?> getCachedAnnouncement(String id) async {
    try {
      log('announcement: AnnouncementLocalDataSource: getCachedAnnouncement - $id');
      return box.get(id);
    } catch (e) {
      throw Exception('Error occurred while fetching cached announcement: $e');
    }
  }

  /// [clearAllCache] clears all announcements from the local storage
  Future<void> clearAllCache() async {
    try {
      await box.clear();
      log('announcement: AnnouncementLocalDataSource: clearAllCache');
    } catch (e) {
      throw Exception('Error occurred while clearing cache: $e');
    }
  }

  /// [getAllCachedAnnouncementIds] returns a list of all cached announcements ids
  Future<List<int>> getAllCachedAnnouncementIds() async {
    try {
      final List<int> announcements = [];
      for (var i = 0; i < box.length; i++) {
        final announcement = box.getAt(i) as Announcement?;
        if (announcement != null) {
          announcements.add(announcement.id);
        }
      }
      return announcements;
    } catch (e) {
      throw Exception('Error occurred while fetching cached announcements: $e');
    }
  }
}

final announcementLocalDataSourceProvider = FutureProvider<AnnouncementLocalDataSource>(
  (ref) async {
    // open box if not opened
    final box = await Hive.openBox(AnnouncementConstant.kBoxName);
    return AnnouncementLocalDataSource(
      box: box,
    );
  },
);
