class Booking {
  final String id;
  final String amenityId;
  final String residentId;
  final DateTime date;
  final String timeSlot;

  Booking({
    required this.id,
    required this.amenityId,
    required this.residentId,
    required this.date,
    required this.timeSlot,
  });
}
