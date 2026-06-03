import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class SystemProvider extends ChangeNotifier {
  final ApiService _api;
  final SocketService _socket;

  Map<String, dynamic>? _stats;
  Map<String, dynamic>? get stats => _stats;

  final List<double> _cpuHistory = [];
  List<double> get cpuHistory => _cpuHistory;

  final List<double> _ramHistory = [];
  List<double> get ramHistory => _ramHistory;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Timer? _statusTimer;

  SystemProvider(this._api, this._socket);

  void startMonitoring(String ip, String token, BuildContext context) {
    _socket.connect(ip, token, onNotification: (notif) {
      context.read<NotificationProvider>().addNotification(notif);
      // Show snackbar or local notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${notif['app']}: ${notif['title']}'),
          backgroundColor: CypherColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }, onStats: (stats) {
      _stats = stats;
      _cpuHistory.add((stats['cpu_percent'] ?? 0.0).toDouble());
      _ramHistory.add((stats['ram_percent'] ?? 0.0).toDouble());
      if (_cpuHistory.length > 20) _cpuHistory.removeAt(0);
      if (_ramHistory.length > 20) _ramHistory.removeAt(0);
      notifyListeners();
    });

    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (_) => fetchStatus());
    fetchStatus();
  }

  void stopMonitoring() {
    _statusTimer?.cancel();
  }

  Future<void> fetchStatus() async {
    try {
      final status = await _api.get('/status');
      _isConnected = status['status'] == 'online';

      final statsResponse = await _api.get('/system-stats');
      _stats = statsResponse;

      _cpuHistory.add((_stats?['cpu_percent'] ?? 0.0).toDouble());
      _ramHistory.add((_stats?['ram_percent'] ?? 0.0).toDouble());

      if (_cpuHistory.length > 20) _cpuHistory.removeAt(0);
      if (_ramHistory.length > 20) _ramHistory.removeAt(0);

      notifyListeners();
    } catch (e) {
      _isConnected = false;
      notifyListeners();
    }
  }

  Future<void> sendPowerCommand(String action) async {
    await _api.post('/power/$action');
  }

  Future<void> sendMediaCommand(String action) async {
    await _api.post('/media/$action');
  }

  Future<void> typeText(String text) async {
    await _api.post('/type', body: {'text': text});
  }

  Future<void> sendHotkey(List<String> keys) async {
    await _api.post('/keyboard/hotkey', body: {'keys': keys});
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
