import 'package:flutter/material.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/group_member_repository.dart';
import '../../domain/repositories/member_repository.dart';

class OnboardingProvider with ChangeNotifier {
  final GroupMemberRepository _groupMemberRepository;
  final MemberRepository _memberRepository;

  List<GroupMember> _groupMembers = [];
  List<Member> _allAppMembers = [];

  OnboardingProvider(this._groupMemberRepository, this._memberRepository) {
    _init();
  }

  void _init() {
    _groupMemberRepository.watchGroupMembers().listen((members) {
      _groupMembers = members;
      notifyListeners();
    });
    _memberRepository.watchMembers().listen((members) {
      _allAppMembers = members;
      notifyListeners();
    });
  }

  List<GroupMember> get groupMembers => _groupMembers;
  List<Member> get allAppMembers => _allAppMembers;

  Future<void> addMemberByPhone(String phoneNumber) async {
    // Cross-reference with app users
    final member = _allAppMembers.firstWhere(
      (m) => m.phoneNumber == phoneNumber,
      orElse: () => throw Exception('User not found with this phone number'),
    );

    // Check if already in group
    if (_groupMembers.any((gm) => gm.memberId == member.id)) {
      throw Exception('User is already a member of this building group');
    }

    final newGroupMember = GroupMember(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      memberId: member.id,
      monthlyFee: 0.0,
    );

    await _groupMemberRepository.addGroupMember(newGroupMember);
  }

  Future<void> addMemberByQR(String qrData) async {
    // Assuming QR data contains the member ID or phone number
    // For now, let's treat it as a phone number
    await addMemberByPhone(qrData);
  }

  Future<void> updateMonthlyFee(String memberId, double fee) async {
    await _groupMemberRepository.updateMonthlyFee(memberId, fee);
  }

  Member? getMemberDetails(String memberId) {
    try {
      return _allAppMembers.firstWhere((m) => m.id == memberId);
    } catch (_) {
      return null;
    }
  }
}
