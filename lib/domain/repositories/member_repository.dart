import '../entities/member.dart';

abstract class MemberRepository {
  Future<List<Member>> getMembers();
  Future<void> addMember(Member member);
  Future<void> updateMember(Member member);
  Future<void> nudgeMember(String memberId);
  Future<Member?> findMemberByPhone(String phoneNumber);
  Stream<List<Member>> watchMembers();
}
