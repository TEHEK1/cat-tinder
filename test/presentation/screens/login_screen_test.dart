import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cat_tinder/domain/repositories/auth_repository.dart';
import 'package:cat_tinder/domain/validators/auth_validator.dart';
import 'package:cat_tinder/core/analytics/analytics_service.dart';
import 'package:cat_tinder/presentation/screens/login_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockAnalyticsService mockAnalytics;
  final sl = GetIt.instance;

  setUp(() {
    sl.reset();
    mockAuthRepo = MockAuthRepository();
    mockAnalytics = MockAnalyticsService();

    sl.registerLazySingleton<AuthRepository>(() => mockAuthRepo);
    sl.registerLazySingleton<AuthValidator>(() => AuthValidator());
    sl.registerLazySingleton<AnalyticsService>(() => mockAnalytics);
  });

  tearDown(() {
    sl.reset();
  });

  Widget buildApp({required VoidCallback onLoginSuccess}) {
    return MaterialApp(
      home: LoginScreen(onLoginSuccess: onLoginSuccess),
    );
  }

  testWidgets('shows validation errors on empty submit', (tester) async {
    bool called = false;
    await tester.pumpWidget(buildApp(onLoginSuccess: () => called = true));

    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(find.text('Email обязателен'), findsOneWidget);
    expect(find.text('Пароль обязателен'), findsOneWidget);
    expect(called, isFalse);
  });

  testWidgets('shows email validation error for invalid format', (tester) async {
    await tester.pumpWidget(buildApp(onLoginSuccess: () {}));

    await tester.enterText(find.byType(TextFormField).first, 'bademail');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(find.text('Некорректный формат email'), findsOneWidget);
  });

  testWidgets('calls login and triggers success callback', (tester) async {
    when(() => mockAuthRepo.login('test@mail.com', 'password123'))
        .thenAnswer((_) async => true);
    when(() => mockAnalytics.logLogin(success: true)).thenReturn(null);

    bool loginSuccess = false;
    await tester.pumpWidget(
      buildApp(onLoginSuccess: () => loginSuccess = true),
    );

    await tester.enterText(find.byType(TextFormField).first, 'test@mail.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(loginSuccess, isTrue);
    verify(() => mockAuthRepo.login('test@mail.com', 'password123')).called(1);
  });

  testWidgets('shows snackbar on failed login', (tester) async {
    when(() => mockAuthRepo.login('test@mail.com', 'wrongpass'))
        .thenAnswer((_) async => false);
    when(() => mockAnalytics.logLogin(
      success: false,
      error: 'invalid_credentials',
    )).thenReturn(null);

    await tester.pumpWidget(buildApp(onLoginSuccess: () {}));

    await tester.enterText(find.byType(TextFormField).first, 'test@mail.com');
    await tester.enterText(find.byType(TextFormField).last, 'wrongpass');
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(find.text('Неверный email или пароль'), findsOneWidget);
  });
}
