import 'package:flutter/foundation.dart';

abstract class AnalyticsService {
  void logEvent(String name, [Map<String, dynamic>? params]);
  void logLogin({required bool success, String? error});
  void logRegister({required bool success, String? error});
  void logOnboardingComplete();
}

class ConsoleAnalyticsService implements AnalyticsService {
  @override
  void logEvent(String name, [Map<String, dynamic>? params]) {
    debugPrint('[Analytics] $name${params != null ? ': $params' : ''}');
  }

  @override
  void logLogin({required bool success, String? error}) {
    logEvent('login', {
      'success': success,
      if (error != null) 'error': error,
    });
  }

  @override
  void logRegister({required bool success, String? error}) {
    logEvent('register', {
      'success': success,
      if (error != null) 'error': error,
    });
  }

  @override
  void logOnboardingComplete() {
    logEvent('onboarding_complete');
  }
}
