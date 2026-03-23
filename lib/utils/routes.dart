// lib/utils/routes.dart
import 'package:flutter/material.dart';
import '../screens/auth/login_page.dart';
import '../screens/main_layout.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/search/search_result_page.dart';
import '../screens/settings/settings_page.dart';
import '../screens/equipment/equipment_detail_page.dart';
import '../screens/transaction/transaction_detail_page.dart';
import '../screens/student/student_detail_page.dart';
import '../screens/category/category_list_page.dart';
import '../screens/condition_log/condition_log_list_page.dart';
import '../screens/user/user_list_page.dart';
import '../screens/student/student_list_page.dart';
import '../models/ui/equipment.dart';
import '../models/ui/transaction.dart';
import '../models/ui/student.dart';

class Routes {
  static const String login = '/login';
  static const String splash = '/';
  static const String main = '/main';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String equipmentDetail = '/equipment/detail';
  static const String transactionNew = '/transaction/new';
  static const String studentDetail = '/student/detail';
  static const String categoryList = '/category';
  static const String conditionLog = '/condition-log';
  static const String userList = '/user';
  static const String studentList = '/student';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginPage(),
    splash: (_) => const SplashScreen(),
    main: (_) => const MainLayout(),
    search: (_) => const SearchResultPage(),
    settings: (_) => const SettingsPage(),
    categoryList: (_) => const CategoryListPage(),
    conditionLog: (_) => const ConditionLogListPage(),
    userList: (_) => const UserListPage(),
    studentList: (_) => const StudentListPage(studentBloc: null),
  };

  // Untuk halaman yang butuh arguments
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.equipmentDetail:
        final eq = settings.arguments as Equipment?;
        return MaterialPageRoute(
          builder: (_) => EquipmentDetailPage(equipment: eq),
        );
      case Routes.transactionNew:
        return MaterialPageRoute(
          builder: (_) => const TransactionDetailPage(transaction: null),
        );
      case Routes.studentDetail:
        final s = settings.arguments as Student?;
        return MaterialPageRoute(builder: (_) => StudentDetailPage(student: s));
      case Routes.search:
        final query = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => SearchResultPage(initialQuery: query),
        );
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
