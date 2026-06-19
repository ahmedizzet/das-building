import 'package:isar/isar.dart';
import '../../domain/entities/payment.dart' as entity;
import '../../domain/repositories/payment_repository.dart';
import '../models/payment.dart' as model;

class IsarPaymentRepository implements PaymentRepository {
  final Isar isar;

  IsarPaymentRepository(this.isar);

  @override
  Future<List<entity.Payment>> getPayments() async {
    final payments = await isar.payments.where().filter().isDeletedEqualTo(false).sortByDateDesc().findAll();
    return payments.map((e) => _toEntity(e)).toList();
  }

  @override
  Future<void> addPayment(entity.Payment payment) async {
    final now = DateTime.now();
    final newPayment = model.Payment()
      ..serverId = payment.id
      ..tenantId = 'default_tenant'
      ..memberId = payment.memberId
      ..amount = payment.amount
      ..type = payment.type
      ..description = payment.description
      ..date = payment.date
      ..createdAt = now
      ..updatedAt = now
      ..isSynced = false
      ..isDeleted = false;

    await isar.writeTxn(() async {
      await isar.payments.put(newPayment);
    });
  }

  @override
  Stream<List<entity.Payment>> watchPayments() {
    return isar.payments
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .watch(fireImmediately: true)
        .map((payments) => payments.map((e) => _toEntity(e)).toList());
  }

  entity.Payment _toEntity(model.Payment m) {
    return entity.Payment(
      id: m.serverId,
      memberId: m.memberId,
      amount: m.amount,
      type: m.type,
      description: m.description,
      date: m.date,
    );
  }
}
