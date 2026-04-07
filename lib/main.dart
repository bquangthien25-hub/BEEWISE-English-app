import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'core/constants/app_strings.dart';
import 'core/dependency_injection/injection_container.dart';
import 'data/datasources/local_user_data_source.dart';
import 'data/models/user_model.dart';
import 'domain/repositories/gamification_repository.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/league/league_bloc.dart';
import 'presentation/bloc/lesson_bloc.dart';
import 'presentation/bloc/mission/mission_bloc.dart';
import 'presentation/bloc/mission/mission_event.dart';
import 'presentation/bloc/league/league_event.dart';
import 'presentation/bloc/theme/theme_bloc.dart';
import 'presentation/bloc/theme/theme_event.dart';
import 'presentation/bloc/theme/theme_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }
  await initDependencies();

  // Listen to Firebase auth state and initialize/clear gamification session
  final firebaseAuth = fb.FirebaseAuth.instance;
  final gamification = sl<GamificationRepository>();
  final local = sl<LocalUserDataSource>();

firebaseAuth.authStateChanges().listen((fb.User? user) async {
  if (user == null) {
    gamification.clearSession();
    return;
  }

  try {
    // Thêm dòng print này để debug xem uid có chuẩn không
    print("User logged in: ${user.uid}");

    var model = await local.getUser(user.uid);
    if (model == null) {
      // Dữ liệu trống (có thể do xóa cache). Cố gắng tải lại từ Firestore.
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          model = UserModel.fromJson(doc.data()!..['id'] = doc.id);
        }
      } catch (e) {
        print("Lỗi khi fetch từ Firestore: $e");
      }

      // Nếu vẫn null sau khi fetch Firestore (chưa từng lưu), khởi tạo profile mới.
      model ??= UserModel(
          id: user.uid, 
          email: user.email ?? '', 
          name: user.displayName ?? 'BeeWise User'
        );
      // Lưu lại bản sao xuống cache ngay lập tức.
      await local.saveUser(model);
    }

    await gamification.initializeSession(model.toEntity());
  } catch (e) {
    print("Lỗi xử lý User Profile: $e");
  }
});

  final authBloc = sl<AuthBloc>();
  final lessonBloc = sl<LessonBloc>();
  final themeBloc = sl<ThemeBloc>();
  final missionBloc = sl<MissionBloc>();
  final leagueBloc = sl<LeagueBloc>();

  themeBloc.add(const ThemeLoadRequested());

  runApp(
    BeeWiseApp(
      authBloc: authBloc,
      lessonBloc: lessonBloc,
      themeBloc: themeBloc,
      missionBloc: missionBloc,
      leagueBloc: leagueBloc,
    ),
  );
}

class BeeWiseApp extends StatelessWidget {
  const BeeWiseApp({
    super.key,
    required this.authBloc,
    required this.lessonBloc,
    required this.themeBloc,
    required this.missionBloc,
    required this.leagueBloc,
  });

  final AuthBloc authBloc;
  final LessonBloc lessonBloc;
  final ThemeBloc themeBloc;
  final MissionBloc missionBloc;
  final LeagueBloc leagueBloc;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<LessonBloc>.value(value: lessonBloc),
        BlocProvider<ThemeBloc>.value(value: themeBloc),
        BlocProvider<MissionBloc>.value(value: missionBloc),
        BlocProvider<LeagueBloc>.value(value: leagueBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) => 
            (c is AuthAuthenticated && p is! AuthAuthenticated) ||
            (c is AuthInitial && p is! AuthInitial),
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.read<MissionBloc>().add(const MissionLoadRequested());
            context.read<LessonBloc>().add(const LessonLoadRequested());
            context.read<LeagueBloc>().add(const LeagueLoadRequested());
          } else if (state is AuthInitial) {
            fb.FirebaseAuth.instance.signOut();
          }
        },
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            final mode = themeState is ThemeReady ? themeState.mode : ThemeMode.dark;
            return MaterialApp.router(
              title: AppStrings.appName,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: mode,
              locale: const Locale('vi', 'VN'),
              supportedLocales: const [
                Locale('vi', 'VN'),
                Locale('en', 'US'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: createAppRouter(authBloc),
            );
          },
        ),
      ),
    );
  }
}
