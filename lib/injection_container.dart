import 'package:get_it/get_it.dart';
import 'package:skillconnect/data/datasources/firebase_remote_datasource.dart';
import 'package:skillconnect/data/repositories/auth_repository_impl.dart';
import 'package:skillconnect/data/repositories/provider_repository_impl.dart';
import 'package:skillconnect/domain/repositories/auth_repository.dart';
import 'package:skillconnect/domain/repositories/provider_repository.dart';
import 'package:skillconnect/presentation/blocs/auth_bloc.dart';
import 'package:skillconnect/presentation/blocs/provider_bloc.dart';
import 'package:skillconnect/presentation/blocs/settings/settings_bloc.dart';
import 'package:skillconnect/domain/repositories/settings_repository.dart';
import 'package:skillconnect/data/repositories/settings_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
    // Chat Feature removed
  // Blocs
  sl.registerFactory(() => AuthBloc(repository: sl()));
  sl.registerFactory(() => ProviderBloc(repository: sl()));
  sl.registerFactory(() => SettingsBloc(settingsRepository: sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProviderRepository>(
    () => ProviderRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sharedPreferences: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<FirebaseRemoteDataSource>(
    () => FirebaseRemoteDataSourceImpl(),
  );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
