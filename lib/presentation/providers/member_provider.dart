import 'package:flutter/material.dart';
import '../../domain/entities/member.dart';

class MemberProvider with ChangeNotifier {
  final List<Member> _members = [
    Member(id: '1', name: 'John Doe', unit: 'Apt 402', balance: 0, status: PaymentStatus.paid, imageUrl: 'https://i.pravatar.cc/150?u=1'),
    Member(id: '2', name: 'Jane Smith', unit: 'Apt 105', balance: 250, status: PaymentStatus.unpaid, imageUrl: 'https://i.pravatar.cc/150?u=2'),
    Member(id: '3', name: 'Robert Johnson', unit: 'Apt 301', balance: 1200, status: PaymentStatus.late, imageUrl: 'https://i.pravatar.cc/150?u=3'),
    Member(id: '4', name: 'Emily Brown', unit: 'Apt 202', balance: 0, status: PaymentStatus.paid, imageUrl: 'https://i.pravatar.cc/150?u=4'),
  ];

  List<Member> get members => _members;

  void nudgeMember(String memberId) {
    print('Nudging member: $memberId');
  }
}
