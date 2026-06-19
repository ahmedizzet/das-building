import 'package:isar/isar.dart';
import '../../domain/entities/group.dart' as entity;
import '../../domain/repositories/group_repository.dart';
import '../models/group.dart' as model;

class IsarGroupRepository implements GroupRepository {
  final Isar isar;

  IsarGroupRepository(this.isar);

  @override
  Future<entity.BuildingGroup?> getGroupById(String id) async {
    final group = await isar.buildingGroups.filter().serverIdEqualTo(id).findFirst();
    return group != null ? _toEntity(group) : null;
  }

  @override
  Future<entity.BuildingGroup?> getGroupByInviteCode(String code) async {
    final group = await isar.buildingGroups.filter().inviteCodeEqualTo(code).findFirst();
    return group != null ? _toEntity(group) : null;
  }

  @override
  Future<void> createGroup(entity.BuildingGroup group) async {
    final m = model.BuildingGroup()
      ..serverId = group.id
      ..name = group.name
      ..inviteCode = group.inviteCode
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..isSynced = false
      ..isDeleted = false;
    
    await isar.writeTxn(() async {
      await isar.buildingGroups.put(m);
    });
  }

  @override
  Future<void> updateGroup(entity.BuildingGroup group) async {
    final m = await isar.buildingGroups.filter().serverIdEqualTo(group.id).findFirst();
    if (m != null) {
      m.name = group.name;
      m.inviteCode = group.inviteCode;
      m.updatedAt = DateTime.now();
      m.isSynced = false;
      await isar.writeTxn(() async {
        await isar.buildingGroups.put(m);
      });
    }
  }

  @override
  Stream<List<entity.BuildingGroup>> watchGroups() {
    return isar.buildingGroups.where().watch(fireImmediately: true).map((list) => list.map((e) => _toEntity(e)).toList());
  }

  entity.BuildingGroup _toEntity(model.BuildingGroup m) {
    return entity.BuildingGroup(
      id: m.serverId,
      name: m.name,
      inviteCode: m.inviteCode,
    );
  }
}
