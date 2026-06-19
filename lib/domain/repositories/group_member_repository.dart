import '../entities/group_member.dart';

abstract class GroupMemberRepository {
  Future<void> addGroupMember(GroupMember member);
  Future<List<GroupMember>> getGroupMembers();
  Stream<List<GroupMember>> watchGroupMembers();
  Future<void> updateMonthlyFee(String memberId, double fee);
}
