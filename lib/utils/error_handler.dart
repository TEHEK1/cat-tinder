import 'package:flutter/material.dart';

class ErrorHandler {
  static void showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Ошибка'),
          ],
        ),
        content: Text(
          _getUserFriendlyMessage(error),
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static String _getUserFriendlyMessage(String error) {
    if (error.contains('Network error') ||
        error.contains('SocketException') ||
        error.contains('Failed host lookup')) {
      return 'Проблема с подключением к интернету. Проверьте соединение и попробуйте снова.';
    } else if (error.contains('TimeoutException')) {
      return 'Превышено время ожидания. Попробуйте позже.';
    } else if (error.contains('401') || error.contains('403')) {
      return 'Ошибка авторизации API. Проверьте API ключ.';
    } else if (error.contains('404')) {
      return 'Данные не найдены.';
    } else if (error.contains('500') ||
        error.contains('502') ||
        error.contains('503')) {
      return 'Сервер временно недоступен. Попробуйте позже.';
    } else if (error.contains('No cats found')) {
      return 'Котики не найдены. Попробуйте еще раз.';
    }

    return 'Произошла ошибка: $error';
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
