import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cat_tinder/data/datasources/app_preferences.dart';
import 'package:cat_tinder/domain/repositories/auth_repository.dart';
import 'package:cat_tinder/domain/validators/auth_validator.dart';
import 'package:cat_tinder/core/analytics/analytics_service.dart';
import 'package:cat_tinder/presentation/app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAppPreferences extends Mock implements AppPreferences {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  final sl = GetIt.instance;

  setUp(() {
    sl.reset();
    final mockPrefs = MockAppPreferences();
    final mockAuth = MockAuthRepository();

    when(() => mockPrefs.isOnboardingCompleted).thenReturn(false);
    when(() => mockAuth.isLoggedIn()).thenAnswer((_) async => false);

    sl.registerLazySingleton<AppPreferences>(() => mockPrefs);
    sl.registerLazySingleton<AuthRepository>(() => mockAuth);
    sl.registerLazySingleton<AuthValidator>(() => AuthValidator());
    sl.registerLazySingleton<AnalyticsService>(() => MockAnalyticsService());
  });

  tearDown(() {
    sl.reset();
  });

  testWidgets('App smoke test — renders MaterialApp', (tester) async {
    await tester.pumpWidget(const CatTinderApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
