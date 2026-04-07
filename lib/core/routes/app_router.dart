import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../dependency_injection/injection_container.dart';
import '../../presentation/bloc/auth_bloc.dart';
import '../../presentation/bloc/lesson_quiz/lesson_quiz_bloc.dart';
import '../../presentation/bloc/lesson_quiz/lesson_quiz_event.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/forgot_password_page.dart';
import '../../presentation/pages/home/learning_path_page.dart';
import '../../presentation/pages/home/missions_page.dart';
import '../../presentation/pages/home/profile_page.dart';
import '../../presentation/pages/leaderboard/leaderboard_page.dart';
import '../../presentation/pages/lesson/lesson_quiz_page.dart';
import '../../presentation/pages/ai/support_chat_page.dart';
import '../../presentation/pages/shop/shop_page.dart';
import '../../presentation/pages/shell/bewise_shell.dart';
import '../../presentation/pages/admin/admin_dashboard_page.dart';
import '../../presentation/pages/admin/admin_chat_list_page.dart';
import '../../presentation/pages/admin/admin_chat_detail_page.dart';
import 'go_router_refresh.dart';

GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final loc = state.matchedLocation;
      final atAuth = loc == '/login' || loc == '/register' || loc == '/forgot-password';
      final isAuthed = authState is AuthAuthenticated;

      if (!isAuthed && !atAuth) {
        return '/login';
      }
      if (isAuthed && atAuth) {
        return '/home';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
          return BeeWiseShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                builder: (context, state) => const LearningPathPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/missions',
                builder: (context, state) => const MissionsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/league',
                builder: (context, state) => const LeaderboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/shop',
                builder: (context, state) => const ShopPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return BlocProvider(
            create: (_) => sl<LessonQuizBloc>()..add(LessonQuizLoadRequested(id)),
            child: LessonQuizPage(lessonId: id),
          );
        },
      ),
      GoRoute(
        path: '/support-chat',
        builder: (context, state) => const SupportChatPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/chats',
        builder: (context, state) => const AdminChatListPage(),
      ),
      GoRoute(
        path: '/admin/chats/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final name = state.extra as String? ?? 'Người dùng';
          return AdminChatDetailPage(userId: id, userName: name);
        },
      ),
    ],
  );
}
