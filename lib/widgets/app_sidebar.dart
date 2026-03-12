// lib/widgets/app_sidebar.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/session_helper.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final role = SessionHelper.currentRole;
    final name = SessionHelper.currentName;
    final isAdmin = role == 'ADMIN';

    return Container(
      width: 240,
      color: AppTheme.sidebarBg,
      child: Column(
        children: [
          // Logo header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
            child: Row(
              children: [
                // Kotak putih di belakang logo
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/images/logo/LogoAlchemist.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Alchemist',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textOnDark,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // Menu items — scrollable supaya tidak overflow
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('UTAMA'),
                  _menuItem(context, 0, Icons.dashboard_rounded, 'Dashboard'),
                  _menuItem(context, 1, Icons.swap_horiz_rounded, 'Transaksi'),
                  _menuItem(context, 2, Icons.science_rounded, 'Peralatan'),
                  _menuItem(context, 3, Icons.assignment_rounded, 'Kondisi Alat'),
                  _menuItem(context, 4, Icons.people_rounded, 'Mahasiswa'),
                  _menuItem(context, 5, Icons.category_rounded, 'Kategori'),
                  if (isAdmin) ...[
                    _sectionLabel('ADMIN AREA'),
                    _menuItem(context, 6, Icons.manage_accounts_rounded, 'User Management'),
                  ],
                ],
              ),
            ),
          ),

          // Profile + Logout — fixed di bawah
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.sidebarSelected,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: AppTheme.sidebarTextSelected,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              fontFamily: AppTheme.fontFamily,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: isAdmin
                                  ? AppTheme.primary.withValues(alpha: 0.3)
                                  : AppTheme.success.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              role,
                              style: TextStyle(
                                color: isAdmin ? AppTheme.primaryLighter : AppTheme.success,
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
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _onLogout(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, size: 16, color: AppTheme.sidebarTextMuted),
                        SizedBox(width: 6),
                        Text(
                          'Keluar',
                          style: TextStyle(
                            color: AppTheme.sidebarTextMuted,
                            fontSize: 13,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                      ],
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

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.sidebarTextMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            fontFamily: AppTheme.fontFamily,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppTheme.primary.withValues(alpha: 0.4))
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18,
              color: isSelected ? AppTheme.primaryLighter : AppTheme.sidebarTextMuted,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.sidebarTextSelected : AppTheme.sidebarText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Container(
                width: 4, height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryLighter,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Keluar', style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
        content: const Text('Apakah kamu yakin ingin keluar?', style: TextStyle(fontFamily: AppTheme.fontFamily)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () { SessionHelper.clearSession(); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}