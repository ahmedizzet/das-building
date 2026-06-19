import 'package:flutter/material.dart';
import '../../domain/entities/amenity.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/amenity_repository.dart';
import '../../domain/repositories/booking_repository.dart';

class BookingProvider with ChangeNotifier {
  final AmenityRepository _amenityRepository;
  final BookingRepository _bookingRepository;
  List<Amenity> _amenities = [];
  List<Booking> _existingBookings = [];
  Amenity? _selectedAmenity;
  int _selectedDateIndex = 0;
  String? _selectedTimeSlot;
  final int _daysToShow = 7;

  BookingProvider(this._amenityRepository, this._bookingRepository) {
    _init();
  }

  void _init() {
    _amenityRepository.watchAmenities().listen((amenities) {
      _amenities = amenities;
      if (_selectedAmenity == null && amenities.isNotEmpty) {
        _selectedAmenity = amenities.first;
      }
      notifyListeners();
    });
    _bookingRepository.watchBookings().listen((bookings) {
      _existingBookings = bookings;
      notifyListeners();
    });
  }

  List<Amenity> get amenities => _amenities;
  Amenity? get selectedAmenity => _selectedAmenity;
  int get selectedDateIndex => _selectedDateIndex;
  String? get selectedTimeSlot => _selectedTimeSlot;
  int get daysToShow => _daysToShow;

  List<Booking> get existingBookings => _existingBookings;

  List<String> get timeSlots => [
    '09:00 AM', '10:00 AM', '11:00 AM',
    '12:00 PM', '01:00 PM', '02:00 PM',
  ];

  bool isTimeSlotBooked(String timeSlot) {
    if (_selectedAmenity == null) return false;
    final targetDate = DateTime.now().add(Duration(days: _selectedDateIndex));
    return _existingBookings.any((b) =>
      b.amenityId == _selectedAmenity!.id &&
      b.date.day == targetDate.day &&
      b.date.month == targetDate.month &&
      b.date.year == targetDate.year &&
      b.timeSlot == timeSlot
    );
  }

  void selectAmenity(Amenity amenity) {
    _selectedAmenity = amenity;
    _selectedTimeSlot = null;
    notifyListeners();
  }

  void selectDateIndex(int index) {
    _selectedDateIndex = index;
    _selectedTimeSlot = null;
    notifyListeners();
  }

  void toggleTimeSlot(String timeSlot) {
    if (_selectedTimeSlot == timeSlot) {
      _selectedTimeSlot = null;
    } else {
      _selectedTimeSlot = timeSlot;
    }
    notifyListeners();
  }

  Future<void> bookNow() async {
    if (_selectedAmenity == null || _selectedTimeSlot == null) return;

    final targetDate = DateTime.now().add(Duration(days: _selectedDateIndex));
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amenityId: _selectedAmenity!.id,
      residentId: 'default_resident',
      date: DateTime(targetDate.year, targetDate.month, targetDate.day),
      timeSlot: _selectedTimeSlot!,
    );
    await _bookingRepository.addBooking(booking);
    _selectedTimeSlot = null;
    notifyListeners();
  }
}
