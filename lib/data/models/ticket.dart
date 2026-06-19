import 'package:isar/isar.dart';

part 'ticket.g.dart';

@collection
class Ticket {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String tenantId;

  late String title;
  late String description;
  late DateTime date;
  late String category;
  
  @Index()
  late int status; // 0: Pending, 1: In Progress, 2: Resolved
  
  String? residentId;

  @Index()
  late DateTime updatedAt;
  @Index()
  late bool isSynced;
  late bool isDeleted;
}
