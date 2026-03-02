import 'package:flutter_test/flutter_test.dart';
import 'package:cat_tinder/domain/validators/auth_validator.dart';

void main() {
  late AuthValidator validator;

  setUp(() {
    validator = AuthValidator();
  });

  group('validateEmail', () {
    test('returns error when email is null', () {
      expect(validator.validateEmail(null), 'Email обязателен');
    });

    test('returns error when email is empty', () {
      expect(validator.validateEmail(''), 'Email обязателен');
    });

    test('returns error when email is whitespace only', () {
      expect(validator.validateEmail('   '), 'Email обязателен');
    });

    test('returns error for invalid email format', () {
      expect(validator.validateEmail('notanemail'), 'Некорректный формат email');
      expect(validator.validateEmail('missing@'), 'Некорректный формат email');
      expect(validator.validateEmail('@nodomain'), 'Некорректный формат email');
      expect(validator.validateEmail('no spaces@mail.com'), 'Некорректный формат email');
    });

    test('returns null for valid email', () {
      expect(validator.validateEmail('test@example.com'), isNull);
      expect(validator.validateEmail('user.name@domain.org'), isNull);
      expect(validator.validateEmail('a@b.co'), isNull);
    });
  });

  group('validatePassword', () {
    test('returns error when password is null', () {
      expect(validator.validatePassword(null), 'Пароль обязателен');
    });

    test('returns error when password is empty', () {
      expect(validator.validatePassword(''), 'Пароль обязателен');
    });

    test('returns error when password is too short', () {
      expect(
        validator.validatePassword('12345'),
        'Минимум ${AuthValidator.minPasswordLength} символов',
      );
    });

    test('returns null for valid password', () {
      expect(validator.validatePassword('123456'), isNull);
      expect(validator.validatePassword('securepassword'), isNull);
    });
  });

  group('validateConfirmPassword', () {
    test('returns error when passwords do not match', () {
      expect(
        validator.validateConfirmPassword('password1', 'password2'),
        'Пароли не совпадают',
      );
    });

    test('returns password validation error if confirm is invalid', () {
      expect(
        validator.validateConfirmPassword('password1', ''),
        'Пароль обязателен',
      );
    });

    test('returns null when passwords match', () {
      expect(
        validator.validateConfirmPassword('mypassword', 'mypassword'),
        isNull,
      );
    });
  });
}
