// lib/screens/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/equipment/equipment_list_bloc.dart';
import '../../blocs/transaction/transaction_list_bloc.dart';
import '../../blocs/student/student_list_bloc.dart';
import '../../utils/app_theme.dart';

class HomePage extends StatelessWidget {
  final EquipmentListBloc equipmentBloc;
  final TransactionListBloc transactionBloc;
  final StudentListBloc studentBloc;
  final Function(int) onNavigate;

  const HomePage({
    super.key,
    required this.equipmentBloc,
    required this.transactionBloc,
    required this.studentBloc,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(context),
          const SizedBox(height: 24),
          _buildNeedAttentionSection(context),
          const SizedBox(height: 24),
          _buildRecentTransactions(context),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context) {
    return BlocBuilder<EquipmentListBloc, EquipmentListState>(
      bloc: equipmentBloc,
      builder: (context, eqState) {
        return BlocBuilder<TransactionListBloc, TransactionListState>(
          bloc: transactionBloc,
          builder: (context, trxState) {
            return BlocBuilder<StudentListBloc, StudentListState>(
              bloc: studentBloc,
              builder: (context, stuState) {
                int totalEq = 0, availableEq = 0, damagedEq = 0;
                int totalTrx = 0;
                int totalStu = 0;

                if (eqState is EquipmentListLoaded) {
                  totalEq = eqState.equipments.length;
                  availableEq = eqState.equipments.where((e) => e.conditionStatus == 'BAIK').length;
                  damagedEq = eqState.equipments.where((e) =>
                    e.conditionStatus == 'RUSAK_BERAT' || e.conditionStatus == 'RUSAK_RINGAN').length;
                }
                if (trxState is TransactionListLoaded) totalTrx = trxState.transactions.length;
                if (stuState is StudentListLoaded) totalStu = stuState.students.length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _StatCard(
                          label: 'Total Peralatan',
                          value: totalEq.toString(),
                          icon: Icons.science_rounded,
                          gradient: AppTheme.primaryGradient,
                          onTap: () => onNavigate(2),
                        )),
                        const SizedBox(width: 16),
                        Expanded(child: _StatCard(
                          label: 'Alat Tersedia',
                          value: availableEq.toString(),
                          icon: Icons.check_circle_rounded,
                          gradient: AppTheme.blueGradient,
                          onTap: () => onNavigate(2),
                        )),
                        const SizedBox(width: 16),
                        Expanded(child: _StatCard(
                          label: 'Alat Rusak',
                          value: damagedEq.toString(),
                          icon: Icons.warning_rounded,
                          gradient: AppTheme.purpleGradient,
                          onTap: () => onNavigate(3),
                          warningValue: damagedEq > 0,
                        )),
                        const SizedBox(width: 16),
                        Expanded(child: _StatCard(
                          label: 'Total Transaksi',
                          value: totalTrx.toString(),
                          icon: Icons.swap_horiz_rounded,
                          gradient: AppTheme.periwinkleGradient,
                          onTap: () => onNavigate(1),
                        )),
                        const SizedBox(width: 16),
                        Expanded(child: _StatCard(
                          label: 'Mahasiswa Aktif',
                          value: totalStu.toString(),
                          icon: Icons.people_rounded,
                          gradient: AppTheme.violetGradient,
                          onTap: () => onNavigate(4),
                        )),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNeedAttentionSection(BuildContext context) {
    return BlocBuilder<EquipmentListBloc, EquipmentListState>(
      bloc: equipmentBloc,
      builder: (context, state) {
        if (state is! EquipmentListLoaded) return const SizedBox();
        final needAttention = state.equipments.where((e) =>
          e.conditionStatus == 'RUSAK_BERAT' ||
          e.conditionStatus == 'RUSAK_RINGAN' ||
          e.conditionStatus == 'DALAM_PERBAIKAN').toList();

        if (needAttention.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.notification_important_rounded, color: AppTheme.error, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Perlu Perhatian',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${needAttention.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: AppTheme.fontFamily),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: needAttention.take(5).map((eq) {
                  final color = AppTheme.getKondisiColor(eq.conditionStatus);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: const Color(0xFFE5E7EB).withValues(alpha: 0.5))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.science_rounded, color: color, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(eq.equipmentName, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 13)),
                              Text(eq.location, style: const TextStyle(fontFamily: AppTheme.fontFamily, color: AppTheme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        _StatusBadge(label: AppTheme.getKondisiLabel(eq.conditionStatus), color: color),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return BlocBuilder<TransactionListBloc, TransactionListState>(
      bloc: transactionBloc,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaksi Terbaru',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigate(1),
                  child: const Text('Lihat Semua', style: TextStyle(fontFamily: AppTheme.fontFamily)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state is TransactionListLoading)
              const _SkeletonLoader()
            else if (state is TransactionListLoaded && state.transactions.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: state.transactions.take(5).map((t) {
                    final isPeminjaman = t.isPeminjaman;
                    final color = isPeminjaman ? AppTheme.warning : AppTheme.success;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isPeminjaman ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                              color: color, size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.equipmentId, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 13)),
                                if (t.usedBy != null)
                                  Text('Oleh: ${t.usedBy}', style: const TextStyle(fontFamily: AppTheme.fontFamily, color: AppTheme.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          _StatusBadge(label: t.typeLabel, color: color),
                          const SizedBox(width: 12),
                          Text('${t.quantity}x', style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            else
              _buildEmptyState('Belum ada transaksi', Icons.swap_horiz_rounded),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(fontFamily: AppTheme.fontFamily, color: AppTheme.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final bool warningValue;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.warningValue = false,
  });

  // Cek apakah warna background terang atau gelap
  bool get _isLight {
    final color = gradient.colors.first;
    final luminance = color.computeLuminance();
    return luminance > 0.4;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _isLight ? const Color(0xFF1E1B4B) : Colors.white;
    final iconBgColor = _isLight
        ? const Color(0xFF1E1B4B).withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.2);
    final iconColor = _isLight ? const Color(0xFF1E1B4B) : Colors.white;
    final subtextColor = _isLight
        ? const Color(0xFF1E1B4B).withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.8);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                Icon(Icons.arrow_forward_rounded, color: subtextColor, size: 16),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: warningValue && value != '0'
                    ? AppTheme.error
                    : textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                color: subtextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: AppTheme.fontFamily,
        ),
      ),
    );
  }
}

class _SkeletonLoader extends StatelessWidget {
  const _SkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: List.generate(3, (i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              _SkeletonBox(width: 36, height: 36, radius: 8),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: 120, height: 12, radius: 4),
                  const SizedBox(height: 6),
                  _SkeletonBox(width: 80, height: 10, radius: 4),
                ],
              )),
              _SkeletonBox(width: 60, height: 24, radius: 12),
            ],
          ),
        )),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width, height, radius;
  const _SkeletonBox({required this.width, required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}