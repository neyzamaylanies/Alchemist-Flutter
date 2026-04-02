// lib/screens/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/equipment/equipment_list_bloc.dart';
import '../../blocs/transaction/transaction_list_bloc.dart';
import '../../blocs/student/student_list_bloc.dart';
import '../../repositories/equipment_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/student_repository.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  void _onNavigate(int index) {
    switch (index) {
      case 1:
        context.go('/transaksi');
        break;
      case 2:
        context.go('/peralatan');
        break;
      case 3:
        context.go('/user');
        break;
      default:
        context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.background;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _equipmentBloc),
        BlocProvider.value(value: _transactionBloc),
        BlocProvider.value(value: _studentBloc),
      ],
      child: Scaffold(
        backgroundColor: bgColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(context, isDark),
              const SizedBox(height: 20),
              _buildStatCards(context, isDark),
              const SizedBox(height: 24),
              _buildNeedAttentionSection(context, isDark),
              const SizedBox(height: 24),
              _buildRecentTransactions(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Greeting ──────────────────────────────────────────────────────────────
  Widget _buildGreeting(BuildContext context, bool isDark) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12)
      greeting = 'Selamat Pagi';
    else if (hour < 15)
      greeting = 'Selamat Siang';
    else if (hour < 18)
      greeting = 'Selamat Sore';
    else
      greeting = 'Selamat Malam';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary,
          ),
        ),
        Text(
          'Dashboard',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.darkText : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── Stat Cards ────────────────────────────────────────────────────────────
  Widget _buildStatCards(BuildContext context, bool isDark) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return BlocBuilder<EquipmentListBloc, EquipmentListState>(
      builder: (context, eqState) {
        return BlocBuilder<TransactionListBloc, TransactionListState>(
          builder: (context, trxState) {
            return BlocBuilder<StudentListBloc, StudentListState>(
              builder: (context, stuState) {
                int totalEq = 0, availableEq = 0, damagedEq = 0;
                int totalTrx = 0, totalStu = 0;

                if (eqState is EquipmentListLoaded) {
                  totalEq = eqState.equipments.length;
                  availableEq = eqState.equipments
                      .where((e) => e.conditionStatus == 'BAIK')
                      .length;
                  damagedEq = eqState.equipments
                      .where(
                        (e) =>
                            e.conditionStatus == 'RUSAK_BERAT' ||
                            e.conditionStatus == 'RUSAK_RINGAN',
                      )
                      .length;
                }
                if (trxState is TransactionListLoaded)
                  totalTrx = trxState.transactions.length;
                if (stuState is StudentListLoaded)
                  totalStu = stuState.students.length;

                final cards = [
                  _StatCardData(
                    'Total Peralatan',
                    totalEq.toString(),
                    Icons.science_rounded,
                    AppTheme.primaryGradient,
                    2,
                  ),
                  _StatCardData(
                    'Alat Tersedia',
                    availableEq.toString(),
                    Icons.check_circle_rounded,
                    AppTheme.blueGradient,
                    2,
                  ),
                  _StatCardData(
                    'Alat Rusak',
                    damagedEq.toString(),
                    Icons.warning_rounded,
                    AppTheme.purpleGradient,
                    2,
                    warning: damagedEq > 0,
                  ),
                  _StatCardData(
                    'Total Transaksi',
                    totalTrx.toString(),
                    Icons.swap_horiz_rounded,
                    AppTheme.periwinkleGradient,
                    1,
                  ),
                  _StatCardData(
                    'Mahasiswa',
                    totalStu.toString(),
                    Icons.people_rounded,
                    AppTheme.violetGradient,
                    3,
                  ),
                ];

                if (isMobile) {
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: cards
                        .map(
                          (c) => _StatCard(
                            label: c.label,
                            value: c.value,
                            icon: c.icon,
                            gradient: c.gradient,
                            warningValue: c.warning,
                            onTap: () => _onNavigate(c.navIndex),
                          ),
                        )
                        .toList(),
                  );
                }

                return Row(
                  children: cards
                      .map(
                        (c) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: c == cards.last ? 0 : 12,
                            ),
                            child: _StatCard(
                              label: c.label,
                              value: c.value,
                              icon: c.icon,
                              gradient: c.gradient,
                              warningValue: c.warning,
                              onTap: () => _onNavigate(c.navIndex),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            );
          },
        );
      },
    );
  }

  // ─── Perlu Perhatian ───────────────────────────────────────────────────────
  Widget _buildNeedAttentionSection(BuildContext context, bool isDark) {
    return BlocBuilder<EquipmentListBloc, EquipmentListState>(
      builder: (context, state) {
        if (state is! EquipmentListLoaded) return const SizedBox();
        final needAttention = state.equipments
            .where(
              (e) =>
                  e.conditionStatus == 'RUSAK_BERAT' ||
                  e.conditionStatus == 'RUSAK_RINGAN' ||
                  e.conditionStatus == 'DALAM_PERBAIKAN',
            )
            .toList();
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
                  child: const Icon(
                    Icons.notification_important_rounded,
                    color: AppTheme.error,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Perlu Perhatian',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.darkText : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${needAttention.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                children: needAttention.take(5).map((eq) {
                  final color = AppTheme.getKondisiColor(eq.conditionStatus);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color:
                              (isDark
                                      ? AppTheme.darkBorder
                                      : const Color(0xFFE5E7EB))
                                  .withValues(alpha: 0.5),
                        ),
                      ),
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
                            Icons.science_rounded,
                            color: color,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eq.equipmentName,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isDark
                                      ? AppTheme.darkText
                                      : AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                eq.location,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: isDark
                                      ? AppTheme.darkTextSub
                                      : AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusBadge(
                          label: AppTheme.getKondisiLabel(eq.conditionStatus),
                          color: color,
                        ),
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

  // ─── Recent Transactions ───────────────────────────────────────────────────
  Widget _buildRecentTransactions(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Transaksi Terbaru',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.darkText : AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _onNavigate(1),
              child: const Text(
                'Lihat semua',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // ── Cross-bloc builder: gabung transaksi + equipment + student ──────
        BlocBuilder<TransactionListBloc, TransactionListState>(
          builder: (context, trxState) {
            if (trxState is TransactionListLoading) {
              return const _SkeletonLoader();
            }
            if (trxState is TransactionListLoaded &&
                trxState.transactions.isNotEmpty) {
              return BlocBuilder<EquipmentListBloc, EquipmentListState>(
                builder: (context, eqState) {
                  return BlocBuilder<StudentListBloc, StudentListState>(
                    builder: (context, stuState) {
                      // Build lookup maps biar O(1)
                      final eqMap = <String, String>{};
                      if (eqState is EquipmentListLoaded) {
                        for (final eq in eqState.equipments) {
                          eqMap[eq.id] = eq.equipmentName;
                        }
                      }

                      final stuMap = <String, String>{};
                      if (stuState is StudentListLoaded) {
                        for (final s in stuState.students) {
                          stuMap[s.id] = s.name;
                        }
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkSurface
                              : AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.darkBorder
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Column(
                          children:
                              (List.of(trxState.transactions)..sort((a, b) {
                                    final dateA =
                                        DateTime.tryParse(
                                          a.transactionDate ?? '',
                                        ) ??
                                        DateTime(0);
                                    final dateB =
                                        DateTime.tryParse(
                                          b.transactionDate ?? '',
                                        ) ??
                                        DateTime(0);
                                    return dateB.compareTo(dateA);
                                  }))
                                  .take(5)
                                  .map((t) {
                                    final isPeminjaman = t.isPeminjaman;
                                    final color = isPeminjaman
                                        ? AppTheme.warning
                                        : AppTheme.success;

                                    // Resolusi nama dari map, fallback ke id
                                    final equipmentName =
                                        eqMap[t.equipmentId] ?? t.equipmentId;
                                    final borrowerName =
                                        stuMap[t.usedBy ?? ''] ??
                                        t.usedBy ??
                                        '-';
                                    final adminName = t.handledBy;

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color:
                                                (isDark
                                                        ? AppTheme.darkBorder
                                                        : const Color(
                                                            0xFFE5E7EB,
                                                          ))
                                                    .withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // ── Ikon tipe transaksi ────────────────
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: color.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              isPeminjaman
                                                  ? Icons.arrow_upward_rounded
                                                  : Icons
                                                        .arrow_downward_rounded,
                                              color: color,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // ── Info utama: ID + nama alat + peminjam ──
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Baris 1: ID transaksi
                                                Text(
                                                  t.id,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppTheme.fontFamily,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    color: isDark
                                                        ? AppTheme.darkText
                                                        : AppTheme.textPrimary,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                // Baris 2: Nama alat
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.science_rounded,
                                                      size: 11,
                                                      color: isDark
                                                          ? AppTheme.darkTextSub
                                                          : AppTheme
                                                                .textSecondary,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Expanded(
                                                      child: Text(
                                                        equipmentName,
                                                        style: TextStyle(
                                                          fontFamily: AppTheme
                                                              .fontFamily,
                                                          fontSize: 11,
                                                          color: isDark
                                                              ? AppTheme
                                                                    .darkTextSub
                                                              : AppTheme
                                                                    .textSecondary,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                // Baris 3: Peminjam + Admin
                                                Row(
                                                  children: [
                                                    // Peminjam
                                                    Icon(
                                                      Icons.person_rounded,
                                                      size: 11,
                                                      color: isDark
                                                          ? AppTheme.darkTextSub
                                                          : AppTheme
                                                                .textSecondary,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Flexible(
                                                      child: Text(
                                                        borrowerName,
                                                        style: TextStyle(
                                                          fontFamily: AppTheme
                                                              .fontFamily,
                                                          fontSize: 11,
                                                          color: isDark
                                                              ? AppTheme
                                                                    .darkTextSub
                                                              : AppTheme
                                                                    .textSecondary,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    // Separator
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 4,
                                                          ),
                                                      child: Text(
                                                        '·',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: isDark
                                                              ? AppTheme
                                                                    .darkTextSub
                                                              : AppTheme
                                                                    .textSecondary,
                                                        ),
                                                      ),
                                                    ),
                                                    // Admin
                                                    Icon(
                                                      Icons.badge_rounded,
                                                      size: 11,
                                                      color: isDark
                                                          ? AppTheme.darkTextSub
                                                          : AppTheme
                                                                .textSecondary,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Flexible(
                                                      child: Text(
                                                        adminName,
                                                        style: TextStyle(
                                                          fontFamily: AppTheme
                                                              .fontFamily,
                                                          fontSize: 11,
                                                          color: isDark
                                                              ? AppTheme
                                                                    .darkTextSub
                                                              : AppTheme
                                                                    .textSecondary,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // ── Quantity + Badge tipe ──────────────
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${t.quantity}x',
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppTheme.fontFamily,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: isDark
                                                      ? AppTheme.darkText
                                                      : AppTheme.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              _StatusBadge(
                                                label: t.typeLabel,
                                                color: color,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  })
                                  .toList(),
                        ),
                      );
                    },
                  );
                },
              );
            }
            return _buildEmptyState(
              'Belum ada transaksi',
              Icons.swap_horiz_rounded,
              isDark,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isDark ? AppTheme.darkTextSub : AppTheme.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data helper ──────────────────────────────────────────────────────────────
class _StatCardData {
  final String label, value;
  final IconData icon;
  final LinearGradient gradient;
  final int navIndex;
  final bool warning;
  _StatCardData(
    this.label,
    this.value,
    this.icon,
    this.gradient,
    this.navIndex, {
    this.warning = false,
  });
}

// ─── StatCard ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, value;
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

  bool get _isLight => gradient.colors.first.computeLuminance() > 0.4;

  @override
  Widget build(BuildContext context) {
    final textColor = _isLight ? const Color(0xFF1E1B4B) : Colors.white;
    final iconBgColor = _isLight
        ? const Color(0xFF1E1B4B).withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.2);
    final iconColor = _isLight ? const Color(0xFF1E1B4B) : Colors.white;
    final subColor = _isLight
        ? const Color(0xFF1E1B4B).withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.8);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                Icon(Icons.arrow_forward_rounded, color: subColor, size: 14),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: warningValue && value != '0'
                        ? AppTheme.error
                        : textColor,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    color: subColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: AppTheme.fontFamily,
        ),
      ),
    );
  }
}

// ─── Skeleton Loader ──────────────────────────────────────────────────────────
class _SkeletonLoader extends StatelessWidget {
  const _SkeletonLoader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: List.generate(
          3,
          (i) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Row(
              children: [
                _SkeletonBox(width: 36, height: 36, radius: 8, isDark: isDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(
                        width: 120,
                        height: 12,
                        radius: 4,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 6),
                      _SkeletonBox(
                        width: 80,
                        height: 10,
                        radius: 4,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                _SkeletonBox(width: 60, height: 24, radius: 12, isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width, height, radius;
  final bool isDark;
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceVar : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
