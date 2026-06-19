import 'package:flutter/material.dart';
import '../../core/services/sync_service.dart';

class SyncProvider with ChangeNotifier {
  final SyncService _syncService;
  bool _isSyncing = false;
  DateTime? _lastSyncAt;
  bool _enabled = true;
  bool _serverReachable = false;
  String? _lastError;

  SyncProvider(this._syncService) {
    print('[SyncProvider] Initializing...');
    _syncService.onSyncStateChanged = (syncing) {
      _isSyncing = syncing;
      notifyListeners();
    };
    _syncService.onSyncCompleted = (time) {
      _lastSyncAt = time;
      _lastError = null;
      notifyListeners();
    };
    _lastSyncAt = _syncService.lastSyncAt;
    _checkServer();
    _syncService.start();
  }

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncAt => _lastSyncAt;
  bool get enabled => _enabled;
  bool get serverReachable => _serverReachable;
  String? get lastError => _lastError;

  void toggleSync(bool value) {
    _enabled = value;
    _syncService.setEnabled(value);
    notifyListeners();
  }

  Future<void> syncNow() async {
    final result = await _syncService.sync();
    if (!result.success && !result.idle) {
      _lastError = result.error;
    } else if (result.success) {
      _lastError = null;
    }
    notifyListeners();
  }

  Future<void> _checkServer() async {
    _serverReachable = await _syncService.checkServer();
    notifyListeners();
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }
}
