import 'package:isar/isar.dart';
import '../../domain/entities/group_member.dart' as entity;
import '../../domain/repositories/group_member_repository.dart';
import '../models/group_member.dart' as model;

class IsarGroupMemberRepository implements GroupMemberRepository {
  final Isar isar;

  IsarGroupMemberRepository(this.isar);

  @override
  Future<void> addGroupMember(entity.GroupMember member) async {
    final newMember = model.GroupMember()
      ..serverId = member.id
      ..tenantId = 'default_tenant'
      ..memberId = member.memberId
      ..monthlyFee = member.monthlyFee
      ..updatedAt = DateTime.now()
      ..isSynced = false
      ..isDeleted = false;

    await isar.writeTxn(() async {
      await isar.groupMembers.put(newMember);
    });
  }

  @override
  Future<List<entity.GroupMember>> getGroupMembers() async {
    final members = await isar.groupMembers.where().filter().isDeletedEqualTo(false).findAll();
    return members.map((m) => _toEntity(m)).toList();
  }

  @override
  Stream<List<entity.GroupMember>> watchGroupMembers() {
    return isar.groupMembers
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((members) => members.map((m) => _toEntity(m)).toList());
  }

  @override
  Future<void> updateMonthlyFee(String memberId, double fee) async {
    final member = await isar.groupMembers.filter().memberIdEqualTo(memberId).findFirst();
    if (member != null) {
      member.monthlyFee = fee;
      member.updatedAt = DateTime.now();
      member.isSynced = false;
      await isar.writeTxn(() async {
        await isar.groupMembers.put(member);
      });
    }
  }

  entity.GroupMember _toEntity(model.GroupMember m) {
    return entity.GroupMember(
      id: m.serverId,
      memberId: m.memberId,
      monthlyFee: m.monthlyFee,
    );
  }
}
