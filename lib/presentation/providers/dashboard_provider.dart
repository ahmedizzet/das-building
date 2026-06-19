import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/member_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/id_generator.dart';

class DashboardProvider with ChangeNotifier {
  final MemberRepository _repository;
  final PaymentRepository _paymentRepository;
  final ApiService? _apiService;
  List<Member> _allMembers = [];
  List<Payment> _allPayments = [];
  String _searchQuery = '';
  String _selectedMonth;
  String _selectedPaymentFilter = 'Paid';
  Member? _currentUser;
  bool _isAdmin = false;

  DashboardProvider(this._repository, this._paymentRepository, [this._apiService])
      : _selectedMonth = DateFormat('MMM').format(DateTime.now()) {
    _init();
  }

  void _init() {
    _repository.watchMembers().listen((members) {
      _allMembers = members;
      _reevaluateAdmin();
      notifyListeners();
    });
    _paymentRepository.watchPayments().listen((payments) {
      _allPayments = payments;
      notifyListeners();
    });
  }

  void _reevaluateAdmin() {
    if (_currentUser == null) {
      _isAdmin = false;
      return;
    }
    _isAdmin = _currentUser!.role == MemberRole.admin;
  }

  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedPaymentFilter;
  String get selectedMonth => _selectedMonth;
  Member? get currentUser => _currentUser;
  List<Member> get allMembers => _allMembers;
  List<Payment> get allPayments => _allPayments;
  bool get isAdmin => _isAdmin;

  List<String> get months {
    final now = DateTime.now();
    final result = <String>[];
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      result.add(DateFormat('MMM').format(date));
    }
    return result;
  }

  int _monthIndex(String abbr) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    return months[abbr] ?? DateTime.now().month;
  }

  int get targetMonth => _monthIndex(_selectedMonth);
  int get targetYear => DateTime.now().year;

  List<Payment> paymentsForMemberInSelectedMonth(String memberId) =>
      _paymentsInSelectedMonth.where((p) => p.memberId == memberId).toList();

  List<Payment> get _paymentsInSelectedMonth =>
      _allPayments.where((p) =>
        p.date.month == targetMonth && p.date.year == targetYear
      ).toList();

  bool isMemberPaidInSelectedMonth(String memberId) =>
      _paymentsInSelectedMonth.any((p) => p.memberId == memberId);

  List<Member> get members {
    var filtered = _allMembers;

    if (_selectedPaymentFilter == 'Paid') {
      filtered = filtered.where((m) => isMemberPaidInSelectedMonth(m.id)).toList();
    } else {
      filtered = filtered.where((m) => !isMemberPaidInSelectedMonth(m.id)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((m) =>
        m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        m.unit.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  String? memberNameById(String id) {
    final member = _allMembers.where((m) => m.id == id).firstOrNull;
    return member?.name;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedMonth(String month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void setSelectedPaymentFilter(String filter) {
    _selectedPaymentFilter = filter;
    notifyListeners();
  }

  Future<void> nudgeMember(String memberId) async {
    await _repository.nudgeMember(memberId);
  }

  Future<void> addMember(Member member) async {
    await _repository.addMember(member);
  }

  Future<void> updateMember(Member member) async {
    await _repository.updateMember(member);
    final idx = _allMembers.indexWhere((m) => m.id == member.id);
    if (idx >= 0) {
      _allMembers[idx] = member;
      if (_currentUser?.id == member.id) {
        _currentUser = member;
      }
      notifyListeners();
    }
  }

  Future<void> recordPayment({
    required String memberId,
    required double amount,
  }) async {
    final payment = Payment(
      id: IdGenerator.generate(),
      memberId: memberId,
      amount: amount,
      type: 'fee',
      date: DateTime.now(),
    );
    await _paymentRepository.addPayment(payment);
  }

  Future<void> loadCurrentUser(String phoneNumber) async {
    final existing = await _repository.findMemberByPhone(phoneNumber);
    if (existing != null) {
      _currentUser = existing;
    } else {
      final isFirst = (await _repository.getMembers()).isEmpty;
      final newMember = Member(
        id: IdGenerator.generate(),
        name: 'Resident',
        unit: '',
        balance: 0,
        status: PaymentStatus.paid,
        role: isFirst ? MemberRole.admin : MemberRole.member,
        imageUrl: 'https://i.pravatar.cc/150?u=me',
        phoneNumber: phoneNumber,
      );
      await _repository.addMember(newMember);
      _currentUser = newMember;
    }

    if (_currentUser?.groupId != null) {
      _apiService?.setTenantId(_currentUser!.groupId!);
    }

    _reevaluateAdmin();
    notifyListeners();
  }
}
