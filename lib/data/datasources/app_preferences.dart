import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final SharedPreferences _prefs;

  static const _onboardingKey = 'onboarding_completed';
  static const _likeCountKey = 'like_count';

  AppPreferences(this._prefs);

  bool get isOnboardingCompleted => _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  int get likeCount => _prefs.getInt(_likeCountKey) ?? 0;

  Future<void> setLikeCount(int count) async {
    await _prefs.setInt(_likeCountKey, count);
  }
}
