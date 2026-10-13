import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/history/presentation/pages/history_analytics_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/stopwatch/presentation/pages/stopwatch_page.dart';
import 'scaffold_with_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Branch 1: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        // Branch 2: History & Analytics
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryAnalyticsPage(),
            ),
          ],
        ),
        // Branch 3: Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    // Detailed Stopwatch Page (Screen 2) - opened on root navigator
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/stopwatch',
      builder: (context, state) => const StopwatchPage(),
    ),
  ],
);
