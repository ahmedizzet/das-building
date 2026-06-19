import 'package:isar/isar.dart';
import '../../domain/entities/ticket.dart' as entity;
import '../../domain/repositories/ticket_repository.dart';
import '../models/ticket.dart' as model;

class IsarTicketRepository implements TicketRepository {
  final Isar isar;

  IsarTicketRepository(this.isar);

  @override
  Future<List<entity.Ticket>> getTickets() async {
    final tickets = await isar.tickets.where().filter().isDeletedEqualTo(false).sortByDateDesc().findAll();
    return tickets.map((e) => _toEntity(e)).toList();
  }

  @override
  Future<void> addTicket(entity.Ticket ticket) async {
    final newTicket = model.Ticket()
      ..serverId = ticket.id
      ..tenantId = 'default_tenant'
      ..title = ticket.title
      ..description = ticket.description
      ..date = ticket.date
      ..category = ticket.category
      ..status = ticket.status.index
      ..updatedAt = DateTime.now()
      ..isSynced = false
      ..isDeleted = false;

    await isar.writeTxn(() async {
      await isar.tickets.put(newTicket);
    });
  }

  @override
  Future<void> updateTicketStatus(String ticketId, entity.TicketStatus status) async {
    final existing = await isar.tickets.where().serverIdEqualTo(ticketId).findFirst();
    if (existing != null) {
      existing.status = status.index;
      existing.updatedAt = DateTime.now();
      existing.isSynced = false;
      await isar.writeTxn(() async {
        await isar.tickets.put(existing);
      });
    }
  }

  @override
  Stream<List<entity.Ticket>> watchTickets() {
    return isar.tickets
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .watch(fireImmediately: true)
        .map((tickets) => tickets.map((e) => _toEntity(e)).toList());
  }

  entity.Ticket _toEntity(model.Ticket m) {
    return entity.Ticket(
      id: m.serverId,
      title: m.title,
      description: m.description,
      status: entity.TicketStatus.values[m.status],
      date: m.date,
      category: m.category,
    );
  }
}
