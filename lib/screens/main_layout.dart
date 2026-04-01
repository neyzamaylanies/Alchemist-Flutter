import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';

import '../blocs/equipment/equipment_list_bloc.dart';
import '../blocs/transaction/transaction_list_bloc.dart';
import '../blocs/student/student_list_bloc.dart';

import '../repositories/equipment_repository.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/student_repository.dart';

import '../utils/remote_helper.dart';
import '../utils/app_theme.dart';
import '../utils/session_helper.dart';
// import '../utils/theme_provider.dart';
// import '../utils/routes.dart';

class MainLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late final EquipmentListBloc _equipmentBloc;
  late final TransactionListBloc _transactionBloc;
  late final StudentListBloc _studentBloc;

  @override
  void initState() {
    super.initState();
    _equipmentBloc = EquipmentListBloc(
      equipmentRepository: EquipmentRepository(RemoteHelper.getDio()),
    )..add(LoadEquipmentListEvent());

    _transactionBloc = TransactionListBloc(
      transactionRepository: TransactionRepository(RemoteHelper.getDio()),
    )..add(LoadTransactionListEvent());

    _studentBloc = StudentListBloc(
      studentRepository: StudentRepository(RemoteHelper.getDio()),
    )..add(LoadStudentListEvent());
  }

  @override
  void dispose() {
    _equipmentBloc.close();
    _transactionBloc.close();
    _studentBloc.close();
    super.dispose();
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(index);
    // Reload data fresh setiap pindah tab (fitur dari branch main)
    switch (index) {
      case 0:
        _equipmentBloc.add(LoadEquipmentListEvent());
        _transactionBloc.add(LoadTransactionListEvent());
        _studentBloc.add(LoadStudentListEvent());
        break;
      case 1:
        _transactionBloc.add(LoadTransactionListEvent());
        break;
      case 2:
        _equipmentBloc.add(LoadEquipmentListEvent());
        break;
      case 3:
        _studentBloc.add(LoadStudentListEvent());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _equipmentBloc),
        BlocProvider.value(value: _transactionBloc),
        BlocProvider.value(value: _studentBloc),
      ],
      child: Scaffold(
        appBar: _buildAppBar(context, isDark, isMobile),
        body: widget.navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: _onTap,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: isDark ? AppTheme.darkTextSub : Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz_rounded),
              label: 'Transaksi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.science_rounded),
              label: 'Peralatan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              label: 'User',
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDark,
    bool isMobile,
  ) {
    return PreferredSize(
      preferredSize: Size.fromHeight(isMobile ? 56 : 64),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.surface,
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logo/LogoAlchemist.png',
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 8),
                if (!isMobile)
                  Text(
                    'Alchemist',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkText : AppTheme.textPrimary,
                    ),
                  ),
                const SizedBox(width: 12),
                // Search Bar (Fitur branch main)
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSurfaceVar
                            : AppTheme.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.darkBorder
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 16,
                            color: isDark ? AppTheme.darkTextSub : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Cari...',
                            style: TextStyle(
                              color: isDark
                                  ? AppTheme.darkTextSub
                                  : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _ProfileDropdown(isDark: isDark, showName: !isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileDropdown extends StatelessWidget {
  final bool isDark;
  final bool showName;
  const _ProfileDropdown({required this.isDark, required this.showName});

  @override
  Widget build(BuildContext context) {
    final name = SessionHelper.currentName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'logout') {
          SessionHelper.clearSession();
          context.go('/login');
        } else {
          // Navigasi ke settings dengan argument tab spesifik (fitur main)
          context.push('/settings', extra: value);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'profile', child: Text('Edit Profile')),
        const PopupMenuItem(value: 'theme', child: Text('Ubah Tema')),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Text('Keluar', style: TextStyle(color: Colors.red)),
        ),
      ],
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primary,
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          if (showName) ...[
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.darkText : AppTheme.textPrimary,
              ),
            ),
          ],
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}
