import 'package:isar/isar.dart';

part 'member.g.dart';

@collection
class Member {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String tenantId;

  late String name;
  late String unit;
  late double balance;
  late int status; // 0: Paid, 1: Unpaid, 2: Late
  late String imageUrl;

  @Index()
  late String phoneNumber;

  @Index()
  late DateTime updatedAt;
  @Index()
  late bool isSynced;
  late bool isDeleted;
}
