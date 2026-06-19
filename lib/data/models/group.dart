import 'package:isar/isar.dart';

part 'group.g.dart';

@collection
class BuildingGroup {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  late String name;
  
  @Index(unique: true)
  late String inviteCode;

  @Index()
  late DateTime createdAt;
  
  @Index()
  late DateTime updatedAt;
  
  @Index()
  late bool isSynced;
  
  @Index()
  late bool isDeleted;
}
