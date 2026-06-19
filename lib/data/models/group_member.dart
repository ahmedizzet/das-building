import 'package:isar/isar.dart';

part 'group_member.g.dart';

@collection
class GroupMember {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String tenantId;

  @Index()
  late String memberId; // Reference to Member.serverId

  late double monthlyFee;

  @Index()
  late DateTime updatedAt;
  @Index()
  late bool isSynced;
  @Index()
  late bool isDeleted;
}
