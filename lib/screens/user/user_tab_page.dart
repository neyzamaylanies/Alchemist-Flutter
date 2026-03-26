// lib/screens/user/user_tab_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/student/student_list_bloc.dart';
import '../../repositories/student_repository.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';
import '../../models/ui/student.dart';
import '../student/student_list_page.dart';
import 'user_list_page.dart';

class UserTabPage extends StatefulWidget {
  const UserTabPage({super.key});

  @override
  State<UserTabPage> createState() => _UserTabPageState();
}

class _UserTabPageState extends State<UserTabPage> {
  late final StudentListBloc _studentBloc;
  List<dynamic> _recentUsers = [];
  bool _loadingUsers = true;

  @override
  void initState() {
    super.initState();
    _studentBloc = StudentListBloc(
      studentRepository: StudentRepository(RemoteHelper.getDio()),
    )..add(LoadStudentListEvent());
    _loadRecentUsers();
  }

  @override
  void dispose() {
    _studentBloc.close();
    super.dispose();
  }

  Future<void> _loadRecentUsers() async {
    try {
      final res = await RemoteHelper.getDio().get('api/users');
      final data = (res.data['data'] as List<dynamic>?) ?? [];
      setState(() {
        _recentUsers = data.take(3).toList();
        _loadingUsers = false;
      });
    } catch (_) {
      setState(() => _loadingUsers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.background;
    final cardColor = isDark ? AppTheme.darkSurface : AppTheme.surface;
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;

    return BlocProvider.value(
      value: _studentBloc,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manajemen User',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kelola data petugas dan mahasiswa',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  color: subColor,
                ),
              ),
              const SizedBox(height: 20),

              // 2 tombol navigasi
              Row(
                children: [
                  Expanded(
                    child: _NavCard(
                      icon: Icons.manage_accounts_rounded,
                      label: 'Petugas',
                      subtitle: 'Kelola user & admin',
                      gradient: AppTheme.primaryGradient,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UserListPage()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NavCard(
                      icon: Icons.school_rounded,
                      label: 'Mahasiswa',
                      subtitle: 'Kelola data mahasiswa',
                      gradient: AppTheme.blueGradient,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentListPage(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Petugas
              _SectionHeader(title: 'Petugas Terbaru', isDark: isDark),
              const SizedBox(height: 12),
              _loadingUsers
                  ? const Center(child: CircularProgressIndicator())
                  : _recentUsers.isEmpty
                  ? _EmptyCard(message: 'Belum ada petugas', isDark: isDark)
                  : Column(
                      children: _recentUsers
                          .map(
                            (u) => _UserCard(
                              user: u,
                              cardColor: cardColor,
                              borderColor: borderColor,
                              textColor: textColor,
                              subColor: subColor,
                              isDark: isDark,
                            ),
                          )
                          .toList(),
                    ),
              const SizedBox(height: 24),

              // Recent Mahasiswa
              _SectionHeader(title: 'Mahasiswa Terbaru', isDark: isDark),
              const SizedBox(height: 12),
              BlocBuilder<StudentListBloc, StudentListState>(
                builder: (context, state) {
                  if (state is StudentListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is StudentListLoaded) {
                    final recent = state.students.take(3).toList();
                    if (recent.isEmpty) {
                      return _EmptyCard(
                        message: 'Belum ada mahasiswa',
                        isDark: isDark,
                      );
                    }
                    return Column(
                      children: recent
                          .map(
                            (s) => _StudentCard(
                              student: s,
                              cardColor: cardColor,
                              borderColor: borderColor,
                              textColor: textColor,
                              subColor: subColor,
                            ),
                          )
                          .toList(),
                    );
                  }
                  return _EmptyCard(
                    message: 'Gagal memuat data',
                    isDark: isDark,
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Lihat semua',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: isDark ? AppTheme.darkText : AppTheme.textPrimary,
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  final bool isDark;
  const _EmptyCard({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? AppTheme.darkTextSub : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final dynamic user;
  final Color cardColor, borderColor, textColor, subColor;
  final bool isDark;
  const _UserCard({
    required this.user,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = (user['role'] ?? '') == 'ADMIN';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
            child: Text(
              (user['name'] ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? '',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: textColor,
                  ),
                ),
                Text(
                  user['email'] ?? '',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: subColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (isAdmin ? AppTheme.primary : AppTheme.success).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: (isAdmin ? AppTheme.primary : AppTheme.success)
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              user['role'] ?? '',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isAdmin ? AppTheme.primary : AppTheme.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final Color cardColor, borderColor, textColor, subColor;
  const _StudentCard({
    required this.student,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.blueDeep.withValues(alpha: 0.15),
            child: Text(
              student.name[0].toUpperCase(),
              style: const TextStyle(
                color: AppTheme.blueDeep,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: textColor,
                  ),
                ),
                Text(
                  '${student.nim} • ${student.studyProgram}',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: subColor,
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
