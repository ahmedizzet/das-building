class Payment {
  final String id;
  final String memberId;
  final double amount;
  final String type;
  final String? description;
  final DateTime date;

  Payment({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
  });
}
