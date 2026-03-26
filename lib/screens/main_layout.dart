// lib/screens/main_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Import Auth untuk Logout
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';

// Import BLoC sesuai aslinya
import '../blocs/equipment/equipment_list_bloc.dart';
import '../blocs/transaction/transaction_list_bloc.dart';
import '../blocs/student/student_list_bloc.dart';

// Import Repositories
import '../repositories/equipment_repository.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/student_repository.dart';

// Import Utils
import '../utils/remote_helper.dart';
import '../utils/app_theme.dart';
import '../utils/session_helper.dart';

class MainLayout extends StatefulWidget {
  // Ini jembatan dari routes.dart ke UI lu
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Inisialisasi BLoC seperti di file original lu
  late final EquipmentListBloc _equipmentBloc;
  late final TransactionListBloc _transactionBloc;
  late final StudentListBloc _studentBloc;

  @override
  void initState() {
    super.initState();
    _equipmentBloc = EquipmentListBloc(
      equipmentRepository: EquipmentRepository(RemoteHelper.getDio()),
    );
    _transactionBloc = TransactionListBloc(
      transactionRepository: TransactionRepository(RemoteHelper.getDio()),
    );
    _studentBloc = StudentListBloc(
      studentRepository: StudentRepository(RemoteHelper.getDio()),
    );

    // Buka komentar ini kalau Event-nya udah lu atur di BLoC lu
    // _equipmentBloc.add(LoadEquipmentListEvent());
    // _transactionBloc.add(LoadTransactionListEvent());
    // _studentBloc.add(LoadStudentListEvent());
  }

  @override
  void dispose() {
    _equipmentBloc.close();
    _transactionBloc.close();
    _studentBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Bungkus dengan MultiBlocProvider biar semua Tab kebagian data
    return MultiBlocProvider(
      providers: [
        BlocProvider<EquipmentListBloc>.value(value: _equipmentBloc),
        BlocProvider<TransactionListBloc>.value(value: _transactionBloc),
        BlocProvider<StudentListBloc>.value(value: _studentBloc),
      ],
      child: Scaffold(
        appBar: _buildAppBar(context, isDark),
        // BODY-nya sekarang dikendalikan penuh oleh go_router
        body: widget.navigationShell,
        bottomNavigationBar: _buildBottomNav(isDark),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    final bgColor = isDark ? AppTheme.darkSurface : AppTheme.surface;
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);

    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Logo + Nama App
                Container(
                  width: 36,
                  height: 36,
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
                const SizedBox(width: 10),
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

                // Search bar
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        context.push('/search'), // Migrasi ke go_router
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            color: isDark
                                ? AppTheme.darkTextSub
                                : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Cari peralatan, mahasiswa...',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              color: isDark
                                  ? AppTheme.darkTextSub
                                  : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Profile avatar + dropdown
                _ProfileDropdown(isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return BottomNavigationBar(
      // Ambil index tab dari go_router
      currentIndex: widget.navigationShell.currentIndex,
      onTap: (index) {
        // Pindah tab menggunakan go_router
        widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        );
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: isDark ? Colors.grey.shade400 : Colors.grey,
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
    );
  }
}

// ─── Profile Dropdown Widget ───────────────────────────────────────────────
class _ProfileDropdown extends StatelessWidget {
  final bool isDark;
  const _ProfileDropdown({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final name = SessionHelper.currentName;
    final role = SessionHelper.currentRole;
    final isAdmin = SessionHelper.isAdmin;

    return PopupMenuButton<String>(
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppTheme.darkSurface : AppTheme.surface,
      onSelected: (value) => _onMenuSelected(context, value),
      itemBuilder: (_) => [
        // Header info user
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primary,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? AppTheme.darkText : AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isAdmin ? AppTheme.primary : AppTheme.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      role,
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
            ],
          ),
        ),
        const PopupMenuDivider(),
        _menuItem('edit_profile', Icons.person_rounded, 'Edit Profile', isDark),
        _menuItem('theme', Icons.dark_mode_rounded, 'Ubah Tema', isDark),
        _menuItem('notif', Icons.notifications_rounded, 'Notifikasi', isDark),
        _menuItem('about', Icons.info_rounded, 'Tentang App', isDark),
        const PopupMenuDivider(),
        _menuItem(
          'logout',
          Icons.logout_rounded,
          'Keluar',
          isDark,
          isDestructive: true,
        ),
      ],
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primary,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label,
    bool isDark, {
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? AppTheme.error
        : (isDark ? AppTheme.darkText : AppTheme.textPrimary);
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'edit_profile':
      case 'theme':
      case 'notif':
      case 'about':
        context.push('/settings'); // Migrasi ke go_router
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
        title: const Text(
          'Konfirmasi Keluar',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Apakah kamu yakin ingin keluar?',
          style: TextStyle(fontFamily: AppTheme.fontFamily),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              SessionHelper.clearSession();
              Navigator.pop(context); // Tutup dialog popup
              context.read<AuthBloc>().add(
                LogoutRequested(),
              ); // Tembak event logout
              context.go('/login'); // Lempar ke halaman login pakai go_router
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
