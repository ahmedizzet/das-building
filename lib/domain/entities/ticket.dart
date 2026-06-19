enum TicketStatus { pending, inProgress, resolved }

class Ticket {
  final String id;
  final String title;
  final String description;
  final TicketStatus status;
  final DateTime date;
  final String category;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.date,
    required this.category,
  });
}
