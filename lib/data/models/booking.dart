import 'package:isar/isar.dart';

part 'booking.g.dart';

@collection
class Booking {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String tenantId;

  late String amenityId;
  late String residentId;
  
  late DateTime date;
  late String timeSlot;

  @Index()
  late DateTime updatedAt;
  @Index()
  late bool isSynced;
  late bool isDeleted;
}
