import 'package:flutter/material.dart';
import '../../domain/entities/ticket.dart';

class TicketProvider with ChangeNotifier {
  final List<Ticket> _tickets = [
    Ticket(
      id: '1',
      title: 'Leaking Pipe in Kitchen',
      description: 'Water is leaking from under the sink.',
      status: TicketStatus.inProgress,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'Plumbing',
    ),
    Ticket(
      id: '2',
      title: 'Broken Light in Hallway',
      description: 'The light on the 3rd floor is flickering.',
      status: TicketStatus.resolved,
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Electrical',
    ),
    Ticket(
      id: '3',
      title: 'AC Not Cooling',
      description: 'The AC in the living room is not cooling properly.',
      status: TicketStatus.pending,
      date: DateTime.now().subtract(const Duration(days: 3)),
      category: 'HVAC',
    ),
  ];

  List<Ticket> get tickets => _tickets;

  void addTicket(Ticket ticket) {
    _tickets.insert(0, ticket);
    notifyListeners();
  }
}
