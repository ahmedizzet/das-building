import 'package:isar/isar.dart';
import '../../domain/entities/booking.dart' as entity;
import '../../domain/repositories/booking_repository.dart';
import '../models/booking.dart' as model;

class IsarBookingRepository implements BookingRepository {
  final Isar isar;

  IsarBookingRepository(this.isar);

  @override
  Future<List<entity.Booking>> getBookings() async {
    final bookings = await isar.bookings.where().filter().isDeletedEqualTo(false).findAll();
    return bookings.map((e) => _toEntity(e)).toList();
  }

  @override
  Future<void> addBooking(entity.Booking booking) async {
    final newBooking = model.Booking()
      ..serverId = booking.id
      ..tenantId = 'default_tenant'
      ..amenityId = booking.amenityId
      ..residentId = booking.residentId
      ..date = booking.date
      ..timeSlot = booking.timeSlot
      ..updatedAt = DateTime.now()
      ..isSynced = false
      ..isDeleted = false;

    await isar.writeTxn(() async {
      await isar.bookings.put(newBooking);
    });
  }

  @override
  Stream<List<entity.Booking>> watchBookings() {
    return isar.bookings
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((bookings) => bookings.map((e) => _toEntity(e)).toList());
  }

  entity.Booking _toEntity(model.Booking m) {
    return entity.Booking(
      id: m.serverId,
      amenityId: m.amenityId,
      residentId: m.residentId,
      date: m.date,
      timeSlot: m.timeSlot,
    );
  }
}
