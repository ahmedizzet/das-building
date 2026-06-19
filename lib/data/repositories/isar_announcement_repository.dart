import 'package:isar/isar.dart';
import '../../domain/entities/announcement.dart' as entity;
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement.dart' as model;

class IsarAnnouncementRepository implements AnnouncementRepository {
  final Isar isar;

  IsarAnnouncementRepository(this.isar);

  @override
  Future<List<entity.Announcement>> getAnnouncements() async {
    final announcements = await isar.announcements.where().filter().isDeletedEqualTo(false).sortByDateDesc().findAll();
    return announcements.map((e) => _toEntity(e)).toList();
  }

  @override
  Future<void> addAnnouncement(entity.Announcement announcement) async {
    final newAnnouncement = model.Announcement()
      ..serverId = announcement.id
      ..tenantId = 'default_tenant'
      ..title = announcement.title
      ..content = announcement.content
      ..author = announcement.author
      ..date = announcement.date
      ..isPinned = announcement.isPinned
      ..category = announcement.category
      ..imageUrl = announcement.imageUrl
      ..updatedAt = DateTime.now()
      ..isSynced = false
      ..isDeleted = false;

    await isar.writeTxn(() async {
      await isar.announcements.put(newAnnouncement);
    });
  }

  @override
  Stream<List<entity.Announcement>> watchAnnouncements() {
    return isar.announcements
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .watch(fireImmediately: true)
        .map((announcements) => announcements.map((e) => _toEntity(e)).toList());
  }

  entity.Announcement _toEntity(model.Announcement m) {
    return entity.Announcement(
      id: m.serverId,
      title: m.title,
      content: m.content,
      author: m.author,
      date: m.date,
      isPinned: m.isPinned,
      category: m.category,
      imageUrl: m.imageUrl,
    );
  }
}
