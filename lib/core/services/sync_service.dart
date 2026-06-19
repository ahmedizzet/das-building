import 'dart:async';
import 'package:isar/isar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/models/expense.dart';
import '../../data/models/member.dart';
import '../../data/models/group.dart';
import '../../data/models/group_member.dart';
import '../../data/models/amenity.dart';
import '../../data/models/booking.dart';
import '../../data/models/announcement.dart';
import '../../data/models/ticket.dart';
import '../../data/models/payment.dart';
import '../../data/models/messages.dart';
import 'api_service.dart';

typedef Json = Map<String, dynamic>;

class SyncService {
  final Isar _isar;
  final ApiService _api;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _periodicTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncAt;
  bool _enabled = true;

  SyncService({
    required Isar isar,
    required ApiService api,
    Connectivity? connectivity,
  })  : _isar = isar,
        _api = api,
        _connectivity = connectivity ?? Connectivity();

  DateTime? get lastSyncAt => _lastSyncAt;
  bool get isSyncing => _isSyncing;
  bool get enabled => _enabled;

  void Function(bool isSyncing)? onSyncStateChanged;
  void Function(DateTime time)? onSyncCompleted;

  void start({Duration interval = const Duration(minutes: 5)}) {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile)) {
        _syncIfNeeded();
      }
    });
    _periodicTimer = Timer.periodic(interval, (_) => _syncIfNeeded());
    
    // Initial sync trigger
    _syncIfNeeded();
  }

  void stop() {
    _connectivitySub?.cancel();
    _periodicTimer?.cancel();
    _connectivitySub = null;
    _periodicTimer = null;
  }

  void setEnabled(bool value) {
    _enabled = value;
    if (value) _syncIfNeeded();
  }

  Future<void> _syncIfNeeded() async {
    if (!_enabled || _isSyncing) return;
    await sync();
  }

  Future<SyncResult> sync() async {
    if (_isSyncing) return SyncResult(idle: true);
    _isSyncing = true;
    onSyncStateChanged?.call(true);

    try {
      final pushData = await _collectUnsynced();
      // If lastSyncAt is null, use a date that is likely to cover the building's life but not all of time
      final pullSince = _lastSyncAt?.toIso8601String() ?? 
                       DateTime(2024, 1, 1).toIso8601String();

      print('[SyncService] Starting sync cycle...');
      print('[SyncService] Tenant ID: ${_api.tenantId}');
      print('[SyncService] Pushing: ${pushData.map((k, v) => MapEntry(k, v.length))}');
      print('[SyncService] Pulling since: $pullSince');

      final response = await _api.sync(
        push: pushData.isNotEmpty ? pushData : null,
        pull: _allPullKeys(pullSince),
      );

      print('[SyncService] Server response received: $response');

      if (response != null && response['success'] == true) {
        if (response['pulled'] is Map) {
          await _applyPulled(response['pulled'] as Map<String, dynamic>);
        }
        await _markSynced(pushData);
        _lastSyncAt = DateTime.now();
        onSyncCompleted?.call(_lastSyncAt!);
        print('[SyncService] Sync success at $_lastSyncAt');
        return SyncResult(success: true, syncedAt: _lastSyncAt);
      } else {
        final error = response['error']?.toString() ?? 'Server returned failure without error message';
        print('[SyncService] Sync failed: $error');
        return SyncResult(success: false, error: error);
      }
    } catch (e, stack) {
      print('[SyncService] Sync Exception: $e');
      print(stack);
      return SyncResult(success: false, error: e.toString());
    } finally {
      _isSyncing = false;
      onSyncStateChanged?.call(false);
    }
  }

  Future<Map<String, List<Json>>> _collectUnsynced() async {
    return {
      'expenses': (await _isar.expenses.where().filter().isSyncedEqualTo(false).findAll()).map(_modelToJson).toList(),
      'members': (await _isar.members.where().filter().isSyncedEqualTo(false).findAll()).map(_modelToJson).toList(),
      'groups': (await _isar.buildingGroups.where().filter().isSyncedEqualTo(false).findAll()).map(_modelToJson).toList(),
      'groupMembers': (await _isar.groupMembers.where().filter().isSyncedEqualTo(false).findAll()).map(_modelToJson).toList(),
      'amenities': (await _isar.amenitys.where().filter().isSyncedEqualTo(false).findAll()).map(_modelToJson).toList(),
      'bookings': (await _isar.bookings.where().filter().isSyncedEqualTo(false).findAll()).map(_modelToJson).toList(),
      'announcements': (await _isar.announcements.where().filter().isSyncedEqualTo(false).findAll()).map(_modelToJson).toList(),
      'tickets': (await _isar.tickets.where().filter().isSyncedEqualTo(false).findAll()).map(_modelToJson).toList(),
      'payments': (await _isar.payments.where().filter().isSyncedEqualTo(false).findAll()).map(_modelToJson).toList(),
      'messages': (await _isar.messages.where().filter().isSyncedEqualTo(false).findAll()).map(_modelToJson).toList(),
    };
  }

  Json _modelToJson(dynamic m) {
    final deletedFlag = (m as dynamic).isDeleted == true;
    final base = <String, dynamic>{
      '_id': (m as dynamic).serverId as String,
      'tenantId': (m as dynamic).tenantId as String,
      'updatedAt': ((m as dynamic).updatedAt as DateTime).toIso8601String(),
    };
    if (deletedFlag) {
      base['deletedAt'] = DateTime.now().toIso8601String();
    }
    if (m is Expense) {
      base['title'] = m.title;
      base['amount'] = m.amount;
      base['date'] = m.date.toIso8601String();
      base['category'] = m.category;
    } else if (m is Member) {
      base['name'] = m.name;
      base['unit'] = m.unit;
      base['balance'] = m.balance;
      base['status'] = m.status;
      base['role'] = m.role;
      base['imageUrl'] = m.imageUrl;
      base['phoneNumber'] = m.phoneNumber;
      base['groupId'] = m.groupId;
    } else if (m is BuildingGroup) {
      base['name'] = m.name;
      base['inviteCode'] = m.inviteCode;
    } else if (m is GroupMember) {
      base['memberId'] = m.memberId;
      base['monthlyFee'] = m.monthlyFee;
    } else if (m is Amenity) {
      base['title'] = m.title;
      base['imageUrl'] = m.imageUrl;
      base['policy'] = m.policy;
    } else if (m is Booking) {
      base['amenityId'] = m.amenityId;
      base['residentId'] = m.residentId;
      base['date'] = m.date.toIso8601String();
      base['timeSlot'] = m.timeSlot;
    } else if (m is Announcement) {
      base['title'] = m.title;
      base['content'] = m.content;
      base['author'] = m.author;
      base['date'] = m.date.toIso8601String();
      base['isPinned'] = m.isPinned;
      base['category'] = m.category;
      base['imageUrl'] = m.imageUrl;
    } else if (m is Ticket) {
      base['title'] = m.title;
      base['description'] = m.description;
      base['date'] = m.date.toIso8601String();
      base['category'] = m.category;
      base['status'] = m.status;
      base['residentId'] = m.residentId;
    } else if (m is Payment) {
      base['memberId'] = m.memberId;
      base['amount'] = m.amount;
      base['type'] = m.type;
      base['description'] = m.description;
      base['date'] = m.date.toIso8601String();
      base['createdAt'] = m.createdAt.toIso8601String();
    } else if (m is Message) {
      base['conversationId'] = m.conversationId;
      base['senderId'] = m.senderId;
      base['content'] = m.content;
      base['type'] = m.type;
      base['readBy'] = m.readBy;
      base['createdAt'] = m.createdAt.toIso8601String();
    }
    return base;
  }

  Map<String, String> _allPullKeys(String since) => {
    'expenses': since, 'members': since, 'groups': since, 'groupMembers': since,
    'amenities': since, 'bookings': since, 'announcements': since, 'tickets': since,
    'payments': since, 'messages': since,
  };

  Future<void> _applyPulled(Map<String, dynamic> pulled) async {
    if (pulled['expenses'] is List) for (final j in pulled['expenses']) await _upsertExpense(j as Json);
    if (pulled['members'] is List) for (final j in pulled['members']) await _upsertMember(j as Json);
    if (pulled['groups'] is List) for (final j in pulled['groups']) await _upsertGroup(j as Json);
    if (pulled['groupMembers'] is List) for (final j in pulled['groupMembers']) await _upsertGroupMember(j as Json);
    if (pulled['amenities'] is List) for (final j in pulled['amenities']) await _upsertAmenity(j as Json);
    if (pulled['bookings'] is List) for (final j in pulled['bookings']) await _upsertBooking(j as Json);
    if (pulled['announcements'] is List) for (final j in pulled['announcements']) await _upsertAnnouncement(j as Json);
    if (pulled['tickets'] is List) for (final j in pulled['tickets']) await _upsertTicket(j as Json);
    if (pulled['payments'] is List) for (final j in pulled['payments']) await _upsertPayment(j as Json);
    if (pulled['messages'] is List) for (final j in pulled['messages']) await _upsertMessage(j as Json);
  }

  Future<void> _upsertExpense(Json j) async {
    final sid = j['_id'] as String;
    final existing = await _isar.expenses.where().serverIdEqualTo(sid).findFirst();
    final serverUpdated = _parseUpdatedAt(j);
    await _isar.writeTxn(() async {
      if (j['deletedAt'] != null) {
        if (existing != null) { existing.isDeleted = true; existing.isSynced = true; await _isar.expenses.put(existing); }
      } else if (existing == null) {
        await _isar.expenses.put(Expense()
          ..serverId = sid
          ..tenantId = (j['tenantId'] as String?) ?? 'default_tenant'
          ..title = (j['title'] as String?) ?? ''
          ..amount = (j['amount'] as num?)?.toDouble() ?? 0
          ..date = _parseDate(j['date'])
          ..category = (j['category'] as String?) ?? ''
          ..updatedAt = serverUpdated ?? DateTime.now()
          ..isSynced = true
          ..isDeleted = false);
      } else if (serverUpdated != null && serverUpdated.isAfter(existing.updatedAt)) {
        existing.title = (j['title'] as String?) ?? existing.title;
        existing.amount = (j['amount'] as num?)?.toDouble() ?? existing.amount;
        existing.date = _parseDate(j['date']);
        existing.category = (j['category'] as String?) ?? existing.category;
        existing.updatedAt = serverUpdated;
        existing.isSynced = true;
        await _isar.expenses.put(existing);
      }
    });
  }

  Future<void> _upsertMember(Json j) async {
    final sid = j['_id'] as String;
    final existing = await _isar.members.where().serverIdEqualTo(sid).findFirst();
    final serverUpdated = _parseUpdatedAt(j);
    await _isar.writeTxn(() async {
      if (j['deletedAt'] != null) {
        if (existing != null) { existing.isDeleted = true; existing.isSynced = true; await _isar.members.put(existing); }
      } else if (existing == null) {
        await _isar.members.put(Member()
          ..serverId = sid
          ..tenantId = (j['tenantId'] as String?) ?? 'default_tenant'
          ..name = (j['name'] as String?) ?? ''
          ..unit = (j['unit'] as String?) ?? ''
          ..balance = (j['balance'] as num?)?.toDouble() ?? 0
          ..status = (j['status'] as num?)?.toInt() ?? 1
          ..role = (j['role'] as num?)?.toInt() ?? 1
          ..imageUrl = (j['imageUrl'] as String?) ?? ''
          ..phoneNumber = (j['phoneNumber'] as String?) ?? ''
          ..groupId = j['groupId'] as String?
          ..updatedAt = serverUpdated ?? DateTime.now()
          ..isSynced = true
          ..isDeleted = false);
      } else if (serverUpdated != null && serverUpdated.isAfter(existing.updatedAt)) {
        existing.name = (j['name'] as String?) ?? existing.name;
        existing.unit = (j['unit'] as String?) ?? existing.unit;
        existing.balance = (j['balance'] as num?)?.toDouble() ?? existing.balance;
        existing.status = (j['status'] as num?)?.toInt() ?? existing.status;
        existing.role = (j['role'] as num?)?.toInt() ?? existing.role;
        existing.imageUrl = (j['imageUrl'] as String?) ?? existing.imageUrl;
        existing.phoneNumber = (j['phoneNumber'] as String?) ?? existing.phoneNumber;
        existing.groupId = j['groupId'] as String?;
        existing.updatedAt = serverUpdated;
        existing.isSynced = true;
        await _isar.members.put(existing);
      }
    });
  }

  Future<void> _upsertGroup(Json j) async {
    final sid = j['_id'] as String;
    final existing = await _isar.buildingGroups.where().serverIdEqualTo(sid).findFirst();
    final serverUpdated = _parseUpdatedAt(j);
    await _isar.writeTxn(() async {
      if (j['deletedAt'] != null) {
        if (existing != null) { existing.isDeleted = true; existing.isSynced = true; await _isar.buildingGroups.put(existing); }
      } else if (existing == null) {
        await _isar.buildingGroups.put(BuildingGroup()
          ..serverId = sid
          ..name = (j['name'] as String?) ?? ''
          ..inviteCode = (j['inviteCode'] as String?) ?? ''
          ..createdAt = _parseDate(j['createdAt'])
          ..updatedAt = serverUpdated ?? DateTime.now()
          ..isSynced = true
          ..isDeleted = false);
      } else if (serverUpdated != null && serverUpdated.isAfter(existing.updatedAt)) {
        existing.name = (j['name'] as String?) ?? existing.name;
        existing.inviteCode = (j['inviteCode'] as String?) ?? existing.inviteCode;
        existing.updatedAt = serverUpdated;
        existing.isSynced = true;
        await _isar.buildingGroups.put(existing);
      }
    });
  }

  Future<void> _upsertGroupMember(Json j) async {
    final sid = j['_id'] as String;
    final existing = await _isar.groupMembers.where().serverIdEqualTo(sid).findFirst();
    final serverUpdated = _parseUpdatedAt(j);
    await _isar.writeTxn(() async {
      if (j['deletedAt'] != null) {
        if (existing != null) { existing.isDeleted = true; existing.isSynced = true; await _isar.groupMembers.put(existing); }
      } else if (existing == null) {
        await _isar.groupMembers.put(GroupMember()
          ..serverId = sid
          ..tenantId = (j['tenantId'] as String?) ?? 'default_tenant'
          ..memberId = (j['memberId'] as String?) ?? ''
          ..monthlyFee = (j['monthlyFee'] as num?)?.toDouble() ?? 0
          ..updatedAt = serverUpdated ?? DateTime.now()
          ..isSynced = true
          ..isDeleted = false);
      } else if (serverUpdated != null && serverUpdated.isAfter(existing.updatedAt)) {
        existing.memberId = (j['memberId'] as String?) ?? existing.memberId;
        existing.monthlyFee = (j['monthlyFee'] as num?)?.toDouble() ?? existing.monthlyFee;
        existing.updatedAt = serverUpdated;
        existing.isSynced = true;
        await _isar.groupMembers.put(existing);
      }
    });
  }

  Future<void> _upsertAmenity(Json j) async {
    final sid = j['_id'] as String;
    final existing = await _isar.amenitys.where().serverIdEqualTo(sid).findFirst();
    final serverUpdated = _parseUpdatedAt(j);
    await _isar.writeTxn(() async {
      if (j['deletedAt'] != null) {
        if (existing != null) { existing.isDeleted = true; existing.isSynced = true; await _isar.amenitys.put(existing); }
      } else if (existing == null) {
        await _isar.amenitys.put(Amenity()
          ..serverId = sid
          ..tenantId = (j['tenantId'] as String?) ?? 'default_tenant'
          ..title = (j['title'] as String?) ?? ''
          ..imageUrl = (j['imageUrl'] as String?) ?? ''
          ..policy = j['policy'] as String?
          ..updatedAt = serverUpdated ?? DateTime.now()
          ..isSynced = true
          ..isDeleted = false);
      } else if (serverUpdated != null && serverUpdated.isAfter(existing.updatedAt)) {
        existing.title = (j['title'] as String?) ?? existing.title;
        existing.imageUrl = (j['imageUrl'] as String?) ?? existing.imageUrl;
        existing.policy = j['policy'] as String?;
        existing.updatedAt = serverUpdated;
        existing.isSynced = true;
        await _isar.amenitys.put(existing);
      }
    });
  }

  Future<void> _upsertBooking(Json j) async {
    final sid = j['_id'] as String;
    final existing = await _isar.bookings.where().serverIdEqualTo(sid).findFirst();
    final serverUpdated = _parseUpdatedAt(j);
    await _isar.writeTxn(() async {
      if (j['deletedAt'] != null) {
        if (existing != null) { existing.isDeleted = true; existing.isSynced = true; await _isar.bookings.put(existing); }
      } else if (existing == null) {
        await _isar.bookings.put(Booking()
          ..serverId = sid
          ..tenantId = (j['tenantId'] as String?) ?? 'default_tenant'
          ..amenityId = (j['amenityId'] as String?) ?? ''
          ..residentId = (j['residentId'] as String?) ?? ''
          ..date = _parseDate(j['date'])
          ..timeSlot = (j['timeSlot'] as String?) ?? ''
          ..updatedAt = serverUpdated ?? DateTime.now()
          ..isSynced = true
          ..isDeleted = false);
      } else if (serverUpdated != null && serverUpdated.isAfter(existing.updatedAt)) {
        existing.amenityId = (j['amenityId'] as String?) ?? existing.amenityId;
        existing.residentId = (j['residentId'] as String?) ?? existing.residentId;
        existing.date = _parseDate(j['date']);
        existing.timeSlot = (j['timeSlot'] as String?) ?? existing.timeSlot;
        existing.updatedAt = serverUpdated;
        existing.isSynced = true;
        await _isar.bookings.put(existing);
      }
    });
  }

  Future<void> _upsertAnnouncement(Json j) async {
    final sid = j['_id'] as String;
    final existing = await _isar.announcements.where().serverIdEqualTo(sid).findFirst();
    final serverUpdated = _parseUpdatedAt(j);
    await _isar.writeTxn(() async {
      if (j['deletedAt'] != null) {
        if (existing != null) { existing.isDeleted = true; existing.isSynced = true; await _isar.announcements.put(existing); }
      } else if (existing == null) {
        await _isar.announcements.put(Announcement()
          ..serverId = sid
          ..tenantId = (j['tenantId'] as String?) ?? 'default_tenant'
          ..title = (j['title'] as String?) ?? ''
          ..content = (j['content'] as String?) ?? ''
          ..author = (j['author'] as String?) ?? ''
          ..date = _parseDate(j['date'])
          ..isPinned = j['isPinned'] == true
          ..category = j['category'] as String?
          ..imageUrl = j['imageUrl'] as String?
          ..updatedAt = serverUpdated ?? DateTime.now()
          ..isSynced = true
          ..isDeleted = false);
      } else if (serverUpdated != null && serverUpdated.isAfter(existing.updatedAt)) {
        existing.title = (j['title'] as String?) ?? existing.title;
        existing.content = (j['content'] as String?) ?? existing.content;
        existing.author = (j['author'] as String?) ?? existing.author;
        existing.date = _parseDate(j['date']);
        existing.isPinned = j['isPinned'] == true;
        existing.category = j['category'] as String?;
        existing.imageUrl = j['imageUrl'] as String?;
        existing.updatedAt = serverUpdated;
        existing.isSynced = true;
        await _isar.announcements.put(existing);
      }
    });
  }

  Future<void> _upsertTicket(Json j) async {
    final sid = j['_id'] as String;
    final existing = await _isar.tickets.where().serverIdEqualTo(sid).findFirst();
    final serverUpdated = _parseUpdatedAt(j);
    await _isar.writeTxn(() async {
      if (j['deletedAt'] != null) {
        if (existing != null) { existing.isDeleted = true; existing.isSynced = true; await _isar.tickets.put(existing); }
      } else if (existing == null) {
        await _isar.tickets.put(Ticket()
          ..serverId = sid
          ..tenantId = (j['tenantId'] as String?) ?? 'default_tenant'
          ..title = (j['title'] as String?) ?? ''
          ..description = (j['description'] as String?) ?? ''
          ..date = _parseDate(j['date'])
          ..category = (j['category'] as String?) ?? ''
          ..status = (j['status'] as num?)?.toInt() ?? 0
          ..residentId = j['residentId'] as String?
          ..updatedAt = serverUpdated ?? DateTime.now()
          ..isSynced = true
          ..isDeleted = false);
      } else if (serverUpdated != null && serverUpdated.isAfter(existing.updatedAt)) {
        existing.title = (j['title'] as String?) ?? existing.title;
        existing.description = (j['description'] as String?) ?? existing.description;
        existing.date = _parseDate(j['date']);
        existing.category = (j['category'] as String?) ?? existing.category;
        existing.status = (j['status'] as num?)?.toInt() ?? existing.status;
        existing.residentId = j['residentId'] as String?;
        existing.updatedAt = serverUpdated;
        existing.isSynced = true;
        await _isar.tickets.put(existing);
      }
    });
  }

  Future<void> _upsertPayment(Json j) async {
    final sid = j['_id'] as String;
    final existing = await _isar.payments.where().serverIdEqualTo(sid).findFirst();
    final serverUpdated = _parseUpdatedAt(j);
    await _isar.writeTxn(() async {
      if (j['deletedAt'] != null) {
        if (existing != null) { existing.isDeleted = true; existing.isSynced = true; await _isar.payments.put(existing); }
      } else if (existing == null) {
        await _isar.payments.put(Payment()
          ..serverId = sid
          ..tenantId = (j['tenantId'] as String?) ?? 'default_tenant'
          ..memberId = (j['memberId'] as String?) ?? ''
          ..amount = (j['amount'] as num?)?.toDouble() ?? 0
          ..type = (j['type'] as String?) ?? ''
          ..description = j['description'] as String?
          ..date = _parseDate(j['date'])
          ..createdAt = _parseDate(j['createdAt'])
          ..updatedAt = serverUpdated ?? DateTime.now()
          ..isSynced = true
          ..isDeleted = false);
      } else if (serverUpdated != null && serverUpdated.isAfter(existing.updatedAt)) {
        existing.memberId = (j['memberId'] as String?) ?? existing.memberId;
        existing.amount = (j['amount'] as num?)?.toDouble() ?? existing.amount;
        existing.type = (j['type'] as String?) ?? existing.type;
        existing.description = j['description'] as String?;
        existing.date = _parseDate(j['date']);
        existing.updatedAt = serverUpdated;
        existing.isSynced = true;
        await _isar.payments.put(existing);
      }
    });
  }

  Future<void> _upsertMessage(Json j) async {
    final sid = j['_id'] as String;
    final existing = await _isar.messages.where().serverIdEqualTo(sid).findFirst();
    final serverUpdated = _parseUpdatedAt(j);
    await _isar.writeTxn(() async {
      if (j['deletedAt'] != null) {
        if (existing != null) { existing.isDeleted = true; existing.isSynced = true; await _isar.messages.put(existing); }
      } else if (existing == null) {
        await _isar.messages.put(Message()
          ..serverId = sid
          ..tenantId = (j['tenantId'] as String?) ?? 'default_tenant'
          ..conversationId = (j['conversationId'] as String?) ?? ''
          ..senderId = (j['senderId'] as String?) ?? ''
          ..content = (j['content'] as String?) ?? ''
          ..type = (j['type'] as String?) ?? 'text'
          ..readBy = (j['readBy'] as List<dynamic>?)?.cast<String>() ?? []
          ..createdAt = _parseDate(j['createdAt'])
          ..updatedAt = serverUpdated ?? DateTime.now()
          ..isSynced = true
          ..isDeleted = false);
      } else if (serverUpdated != null && serverUpdated.isAfter(existing.updatedAt)) {
        existing.content = (j['content'] as String?) ?? existing.content;
        existing.type = (j['type'] as String?) ?? existing.type;
        existing.readBy = (j['readBy'] as List<dynamic>?)?.cast<String>() ?? existing.readBy;
        existing.updatedAt = serverUpdated;
        existing.isSynced = true;
        await _isar.messages.put(existing);
      }
    });
  }

  Future<void> _markSynced(Map<String, List<Json>> pushed) async {
    await _isar.writeTxn(() async {
      for (final entry in pushed.entries) {
        for (final j in entry.value) {
          final sid = j['_id'] as String?;
          if (sid == null) continue;
          switch (entry.key) {
            case 'expenses':
              final e1 = await _isar.expenses.where().serverIdEqualTo(sid).findFirst();
              if (e1 != null) { e1.isSynced = true; await _isar.expenses.put(e1); }
              break;
            case 'members':
              final e2 = await _isar.members.where().serverIdEqualTo(sid).findFirst();
              if (e2 != null) { e2.isSynced = true; await _isar.members.put(e2); }
              break;
            case 'groups':
              final e3 = await _isar.buildingGroups.where().serverIdEqualTo(sid).findFirst();
              if (e3 != null) { e3.isSynced = true; await _isar.buildingGroups.put(e3); }
              break;
            case 'groupMembers':
              final e4 = await _isar.groupMembers.where().serverIdEqualTo(sid).findFirst();
              if (e4 != null) { e4.isSynced = true; await _isar.groupMembers.put(e4); }
              break;
            case 'amenities':
              final e5 = await _isar.amenitys.where().serverIdEqualTo(sid).findFirst();
              if (e5 != null) { e5.isSynced = true; await _isar.amenitys.put(e5); }
              break;
            case 'bookings':
              final e6 = await _isar.bookings.where().serverIdEqualTo(sid).findFirst();
              if (e6 != null) { e6.isSynced = true; await _isar.bookings.put(e6); }
              break;
            case 'announcements':
              final e7 = await _isar.announcements.where().serverIdEqualTo(sid).findFirst();
              if (e7 != null) { e7.isSynced = true; await _isar.announcements.put(e7); }
              break;
            case 'tickets':
              final e8 = await _isar.tickets.where().serverIdEqualTo(sid).findFirst();
              if (e8 != null) { e8.isSynced = true; await _isar.tickets.put(e8); }
              break;
            case 'payments':
              final e9 = await _isar.payments.where().serverIdEqualTo(sid).findFirst();
              if (e9 != null) { e9.isSynced = true; await _isar.payments.put(e9); }
              break;
            case 'messages':
              final e10 = await _isar.messages.where().serverIdEqualTo(sid).findFirst();
              if (e10 != null) { e10.isSynced = true; await _isar.messages.put(e10); }
              break;
          }
        }
      }
    });
  }

  DateTime _parseDate(dynamic d) {
    if (d == null) return DateTime.now();
    if (d is DateTime) return d;
    return DateTime.tryParse(d.toString()) ?? DateTime.now();
  }

  DateTime? _parseUpdatedAt(Json j) {
    final u = j['updatedAt'];
    if (u == null) return null;
    if (u is DateTime) return u;
    return DateTime.tryParse(u.toString());
  }

  Future<bool> checkServer() async {
    try {
      return await _api.healthCheck();
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    stop();
  }
}

class SyncResult {
  final bool success;
  final DateTime? syncedAt;
  final String? error;
  final bool idle;

  SyncResult({this.success = false, this.syncedAt, this.error, this.idle = false});
}
