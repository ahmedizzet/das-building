import 'package:isar/isar.dart';

part 'announcement.g.dart';

@collection
class Announcement {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String tenantId;

  late String title;
  late String content;
  late String author;
  late DateTime date;

  @Index()
  late bool isPinned;
  
  String? category; 
  String? imageUrl;

  @Index()
  late DateTime updatedAt;
  @Index()
  late bool isSynced;
  late bool isDeleted;
}
