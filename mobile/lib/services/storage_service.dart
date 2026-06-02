import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyAuthToken = 'auth_token';
  static const String keyDeviceId = 'device_id';
  static const String keyPcIp = 'pc_ip';
  static const String keyIsPaired = 'is_paired';
  static const String keyDeviceName = 'device_name';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  String? get authToken => _prefs.getString(keyAuthToken);
  String? get deviceId => _prefs.getString(keyDeviceId);
  String? get pcIp => _prefs.getString(keyPcIp);
  bool get isPaired => _prefs.getBool(keyIsPaired) ?? false;
  String? get deviceName => _prefs.getString(keyDeviceName);

  Future<void> savePairingData({
    required String token,
    required String deviceId,
    required String ip,
    required String name,
  }) async {
    await _prefs.setString(keyAuthToken, token);
    await _prefs.setString(keyDeviceId, deviceId);
    await _prefs.setString(keyPcIp, ip);
    await _prefs.setString(keyDeviceName, name);
    await _prefs.setBool(keyIsPaired, true);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
