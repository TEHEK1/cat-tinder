import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cat_tinder/data/datasources/auth_local_datasource.dart';
import 'package:cat_tinder/data/repositories/auth_repository_impl.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

String _hash(String password) {
  return sha256.convert(utf8.encode(password)).toString();
}

void main() {
  late MockAuthLocalDataSource mockDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  group('register', () {
    const email = 'test@example.com';
    const password = 'secret123';

    test('returns true and saves user when user does not exist', () async {
      when(() => mockDataSource.hasUser(email))
          .thenAnswer((_) async => false);
      when(() => mockDataSource.saveUser(email, any()))
          .thenAnswer((_) async {});
      when(() => mockDataSource.saveSession(email))
          .thenAnswer((_) async {});

      final result = await repository.register(email, password);

      expect(result, isTrue);
      verify(() => mockDataSource.saveUser(email, _hash(password))).called(1);
      verify(() => mockDataSource.saveSession(email)).called(1);
    });

    test('returns false when user already exists', () async {
      when(() => mockDataSource.hasUser(email))
          .thenAnswer((_) async => true);

      final result = await repository.register(email, password);

      expect(result, isFalse);
      verifyNever(() => mockDataSource.saveUser(any(), any()));
    });
  });

  group('login', () {
    const email = 'test@example.com';
    const password = 'secret123';
    final hashed = _hash(password);

    test('returns true when credentials are correct', () async {
      when(() => mockDataSource.getHashedPassword(email))
          .thenAnswer((_) async => hashed);
      when(() => mockDataSource.saveSession(email))
          .thenAnswer((_) async {});

      final result = await repository.login(email, password);

      expect(result, isTrue);
      verify(() => mockDataSource.saveSession(email)).called(1);
    });

    test('returns false when user does not exist', () async {
      when(() => mockDataSource.getHashedPassword(email))
          .thenAnswer((_) async => null);

      final result = await repository.login(email, password);

      expect(result, isFalse);
    });

    test('returns false when password is wrong', () async {
      when(() => mockDataSource.getHashedPassword(email))
          .thenAnswer((_) async => _hash('wrongpassword'));

      final result = await repository.login(email, password);

      expect(result, isFalse);
    });
  });

  group('logout', () {
    test('clears session', () async {
      when(() => mockDataSource.clearSession()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockDataSource.clearSession()).called(1);
    });
  });

  group('isLoggedIn', () {
    test('returns true when session exists', () async {
      when(() => mockDataSource.hasSession()).thenAnswer((_) async => true);

      expect(await repository.isLoggedIn(), isTrue);
    });

    test('returns false when no session', () async {
      when(() => mockDataSource.hasSession()).thenAnswer((_) async => false);

      expect(await repository.isLoggedIn(), isFalse);
    });
  });
}
