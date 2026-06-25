import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vsign_mobile_app/features/navigation_shell.dart';
import 'package:vsign_mobile_app/features/auth/presentation/login_screen.dart';
import 'package:vsign_mobile_app/features/auth/presentation/register_screen.dart';
import 'package:vsign_mobile_app/features/auth/presentation/profile_screen.dart';
import 'package:vsign_mobile_app/features/course/presentation/courses_screen.dart';
import 'package:vsign_mobile_app/features/course/presentation/lesson_detail_screen.dart';
import 'package:vsign_mobile_app/features/dictionary/presentation/dictionary_screen.dart';
import 'package:vsign_mobile_app/features/gamification/presentation/leaderboard_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash', // Start from splash screen to check auto login
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    
    // Main Navigation Shell containing BottomNavigationBar
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainNavigationShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/courses',
          builder: (context, state) => const CoursesScreen(),
        ),
        GoRoute(
          path: '/dictionary',
          builder: (context, state) => const DictionaryScreen(),
        ),
        GoRoute(
          path: '/leaderboard',
          builder: (context, state) => const LeaderboardScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    
    // Detail screens
    GoRoute(
      path: '/lesson/:lessonId',
      builder: (context, state) {
        final lessonId = state.pathParameters['lessonId'] ?? '';
        return LessonDetailScreen(lessonId: lessonId);
      },
    ),
  ],
);
