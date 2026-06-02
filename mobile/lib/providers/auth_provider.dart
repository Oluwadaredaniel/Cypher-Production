import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api;
  final StorageService _storage;

  bool _isPaired = false;
  bool get isPaired => _isPaired;

  String? _deviceName;
  String? get deviceName => _deviceName;

  AuthProvider(this._api, this._storage) {
    _isPaired = _storage.isPaired;
    _deviceName = _storage.deviceName;
    if (_isPaired) {
      _api.updateConfig(_storage.pcIp!, _storage.authToken);
    }
  }

  Future<void> pair(String ip, String code) async {
    final deviceId = _storage.deviceId ?? 'android_${const Uuid().v4()}';
    final name = _storage.deviceName ?? Platform.localHostname;

    _api.updateConfig(ip, null);

    try {
      final response = await _api.post('/pair_device', body: {
        'pairing_code': code,
        'device_id': deviceId,
        'device_name': name,
      });

      if (response['success'] == true) {
        final token = response['token'];
        await _storage.savePairingData(
          token: token,
          deviceId: deviceId,
          ip: ip,
          name: name,
        );
        _api.updateConfig(ip, token);
        _isPaired = true;
        _deviceName = name;
        notifyListeners();
      } else {
        throw Exception(response['error'] ?? 'Pairing failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unpair() async {
    await _storage.clear();
    _isPaired = false;
    _deviceName = null;
    notifyListeners();
  }
}
