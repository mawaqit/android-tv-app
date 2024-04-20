import '../../models/announcement.dart';

abstract class AnnouncementRepository {
  Stream<List<Announcement>> getAnnouncementsStream([String? mosqueUUID]);
  Future<List<Announcement>> getAnnouncements([String? mosqueUUID]);
}
