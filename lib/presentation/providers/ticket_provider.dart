import 'package:flutter/material.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/ticket_repository.dart';

class TicketProvider with ChangeNotifier {
  final TicketRepository _repository;
  List<Ticket> _allTickets = [];
  String _selectedFilter = 'All Tickets';

  TicketProvider(this._repository) {
    _init();
  }

  void _init() {
    _repository.watchTickets().listen((tickets) {
      _allTickets = tickets;
      notifyListeners();
    });
  }

  String get selectedFilter => _selectedFilter;

  List<Ticket> get tickets {
    switch (_selectedFilter) {
      case 'Open':
        return _allTickets.where((t) => t.status == TicketStatus.pending).toList();
      case 'In Progress':
        return _allTickets.where((t) => t.status == TicketStatus.inProgress).toList();
      case 'Resolved':
        return _allTickets.where((t) => t.status == TicketStatus.resolved).toList();
      default:
        return _allTickets;
    }
  }

  void setSelectedFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> addTicket({
    required String title,
    required String description,
    required String category,
  }) async {
    final newTicket = Ticket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      status: TicketStatus.pending,
      date: DateTime.now(),
      category: category,
    );
    await _repository.addTicket(newTicket);
  }
}
