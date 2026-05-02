import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CachedData {
  final String data;
  final DateTime timestamp;

  CachedData(this.data, this.timestamp);

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

class CacheService {
  static const _ttlMinutes = 5;
  static const Duration _ttl = Duration(minutes: _ttlMinutes);
  static CacheService? _instance;
  late SharedPreferences _prefs;

  CacheService._internal();

  static Future<CacheService> getInstance() async {
    if (_instance == null) {
      _instance = CacheService._internal();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> set(String key, dynamic data) async {
    final jsonString = jsonEncode(data);
    await _prefs.setString(key, jsonString);
    await _prefs.setString(
        '${key}_timestamp', DateTime.now().toIso8601String());
  }

  Future<dynamic> get(String key) async {
    final jsonString = _prefs.getString(key);
    final timestampString = _prefs.getString('${key}_timestamp');
    if (jsonString == null || timestampString == null) return null;

    final timestamp = DateTime.parse(timestampString);
    if (DateTime.now().difference(timestamp) > _ttl) return null;

    return jsonDecode(jsonString);
  }

  Future<void> clear(String key) async {
    await _prefs.remove(key);
    await _prefs.remove('${key}_timestamp');
  }

  Future<void> clearAll() async {
    final keys =
        _prefs.getKeys().where((k) => !k.contains('_timestamp')).toList();
    for (var key in keys) {
      await clear(key);
    }
  }

  bool isCached(String key) {
    return _prefs.containsKey(key) && _prefs.containsKey('${key}_timestamp');
  }

  DateTime? getCacheTimestamp(String key) {
    final ts = _prefs.getString('${key}_timestamp');
    return ts != null ? DateTime.parse(ts) : null;
  }
}
