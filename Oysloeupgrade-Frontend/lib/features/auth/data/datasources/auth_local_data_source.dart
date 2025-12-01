import 'package:hive/hive.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/auth_session_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheSession(AuthSessionModel session);
  Future<AuthSessionModel?> readSession();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({required Box<dynamic> box}) : _box = box;

  static const String _sessionKey = 'session';

  final Box<dynamic> _box;

  @override
  Future<void> cacheSession(AuthSessionModel session) async {
    try {
      await _box.put(_sessionKey, session.toJson());
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  Future<AuthSessionModel?> readSession() async {
    try {
      final dynamic raw = _box.get(_sessionKey);
      if (raw is Map) {
        final normalized = _normalizeMap(raw);
        return AuthSessionModel.fromJson(normalized);
      }
      return null;
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await _box.delete(_sessionKey);
    } catch (error) {
      throw CacheException(error.toString());
    }
  }
}

Map<String, dynamic> _normalizeMap(Map<dynamic, dynamic> source) {
  return source.map((dynamic key, dynamic value) {
    return MapEntry<String, dynamic>(
      key.toString(),
      _normalizeValue(value),
    );
  });
}

dynamic _normalizeValue(dynamic value) {
  if (value is Map) {
    return _normalizeMap(value.cast<dynamic, dynamic>());
  }
  if (value is List) {
    return value.map(_normalizeValue).toList();
  }
  return value;
}
