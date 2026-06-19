import '../entities/ticket.dart';

abstract class TicketRepository {
  Future<List<Ticket>> getTickets();
  Future<void> addTicket(Ticket ticket);
  Future<void> updateTicketStatus(String ticketId, TicketStatus status);
  Stream<List<Ticket>> watchTickets();
}
