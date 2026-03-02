import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/cat_api_datasource.dart';
import '../../data/datasources/app_preferences.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/cat_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/cat_repository.dart';
import '../../domain/validators/auth_validator.dart';
import '../analytics/analytics_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();

  sl.registerLazySingleton(() => AppPreferences(prefs));

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: secureStorage,
      prefs: prefs,
    ),
  );
  sl.registerLazySingleton(() => CatApiDataSource());

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthLocalDataSource>()),
  );
  sl.registerLazySingleton<CatRepository>(
    () => CatRepositoryImpl(sl<CatApiDataSource>()),
  );

  sl.registerLazySingleton(() => AuthValidator());

  sl.registerLazySingleton<AnalyticsService>(() => ConsoleAnalyticsService());
}
