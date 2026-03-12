// lib/screens/main_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/equipment/equipment_list_bloc.dart';
import '../blocs/transaction/transaction_list_bloc.dart';
import '../blocs/student/student_list_bloc.dart';
import '../repositories/equipment_repository.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/student_repository.dart';
import '../utils/remote_helper.dart';
import '../utils/app_theme.dart';
import '../utils/session_helper.dart';
import '../widgets/app_sidebar.dart';
import 'home/home_page.dart';
import 'equipment/equipment_list_page.dart';
import 'transaction/transaction_list_page.dart';
import 'student/student_list_page.dart';
import 'category/category_list_page.dart';
import 'condition_log/condition_log_list_page.dart';
import 'user/user_list_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool _sidebarVisible = true;

  final EquipmentListBloc _equipmentBloc = EquipmentListBloc(
    equipmentRepository: EquipmentRepository(RemoteHelper.getDio()),
  );
  final TransactionListBloc _transactionBloc = TransactionListBloc(
    transactionRepository: TransactionRepository(RemoteHelper.getDio()),
  );
  final StudentListBloc _studentBloc = StudentListBloc(
    studentRepository: StudentRepository(RemoteHelper.getDio()),
  );

  @override
  void initState() {
    super.initState();
    _equipmentBloc.add(LoadEquipmentListEvent());
    _transactionBloc.add(LoadTransactionListEvent());
    _studentBloc.add(LoadStudentListEvent());
  }

  @override
  void dispose() {
    _equipmentBloc.close();
    _transactionBloc.close();
    _studentBloc.close();
    super.dispose();
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return HomePage(
          equipmentBloc: _equipmentBloc,
          transactionBloc: _transactionBloc,
          studentBloc: _studentBloc,
          onNavigate: (index) => setState(() => _selectedIndex = index),
        );
      case 1: return TransactionListPage(transactionBloc: _transactionBloc);
      case 2: return EquipmentListPage(equipmentBloc: _equipmentBloc);
      case 3: return const ConditionLogListPage();
      case 4: return StudentListPage(studentBloc: _studentBloc);
      case 5: return const CategoryListPage();
      case 6: return const UserListPage();
      default:
        return HomePage(
          equipmentBloc: _equipmentBloc,
          transactionBloc: _transactionBloc,
          studentBloc: _studentBloc,
          onNavigate: (index) => setState(() => _selectedIndex = index),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EquipmentListBloc>.value(value: _equipmentBloc),
        BlocProvider<TransactionListBloc>.value(value: _transactionBloc),
        BlocProvider<StudentListBloc>.value(value: _studentBloc),
      ],
      child: Scaffold(
        body: Row(
          children: [
            // Sidebar dengan animasi hide/show
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: _sidebarVisible ? 240 : 0,
              child: _sidebarVisible
                  ? AppSidebar(
                      selectedIndex: _selectedIndex,
                      onItemSelected: (index) => setState(() => _selectedIndex = index),
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(child: _buildPage()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final titles = [
      'Dashboard', 'Transaksi', 'Peralatan Lab',
      'Kondisi Alat', 'Mahasiswa', 'Kategori', 'User Management'
    ];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          // Toggle sidebar button
          GestureDetector(
            onTap: () => setState(() => _sidebarVisible = !_sidebarVisible),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _sidebarVisible ? Icons.menu_open_rounded : Icons.menu_rounded,
                size: 20,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            titles[_selectedIndex.clamp(0, titles.length - 1)],
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          // Profile chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    SessionHelper.currentName.isNotEmpty
                        ? SessionHelper.currentName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  SessionHelper.currentName,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: SessionHelper.isAdmin ? AppTheme.primary : AppTheme.success,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    SessionHelper.currentRole,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}