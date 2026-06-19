import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/group_repository.dart';
import '../../domain/repositories/member_repository.dart';
import 'dashboard_provider.dart';
import '../../core/utils/id_generator.dart';

class GroupProvider with ChangeNotifier {
  final GroupRepository _groupRepository;
  final MemberRepository _memberRepository;
  final DashboardProvider _memberProvider;

  GroupProvider(this._groupRepository, this._memberRepository, this._memberProvider);

  BuildingGroup? _currentGroup;
  bool _isLoading = false;

  BuildingGroup? get currentGroup => _currentGroup;
  bool get isLoading => _isLoading;

  Future<void> loadGroup() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = _memberProvider.currentUser;
      if (user?.groupId != null) {
        _currentGroup = await _groupRepository.getGroupById(user!.groupId!);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createGroup(String name) async {
    final user = _memberProvider.currentUser;
    if (user == null || user.groupId != null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final inviteCode = _generateInviteCode();
      final newGroup = BuildingGroup(
        id: IdGenerator.generate(),
        name: name,
        inviteCode: inviteCode,
      );

      await _groupRepository.createGroup(newGroup);
      
      // Update user with group ID
      final updatedUser = user.copyWith(groupId: newGroup.id, role: MemberRole.admin);
      await _memberRepository.updateMember(updatedUser);
      
      // Sync with DashboardProvider
      await _memberProvider.loadCurrentUser(user.phoneNumber);
      
      _currentGroup = newGroup;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinGroupByCode(String code, {MemberRole role = MemberRole.member}) async {
    final user = _memberProvider.currentUser;
    if (user == null || user.groupId != null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final group = await _groupRepository.getGroupByInviteCode(code);
      if (group != null) {
        final updatedUser = user.copyWith(groupId: group.id, role: role);
        await _memberRepository.updateMember(updatedUser);
        await _memberProvider.loadCurrentUser(user.phoneNumber);
        _currentGroup = group;
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}

extension MemberCopyWith on Member {
  Member copyWith({String? groupId, MemberRole? role}) {
    return Member(
      id: id,
      name: name,
      unit: unit,
      balance: balance,
      status: status,
      role: role ?? this.role,
      imageUrl: imageUrl,
      phoneNumber: phoneNumber,
      groupId: groupId ?? this.groupId,
    );
  }
}
