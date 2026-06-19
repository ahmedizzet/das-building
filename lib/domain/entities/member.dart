enum PaymentStatus { paid, unpaid, late }

enum MemberRole { admin, member }

class Member {
  final String id;
  final String name;
  final String unit;
  final double balance;
  final PaymentStatus status;
  final MemberRole role;
  final String imageUrl;
  final String phoneNumber;
  final String? groupId;

  Member({
    required this.id,
    required this.name,
    required this.unit,
    required this.balance,
    required this.status,
    required this.role,
    required this.imageUrl,
    required this.phoneNumber,
    this.groupId,
  });
}
