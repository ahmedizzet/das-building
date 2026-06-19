import '../entities/group.dart';

abstract class GroupRepository {
  Future<BuildingGroup?> getGroupById(String id);
  Future<BuildingGroup?> getGroupByInviteCode(String code);
  Future<void> createGroup(BuildingGroup group);
  Future<void> updateGroup(BuildingGroup group);
  Stream<List<BuildingGroup>> watchGroups();
}
