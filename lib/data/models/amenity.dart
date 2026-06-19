import 'package:isar/isar.dart';

part 'amenity.g.dart';

@collection
class Amenity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String tenantId;

  late String title;
  late String imageUrl;
  String? policy;

  @Index()
  late DateTime updatedAt;
  @Index()
  late bool isSynced;
  late bool isDeleted;
}
