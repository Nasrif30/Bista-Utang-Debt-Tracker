import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static const String _deviceIdKey = 'device_id';
  static String? _deviceId;

  static Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString(_deviceIdKey);

    if (_deviceId == null) {
      _deviceId = await _generateDeviceId();
      await prefs.setString(_deviceIdKey, _deviceId!);
    }

    return _deviceId!;
  }

  static Future<String> _generateDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    
    try {
      if (await deviceInfo.androidInfo != null) {
        final androidInfo = await deviceInfo.androidInfo;
        return 'android_${androidInfo.id}_${const Uuid().v4()}';
      } else if (await deviceInfo.iosInfo != null) {
        final iosInfo = await deviceInfo.iosInfo;
        return 'ios_${iosInfo.identifierForVendor}_${const Uuid().v4()}';
      }
    } catch (e) {
      // Fallback to UUID if device info fails
    }
    
    return 'device_${const Uuid().v4()}';
  }

  static Future<void> resetDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
    _deviceId = null;
  }
}
