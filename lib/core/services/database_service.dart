import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/expense.dart';
import '../../data/models/ticket.dart';
import '../../data/models/member.dart';
import '../../data/models/amenity.dart';
import '../../data/models/booking.dart';
import '../../data/models/announcement.dart';
import '../../data/models/payment.dart';
import '../../data/models/messages.dart';
import '../../data/models/group_member.dart';
import '../../data/models/group.dart';

class DatabaseService {
  late Isar isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [
        ExpenseSchema,
        TicketSchema,
        MemberSchema,
        AmenitySchema,
        BookingSchema,
        AnnouncementSchema,
        PaymentSchema,
        MessageSchema,
        GroupMemberSchema,
        BuildingGroupSchema,
      ],
      directory: dir.path,
    );
  }
}
