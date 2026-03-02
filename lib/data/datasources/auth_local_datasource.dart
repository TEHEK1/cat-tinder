import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(String email, String hashedPassword);
  Future<String?> getHashedPassword(String email);
  Future<bool> hasUser(String email);
  Future<void> saveSession(String email);
  Future<void> clearSession();
  Future<bool> hasSession();
  Future<String?> getSessionEmail();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  static const _sessionKey = 'auth_session_email';
  static const _usersPrefix = 'user_';

  AuthLocalDataSourceImpl({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  @override
  Future<void> saveUser(String email, String hashedPassword) async {
    await _secureStorage.write(
      key: '$_usersPrefix${email.toLowerCase()}',
      value: hashedPassword,
    );
  }

  @override
  Future<String?> getHashedPassword(String email) async {
    return _secureStorage.read(
      key: '$_usersPrefix${email.toLowerCase()}',
    );
  }

  @override
  Future<bool> hasUser(String email) async {
    final password = await getHashedPassword(email);
    return password != null;
  }

  @override
  Future<void> saveSession(String email) async {
    await _prefs.setString(_sessionKey, email.toLowerCase());
  }

  @override
  Future<void> clearSession() async {
    await _prefs.remove(_sessionKey);
  }

  @override
  Future<bool> hasSession() async {
    return _prefs.containsKey(_sessionKey);
  }

  @override
  Future<String?> getSessionEmail() async {
    return _prefs.getString(_sessionKey);
  }
}
