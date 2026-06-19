import 'package:isar/isar.dart';
import '../../domain/entities/member.dart' as entity;
import '../../domain/repositories/member_repository.dart';
import '../models/member.dart' as model;

class IsarMemberRepository implements MemberRepository {
  final Isar isar;

  IsarMemberRepository(this.isar);

  @override
  Future<List<entity.Member>> getMembers() async {
    final members = await isar.members.where().filter().isDeletedEqualTo(false).findAll();
    return members.map((e) => _toEntity(e)).toList();
  }

  @override
  Future<void> addMember(entity.Member member) async {
    final newMember = _toModel(member);
    await isar.writeTxn(() async {
      await isar.members.put(newMember);
    });
  }

  @override
  Future<void> updateMember(entity.Member member) async {
    final existing = await isar.members.where().serverIdEqualTo(member.id).findFirst();
    if (existing != null) {
      existing.name = member.name;
      existing.unit = member.unit;
      existing.balance = member.balance;
      existing.status = member.status.index;
      existing.role = member.role.index;
      existing.imageUrl = member.imageUrl;
      existing.phoneNumber = member.phoneNumber;
      existing.groupId = member.groupId;
      existing.updatedAt = DateTime.now();
      existing.isSynced = false;
      await isar.writeTxn(() async {
        await isar.members.put(existing);
      });
    }
  }

  @override
  Future<void> nudgeMember(String memberId) async {
    final existing = await isar.members.where().serverIdEqualTo(memberId).findFirst();
    if (existing != null) {
      existing.updatedAt = DateTime.now();
      existing.isSynced = false;
      await isar.writeTxn(() async {
        await isar.members.put(existing);
      });
    }
  }

  @override
  Future<entity.Member?> findMemberByPhone(String phoneNumber) async {
    final member = await isar.members.where().phoneNumberEqualTo(phoneNumber).filter().isDeletedEqualTo(false).findFirst();
    if (member == null) return null;
    return _toEntity(member);
  }

  @override
  Stream<List<entity.Member>> watchMembers() {
    return isar.members
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((members) => members.map((e) => _toEntity(e)).toList());
  }

  model.Member _toModel(entity.Member m) {
    return model.Member()
      ..serverId = m.id
      ..tenantId = 'default_tenant'
      ..name = m.name
      ..unit = m.unit
      ..balance = m.balance
      ..status = m.status.index
      ..role = m.role.index
      ..imageUrl = m.imageUrl
      ..phoneNumber = m.phoneNumber
      ..groupId = m.groupId
      ..updatedAt = DateTime.now()
      ..isSynced = false
      ..isDeleted = false;
  }

  entity.Member _toEntity(model.Member m) {
    return entity.Member(
      id: m.serverId,
      name: m.name,
      unit: m.unit,
      balance: m.balance,
      status: entity.PaymentStatus.values[m.status],
      role: entity.MemberRole.values[m.role],
      imageUrl: m.imageUrl,
      phoneNumber: m.phoneNumber,
      groupId: m.groupId,
    );
  }
}
