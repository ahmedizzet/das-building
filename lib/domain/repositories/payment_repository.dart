import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<List<Payment>> getPayments();
  Future<void> addPayment(Payment payment);
  Stream<List<Payment>> watchPayments();
}
