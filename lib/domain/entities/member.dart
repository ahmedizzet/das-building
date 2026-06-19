enum PaymentStatus { paid, unpaid, late }

class Member {
  final String id;
  final String name;
  final String unit;
  final double balance;
  final PaymentStatus status;
  final String imageUrl;
  final String phoneNumber;

  Member({
    required this.id,
    required this.name,
    required this.unit,
    required this.balance,
    required this.status,
    required this.imageUrl,
    required this.phoneNumber,
  });
}
