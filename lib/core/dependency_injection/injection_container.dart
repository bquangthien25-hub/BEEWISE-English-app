import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/firebase_auth_remote_data_source.dart';
import '../../data/datasources/local_user_data_source.dart';
import '../../data/datasources/league_remote_data_source.dart';
import '../../data/datasources/lesson_remote_data_source.dart';
import '../../data/datasources/local_lesson_data_source.dart';
import '../../data/datasources/local_league_data_source.dart';
import '../../data/datasources/theme_local_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/gamification_repository_impl.dart';
import '../../data/repositories/league_repository_impl.dart';
import '../../data/repositories/lesson_repository_impl.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../data/user_profile_store.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../../domain/repositories/league_repository.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../../domain/repositories/theme_repository.dart';
import '../../domain/usecases/get_lesson_by_id_usecase.dart';
import '../../domain/usecases/get_lessons_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../presentation/bloc/auth_bloc.dart';
import '../../presentation/bloc/league/league_bloc.dart';
import '../../presentation/bloc/lesson_bloc.dart';
import '../../presentation/bloc/lesson_quiz/lesson_quiz_bloc.dart';
import '../../presentation/bloc/mission/mission_bloc.dart';
import '../../presentation/bloc/theme/theme_bloc.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // External
  sl.registerLazySingleton(Connectivity.new);

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Theme (persisted)
  sl.registerLazySingleton(() => ThemeLocalDataSource(sl()));
  sl.registerLazySingleton<ThemeRepository>(() => ThemeRepositoryImpl(sl()));

  // Session / profile (XP, streak, completed lessons, missions)
  sl.registerLazySingleton(UserProfileStore.new);

  // Firebase instance
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Local database
  final dbPath = await getDatabasesPath();
  final dbFile = p.join(dbPath, 'beewise_user.db');
  final db = await openDatabase(
    dbFile,
    version: 2,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          data TEXT NOT NULL
        );
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS lessons (
          id TEXT PRIMARY KEY,
          data TEXT NOT NULL
        );
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS league (
          id TEXT PRIMARY KEY,
          data TEXT NOT NULL
        );
      ''');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS lessons (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS league (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL
          );
        ''');
      }
    },
  );
  sl.registerLazySingleton<Database>(() => db);

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => FirebaseAuthRemoteDataSourceImpl(auth: sl()),
  );
  sl.registerLazySingleton<LocalUserDataSource>(() => LocalUserDataSource(sl()));
  sl.registerLazySingleton<LocalLessonDataSource>(() => LocalLessonDataSource(sl()));
  sl.registerLazySingleton<LocalLeagueDataSource>(() => LocalLeagueDataSource(sl()));
  sl.registerLazySingleton<LessonRemoteDataSource>(LessonRemoteDataSourceImpl.new);
  sl.registerLazySingleton<LeagueRemoteDataSource>(LeagueRemoteDataSourceImpl.new);

  // Gamification repository (uses local storage)
  sl.registerLazySingleton<GamificationRepository>(
    () => GamificationRepositoryImpl(sl(), sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<LessonRepository>(
    () => LessonRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      profileStore: sl(),
    ),
  );
  sl.registerLazySingleton<LeagueRepository>(
    () => LeagueRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      profileStore: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetLessonsUseCase(sl()));
  sl.registerLazySingleton(() => GetLessonByIdUseCase(sl()));

  // BLoCs (singletons — provided ở root)
  sl.registerLazySingleton(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      forgotPasswordUseCase: sl(),
      gamificationRepository: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => LessonBloc(getLessonsUseCase: sl()),
  );
  sl.registerLazySingleton(
    () => ThemeBloc(themeRepository: sl()),
  );
  sl.registerLazySingleton(
    () => MissionBloc(
      gamificationRepository: sl(),
      authBloc: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => LeagueBloc(
      leagueRepository: sl(),
      profileStore: sl(),
    ),
  );

  sl.registerFactory(
    () => LessonQuizBloc(
      getLessonById: sl(),
      gamificationRepository: sl(),
      authBloc: sl(),
    ),
  );
}
