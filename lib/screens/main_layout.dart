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
import '../utils/routes.dart';
import '../utils/session_helper.dart';
import 'home/home_page.dart';
import 'equipment/equipment_list_page.dart';
import 'transaction/transaction_list_page.dart';
import 'user/user_tab_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
    // Reload API setiap pindah tab supaya data selalu fresh
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
          onNavigate: _onTabTapped,
        );
      case 1:
        return TransactionListPage(transactionBloc: _transactionBloc);
      case 2:
        return EquipmentListPage(equipmentBloc: _equipmentBloc);
      case 3:
        return UserTabPage(studentBloc: _studentBloc);
      default:
        return HomePage(
          equipmentBloc: _equipmentBloc,
          transactionBloc: _transactionBloc,
          studentBloc: _studentBloc,
          onNavigate: _onTabTapped,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider<EquipmentListBloc>.value(value: _equipmentBloc),
        BlocProvider<TransactionListBloc>.value(value: _transactionBloc),
        BlocProvider<StudentListBloc>.value(value: _studentBloc),
      ],
      child: Scaffold(
        appBar: _buildAppBar(context, isDark),
        body: _buildPage(),
        bottomNavigationBar: _buildBottomNav(isDark),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final bgColor = isDark ? AppTheme.darkSurface : AppTheme.surface;
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);

    return PreferredSize(
      preferredSize: Size.fromHeight(isMobile ? 56 : 64),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(bottom: BorderSide(color: borderColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 8),
            child: Row(
              children: [
                // Logo
                Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/images/logo/LogoAlchemist.png',
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(width: 8),
                if (!isMobile) ...[
                  Text(
                    'Alchemist',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.darkText : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                // Search bar — lebih kecil di mobile
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context, Routes.search, arguments: ''),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurfaceVar : AppTheme.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, size: 15,
                            color: isDark ? AppTheme.darkTextSub : AppTheme.textMuted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isMobile ? 'Cari...' : 'Cari peralatan, mahasiswa...',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily, fontSize: 12,
                                color: isDark ? AppTheme.darkTextSub : AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _ProfileDropdown(isDark: isDark, showName: !isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onTabTapped,
      backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.surface,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: isDark ? AppTheme.darkTextSub : AppTheme.textMuted,
      selectedLabelStyle: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.swap_horiz_rounded), label: 'Transaksi'),
        BottomNavigationBarItem(icon: Icon(Icons.science_rounded), label: 'Peralatan'),
        BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'User'),
      ],
    );
  }
}

// ─── Profile Dropdown ──────────────────────────────────────────────────────
class _ProfileDropdown extends StatelessWidget {
  final bool isDark;
  final bool showName;
  const _ProfileDropdown({required this.isDark, this.showName = true});

  @override
  Widget build(BuildContext context) {
    final name = SessionHelper.currentName;
    final role = SessionHelper.currentRole;
    final isAdmin = SessionHelper.isAdmin;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return PopupMenuButton<String>(
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppTheme.darkSurface : AppTheme.surface,
      onSelected: (value) => _onMenuSelected(context, value),
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primary,
              child: Text(initial,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: TextStyle(fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w600, fontSize: 14,
                color: isDark ? AppTheme.darkText : AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isAdmin ? AppTheme.primary : AppTheme.success,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(role, style: const TextStyle(color: Colors.white,
                  fontSize: 10, fontWeight: FontWeight.w600, fontFamily: AppTheme.fontFamily)),
              ),
            ]),
          ]),
        ),
        const PopupMenuDivider(),
        _menuItem('edit_profile', Icons.person_rounded, 'Edit Profile', isDark),
        _menuItem('theme', Icons.dark_mode_rounded, 'Ubah Tema', isDark),
        _menuItem('notif', Icons.notifications_rounded, 'Notifikasi', isDark),
        _menuItem('about', Icons.info_rounded, 'Tentang App', isDark),
        const PopupMenuDivider(),
        _menuItem('logout', Icons.logout_rounded, 'Keluar', isDark, isDestructive: true),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primary,
            child: Text(initial,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          if (showName) ...[
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkText : AppTheme.textPrimary)),
            ),
          ],
          const SizedBox(width: 2),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16,
            color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label, bool isDark,
      {bool isDestructive = false}) {
    final color = isDestructive ? AppTheme.error : (isDark ? AppTheme.darkText : AppTheme.textPrimary);
    return PopupMenuItem<String>(
      value: value,
      child: Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: color)),
      ]),
    );
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'edit_profile':
      case 'theme':
      case 'notif':
      case 'about':
        Navigator.pushNamed(context, Routes.settings, arguments: value);
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Keluar',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
        content: const Text('Apakah kamu yakin ingin keluar?',
          style: TextStyle(fontFamily: AppTheme.fontFamily)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              SessionHelper.clearSession();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, Routes.splash, (r) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}