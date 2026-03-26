// lib/utils/routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import Screens
import '../screens/auth/login_page.dart';
import '../screens/main_layout.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/search/search_result_page.dart';
import '../screens/settings/settings_page.dart';
import '../screens/home/home_page.dart';
import '../screens/equipment/equipment_list_page.dart';
import '../screens/equipment/equipment_detail_page.dart';
import '../screens/transaction/transaction_list_page.dart';
import '../screens/transaction/transaction_detail_page.dart';
import '../screens/student/student_detail_page.dart';
import '../screens/student/student_list_page.dart';
import '../screens/category/category_list_page.dart';
import '../screens/condition_log/condition_log_list_page.dart';
import '../screens/user/user_list_page.dart';
import '../screens/user/user_tab_page.dart';

// Import Models
import '../models/ui/equipment.dart';
import '../models/ui/transaction.dart';
import '../models/ui/student.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // --- RUTE AWAL ---
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

      // --- BOTTOM NAVIGATION (StatefulShellRoute) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainLayout(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transaksi',
                builder: (context, state) => const TransactionListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/peralatan',
                builder: (context, state) => const EquipmentListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user',
                builder: (context, state) => const UserTabPage(),
              ),
            ],
          ),
        ],
      ),

      // --- RUTE STANDALONE ---
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchResultPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/category',
        builder: (context, state) => const CategoryListPage(),
      ),
      GoRoute(
        path: '/condition-log',
        builder: (context, state) => const ConditionLogListPage(),
      ),
      GoRoute(
        path: '/user-list',
        builder: (context, state) => const UserListPage(),
      ),
      GoRoute(
        path: '/student-list',
        builder: (context, state) => const StudentListPage(),
      ),

      // --- RUTE DETAIL ---
      GoRoute(
        path: '/detail/equipment',
        builder: (context, state) =>
            EquipmentDetailPage(equipment: state.extra as Equipment?),
      ),
      GoRoute(
        path: '/detail/transaction',
        builder: (context, state) =>
            TransactionDetailPage(transaction: state.extra as Transaction?),
      ),
      GoRoute(
        path: '/detail/student',
        builder: (context, state) =>
            StudentDetailPage(student: state.extra as Student?),
      ),
    ],
  );
}
