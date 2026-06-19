import '../entities/booking.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings();
  Future<void> addBooking(Booking booking);
  Stream<List<Booking>> watchBookings();
}
