import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../services/api_service.dart';

class SystemProvider extends ChangeNotifier {
  final ApiService _api;

  String _pairingCode = '------';
  String get pairingCode => _pairingCode;

  Map<String, dynamic>? _stats;
  Map<String, dynamic>? get stats => _stats;

  final List<double> _cpuHistory = [];
  List<double> get cpuHistory => _cpuHistory;

  final List<double> _ramHistory = [];
  List<double> get ramHistory => _ramHistory;

  List<dynamic> _pairedDevices = [];
  List<dynamic> get pairedDevices => _pairedDevices;

  List<dynamic> _activity = [];
  List<dynamic> get activity => _activity;

  bool _isServerRunning = false;
  bool get isServerRunning => _isServerRunning;

  io.Socket? _socket;
  Timer? _refreshTimer;

  SystemProvider(this._api);

  void startMonitoring() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) => _refreshData());
    _refreshData();
    _connectSocket();
  }

  void _connectSocket() {
    _socket = io.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'extraHeaders': {'X-Auth-Token': 'cypher-internal-pc-app-token-2024'}
    });

    _socket!.on('system_stats', (data) {
      _stats = Map<String, dynamic>.from(data);
      _cpuHistory.add((_stats?['cpu_percent'] ?? 0.0).toDouble());
      _ramHistory.add((_stats?['ram_percent'] ?? 0.0).toDouble());
      if (_cpuHistory.length > 30) _cpuHistory.removeAt(0);
      if (_ramHistory.length > 30) _ramHistory.removeAt(0);
      notifyListeners();
    });

    _socket!.on('activity_update', (data) {
      _activity.insert(0, data);
      if (_activity.length > 100) _activity.removeLast();
      notifyListeners();
    });
  }

  Future<void> _refreshData() async {
    try {
      final codeRes = await _api.get('/connect-code');
      _pairingCode = codeRes['code'];

      final devicesRes = await _api.get('/paired-devices');
      _pairedDevices = devicesRes;

      final activityRes = await _api.get('/system/activity');
      _activity = activityRes;

      _isServerRunning = true;
      notifyListeners();
    } catch (e) {
      _isServerRunning = false;
      notifyListeners();
    }
  }

  Future<void> rotatePairingCode() async {
    try {
      final res = await _api.post('/connect-code');
      _pairingCode = res['code'];
      notifyListeners();
    } catch (e) {}
  }

  Future<void> unpairDevice(String deviceId) async {
    await _api.post('/unpair', body: {'device_id': deviceId});
    _refreshData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _socket?.disconnect();
    super.dispose();
  }
}
