class AuthValidator {
  static const int minPasswordLength = 6;

  String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email обязателен';
    }
    final regex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(email.trim())) {
      return 'Некорректный формат email';
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Пароль обязателен';
    }
    if (password.length < minPasswordLength) {
      return 'Минимум $minPasswordLength символов';
    }
    return null;
  }

  String? validateConfirmPassword(String? password, String? confirmPassword) {
    final error = validatePassword(confirmPassword);
    if (error != null) return error;
    if (password != confirmPassword) {
      return 'Пароли не совпадают';
    }
    return null;
  }
}
