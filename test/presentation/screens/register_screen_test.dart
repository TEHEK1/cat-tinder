import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cat_tinder/domain/repositories/auth_repository.dart';
import 'package:cat_tinder/domain/validators/auth_validator.dart';
import 'package:cat_tinder/core/analytics/analytics_service.dart';
import 'package:cat_tinder/presentation/screens/register_screen.dart';

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

  Widget buildApp({required VoidCallback onRegisterSuccess}) {
    return MaterialApp(
      home: RegisterScreen(onRegisterSuccess: onRegisterSuccess),
    );
  }

  testWidgets('shows validation errors on empty submit', (tester) async {
    await tester.pumpWidget(buildApp(onRegisterSuccess: () {}));

    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();

    expect(find.text('Email обязателен'), findsOneWidget);
    expect(find.text('Пароль обязателен'), findsAtLeast(1));
  });

  testWidgets('shows mismatch error when passwords differ', (tester) async {
    await tester.pumpWidget(buildApp(onRegisterSuccess: () {}));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'user@mail.com');
    await tester.enterText(fields.at(1), 'password1');
    await tester.enterText(fields.at(2), 'password2');
    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();

    expect(find.text('Пароли не совпадают'), findsOneWidget);
  });

  testWidgets('calls register and triggers success on valid input',
      (tester) async {
    when(() => mockAuthRepo.register('user@mail.com', 'password1'))
        .thenAnswer((_) async => true);
    when(() => mockAnalytics.logRegister(success: true)).thenReturn(null);

    bool registerSuccess = false;
    await tester.pumpWidget(
      buildApp(onRegisterSuccess: () => registerSuccess = true),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'user@mail.com');
    await tester.enterText(fields.at(1), 'password1');
    await tester.enterText(fields.at(2), 'password1');
    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();

    expect(registerSuccess, isTrue);
    verify(() => mockAuthRepo.register('user@mail.com', 'password1'))
        .called(1);
  });

  testWidgets('shows snackbar when user already exists', (tester) async {
    when(() => mockAuthRepo.register('user@mail.com', 'password1'))
        .thenAnswer((_) async => false);
    when(() => mockAnalytics.logRegister(
      success: false,
      error: 'user_exists',
    )).thenReturn(null);

    await tester.pumpWidget(buildApp(onRegisterSuccess: () {}));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'user@mail.com');
    await tester.enterText(fields.at(1), 'password1');
    await tester.enterText(fields.at(2), 'password1');
    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();

    expect(
      find.text('Пользователь с таким email уже существует'),
      findsOneWidget,
    );
  });
}
