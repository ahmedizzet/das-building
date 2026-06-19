import '../entities/announcement.dart';

abstract class AnnouncementRepository {
  Future<List<Announcement>> getAnnouncements();
  Future<void> addAnnouncement(Announcement announcement);
  Stream<List<Announcement>> watchAnnouncements();
}
