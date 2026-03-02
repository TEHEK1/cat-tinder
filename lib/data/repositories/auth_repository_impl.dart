import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  @override
  Future<bool> register(String email, String password) async {
    final exists = await _dataSource.hasUser(email);
    if (exists) return false;

    final hashed = _hashPassword(password);
    await _dataSource.saveUser(email, hashed);
    await _dataSource.saveSession(email);
    return true;
  }

  @override
  Future<bool> login(String email, String password) async {
    final storedHash = await _dataSource.getHashedPassword(email);
    if (storedHash == null) return false;

    final inputHash = _hashPassword(password);
    if (storedHash != inputHash) return false;

    await _dataSource.saveSession(email);
    return true;
  }

  @override
  Future<void> logout() async {
    await _dataSource.clearSession();
  }

  @override
  Future<bool> isLoggedIn() async {
    return _dataSource.hasSession();
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    return _dataSource.getSessionEmail();
  }
}
