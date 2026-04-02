// lib/screens/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/session_helper.dart';
import '../../utils/theme_provider.dart';
import '../../utils/routes.dart';
import '../../widgets/loading_button.dart';
import '../../utils/remote_helper.dart';
import '../../utils/shared_preference_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedSection = 0; // 0=profile, 1=tema, 2=notif, 3=about

  @override
  void initState() {
    super.initState();
    // Baca argument dari route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arg = ModalRoute.of(context)?.settings.arguments as String?;
      if (arg == 'theme')
        setState(() => _selectedSection = 1);
      else if (arg == 'notif')
        setState(() => _selectedSection = 2);
      else if (arg == 'about')
        setState(() => _selectedSection = 3);
      else
        setState(() => _selectedSection = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.background;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          // Sidebar menu (tablet/web) atau top tabs (mobile)
          if (MediaQuery.of(context).size.width > 600) ...[
            _buildSideMenu(isDark, textColor),
            Container(
              width: 1,
              color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
            ),
          ],
          Expanded(child: _buildContent(isDark, textColor)),
        ],
      ),
      // Bottom tabs for mobile
      bottomNavigationBar: MediaQuery.of(context).size.width <= 600
          ? _buildBottomTabs(isDark)
          : null,
    );
  }

  Widget _buildSideMenu(bool isDark, Color textColor) {
    final items = [
      (Icons.person_rounded, 'Edit Profile'),
      (Icons.dark_mode_rounded, 'Tema'),
      (Icons.notifications_rounded, 'Notifikasi'),
      (Icons.info_rounded, 'Tentang App'),
    ];
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isSelected = _selectedSection == e.key;
          return GestureDetector(
            onTap: () => setState(() => _selectedSection = e.key),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    e.value.$1,
                    size: 18,
                    color: isSelected
                        ? AppTheme.primary
                        : (isDark
                              ? AppTheme.darkTextSub
                              : AppTheme.textSecondary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    e.value.$2,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? AppTheme.primary : textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomTabs(bool isDark) {
    return BottomNavigationBar(
      currentIndex: _selectedSection,
      onTap: (i) => setState(() => _selectedSection = i),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dark_mode_rounded),
          label: 'Tema',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_rounded),
          label: 'Notif',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_rounded),
          label: 'Tentang',
        ),
      ],
    );
  }

  Widget _buildContent(bool isDark, Color textColor) {
    switch (_selectedSection) {
      case 0:
        return _EditProfileSection(isDark: isDark, textColor: textColor);
      case 1:
        return _ThemeSection(isDark: isDark, textColor: textColor);
      case 2:
        return _NotifSection(isDark: isDark, textColor: textColor);
      case 3:
        return _AboutSection(isDark: isDark, textColor: textColor);
      default:
        return const SizedBox();
    }
  }
}

// ─── Edit Profile ────────────────────────────────────────────────────────────
class _EditProfileSection extends StatefulWidget {
  final bool isDark;
  final Color textColor;
  const _EditProfileSection({required this.isDark, required this.textColor});

  @override
  State<_EditProfileSection> createState() => _EditProfileSectionState();
}

class _EditProfileSectionState extends State<_EditProfileSection> {
  late final _nameCtrl = TextEditingController(text: SessionHelper.currentName);
  late final _emailCtrl = TextEditingController(
    text: SessionHelper.currentEmail,
  );
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Profile',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: widget.textColor,
            ),
          ),
          const SizedBox(height: 20),
          // Avatar
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    SessionHelper.currentName.isNotEmpty
                        ? SessionHelper.currentName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _fieldLabel('Nama', widget.textColor),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(hintText: 'Nama lengkap'),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Email', widget.textColor),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'email@contoh.com'),
          ),
          const SizedBox(height: 24),
          Text(
            'Ganti Password',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: widget.textColor,
            ),
          ),
          const SizedBox(height: 12),
          _fieldLabel('Password Lama', widget.textColor),
          TextField(
            controller: _oldPassCtrl,
            obscureText: true,
            decoration: const InputDecoration(hintText: '••••••••'),
          ),
          const SizedBox(height: 12),
          _fieldLabel('Password Baru', widget.textColor),
          TextField(
            controller: _newPassCtrl,
            obscureText: true,
            decoration: const InputDecoration(hintText: '••••••••'),
          ),
          const SizedBox(height: 24),
          LoadingButton(
            isLoading: _loading,
            text: 'Simpan Perubahan',
            onPressed: _onSave,
          ),
        ],
      ),
    );
  }

  void _onSave() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan email tidak boleh kosong!')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await RemoteHelper.getDio().put(
        'api/users/${SessionHelper.currentId}',
        data: {
          'name': _nameCtrl.text,
          'email': _emailCtrl.text,
          if (_newPassCtrl.text.isNotEmpty) 'password': _newPassCtrl.text,
        },
      );

      SessionHelper.setSession(
        id: SessionHelper.currentId,
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        role: SessionHelper.currentRole,
      );

      await SharedPreferenceHelper.saveUserInfo(
        id: SessionHelper.currentId,
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        role: SessionHelper.currentRole,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui profil')),
        );
      }
    }
    setState(() => _loading = false);
  }

  Widget _fieldLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

// ─── Tema ─────────────────────────────────────────────────────────────────────
class _ThemeSection extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  const _ThemeSection({required this.isDark, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tema Aplikasi',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih tampilan yang nyaman untuk kamu',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          // Light mode card
          _ThemeCard(
            icon: Icons.wb_sunny_rounded,
            title: 'Mode Terang',
            subtitle: 'Tampilan cerah, cocok di siang hari',
            isSelected: !themeProvider.isDarkMode,
            onTap: () => themeProvider.setDark(false),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          // Dark mode card
          _ThemeCard(
            icon: Icons.dark_mode_rounded,
            title: 'Mode Gelap',
            subtitle: 'Tampilan gelap, hemat baterai',
            isSelected: themeProvider.isDarkMode,
            onTap: () => themeProvider.setDark(true),
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          // Toggle switch
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.wb_sunny_rounded,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    themeProvider.isDarkMode
                        ? 'Mode Gelap Aktif'
                        : 'Mode Terang Aktif',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (v) => themeProvider.setDark(v),
                  activeColor: AppTheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool isSelected, isDark;
  final VoidCallback onTap;
  const _ThemeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.08)
              : (isDark ? AppTheme.darkSurface : AppTheme.surface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected
                          ? AppTheme.primary
                          : (isDark ? AppTheme.darkText : AppTheme.textPrimary),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.darkTextSub
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Notifikasi ───────────────────────────────────────────────────────────────
class _NotifSection extends StatefulWidget {
  final bool isDark;
  final Color textColor;
  const _NotifSection({required this.isDark, required this.textColor});

  @override
  State<_NotifSection> createState() => _NotifSectionState();
}

class _NotifSectionState extends State<_NotifSection> {
  bool _notifAlatRusak = true;
  bool _notifTransaksi = false;
  bool _notifStokRendah = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifikasi',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: widget.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Atur notifikasi yang ingin kamu terima',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: widget.isDark
                  ? AppTheme.darkTextSub
                  : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _NotifTile(
            icon: Icons.warning_rounded,
            iconColor: AppTheme.error,
            title: 'Alat Rusak',
            subtitle:
                'Notifikasi saat ada alat yang kondisinya berubah jadi rusak',
            value: _notifAlatRusak,
            onChanged: (v) => setState(() => _notifAlatRusak = v),
            isDark: widget.isDark,
            textColor: widget.textColor,
          ),
          const SizedBox(height: 8),
          _NotifTile(
            icon: Icons.swap_horiz_rounded,
            iconColor: AppTheme.warning,
            title: 'Transaksi Baru',
            subtitle:
                'Notifikasi saat ada transaksi peminjaman atau pengembalian baru',
            value: _notifTransaksi,
            onChanged: (v) => setState(() => _notifTransaksi = v),
            isDark: widget.isDark,
            textColor: widget.textColor,
          ),
          const SizedBox(height: 8),
          _NotifTile(
            icon: Icons.inventory_rounded,
            iconColor: AppTheme.info,
            title: 'Stok Alat Rendah',
            subtitle: 'Notifikasi saat jumlah alat tersedia kurang dari 20%',
            value: _notifStokRendah,
            onChanged: (v) => setState(() => _notifStokRendah = v),
            isDark: widget.isDark,
            textColor: widget.textColor,
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final bool value, isDark;
  final Color textColor;
  final ValueChanged<bool> onChanged;
  const _NotifTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.textColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.darkTextSub
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

// ─── About ───────────────────────────────────────────────────────────────────
class _AboutSection extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  const _AboutSection({required this.isDark, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tentang Aplikasi',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3730A3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/images/logo/LogoAlchemist.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Alchemist',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sistem Manajemen Inventory Laboratorium',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: isDark
                        ? AppTheme.darkTextSub
                        : AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _InfoTile(
            label: 'Versi Aplikasi',
            value: '1.0.0',
            isDark: isDark,
            textColor: textColor,
          ),
          _InfoTile(
            label: 'Platform',
            value: 'Flutter (Android & Web)',
            isDark: isDark,
            textColor: textColor,
          ),
          _InfoTile(
            label: 'Backend',
            value: 'Spring Boot REST API',
            isDark: isDark,
            textColor: textColor,
          ),
          _InfoTile(
            label: 'Developer',
            value: 'Tim Alchemist — FTUI',
            isDark: isDark,
            textColor: textColor,
          ),
          _InfoTile(
            label: 'Tahun',
            value: '2025',
            isDark: isDark,
            textColor: textColor,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  final bool isDark;
  final Color textColor;
  const _InfoTile({
    required this.label,
    required this.value,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
