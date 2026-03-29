// lib/screens/transaction/transaction_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/transaction/transaction_list_bloc.dart';
import '../../models/ui/transaction.dart';
import '../../repositories/transaction_repository.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';
import 'transaction_detail_page.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  late final TransactionListBloc _bloc;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _bloc = TransactionListBloc(
      transactionRepository: TransactionRepository(RemoteHelper.getDio()),
    )..add(LoadTransactionListEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  List<Transaction> _sorted(List<Transaction> list) {
    final copy = List<Transaction>.from(list);
    copy.sort((a, b) {
      final da = DateTime.tryParse(a.transactionDate ?? '') ?? DateTime(0);
      final db = DateTime.tryParse(b.transactionDate ?? '') ?? DateTime(0);
      return db.compareTo(da);
    });
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.background;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            // ── Header + search ────────────────────────────────────────────
            Container(
              color: isDark ? AppTheme.darkSurface : AppTheme.surface,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Riwayat Transaksi',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _onCreateClick(context),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Tambah'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (q) =>
                        setState(() => _searchQuery = q.toLowerCase()),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      color: textColor,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Cari transaksi...',
                      prefixIcon: Icon(Icons.search_rounded, size: 18),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      constraints: BoxConstraints(maxHeight: 42),
                    ),
                  ),
                ],
              ),
            ),

            // ── Konten ────────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<TransactionListBloc, TransactionListState>(
                builder: (context, state) {
                  if (state is TransactionListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final all = state is TransactionListLoaded
                      ? state.transactions
                      : <Transaction>[];

                  final transactions = _sorted(
                    all.where((t) {
                      if (_searchQuery.isEmpty) return true;
                      return t.id.toLowerCase().contains(_searchQuery) ||
                          t.equipmentId.toLowerCase().contains(_searchQuery) ||
                          (t.usedBy?.toLowerCase().contains(_searchQuery) ??
                              false) ||
                          t.handledBy.toLowerCase().contains(_searchQuery);
                    }).toList(),
                  );

                  if (transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            size: 48,
                            color: subColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada transaksi',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: subColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      if (w < 600) {
                        return _MobileList(
                          transactions: transactions,
                          isDark: isDark,
                        );
                      }
                      return _DesktopTable(
                        transactions: transactions,
                        isDark: isDark,
                        availableWidth: w,
                        showPetugas: w >= 900,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCreateClick(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TransactionDetailPage(transaction: null),
      ),
    );
    if (result is TransactionCreatedResult) {
      _bloc.add(AddNewTransactionEvent(newTransaction: result.transaction));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE — Card list
// ─────────────────────────────────────────────────────────────────────────────
class _MobileList extends StatelessWidget {
  final List<Transaction> transactions;
  final bool isDark;
  const _MobileList({required this.transactions, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final t = transactions[i];
        final isPeminjaman = t.isPeminjaman;
        final color = isPeminjaman ? AppTheme.warning : AppTheme.success;
        final dateStr = (t.transactionDate ?? '').toString().split('T').first;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPeminjaman
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.id,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _TxBadge(label: t.typeLabel, color: color),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                      icon: Icons.science_rounded,
                      text: t.equipmentId,
                      color: subColor,
                    ),
                    const SizedBox(height: 3),
                    _InfoRow(
                      icon: Icons.person_rounded,
                      text: t.usedBy ?? '-',
                      color: subColor,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoRow(
                            icon: Icons.badge_rounded,
                            text: t.handledBy,
                            color: subColor,
                          ),
                        ),
                        Text(
                          '${t.quantity}x  ·  $dateStr',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            color: subColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESKTOP/TABLET — Custom table, full control, no DataTableCard
// ─────────────────────────────────────────────────────────────────────────────
class _DesktopTable extends StatelessWidget {
  final List<Transaction> transactions;
  final bool isDark;
  final double availableWidth;
  final bool showPetugas;

  const _DesktopTable({
    required this.transactions,
    required this.isDark,
    required this.availableWidth,
    required this.showPetugas,
  });

  List<_ColDef> get _cols => [
    const _ColDef('ID', 140, flex: 2),
    const _ColDef('TIPE', 120, flex: 0),
    const _ColDef('ALAT', 90, flex: 1),
    const _ColDef('PEMINJAM', 90, flex: 1),
    const _ColDef('JUMLAH', 70, flex: 0),
    if (showPetugas) const _ColDef('PETUGAS', 90, flex: 1),
    const _ColDef('TANGGAL', 100, flex: 1),
  ];

  // Flex-based column width — tidak ada yang overflow, tidak ada police line
  List<double> _computeWidths() {
    final cols = _cols;
    // 16px padding kiri + 16px kanan + 2px border = 34px dikurangi dari available
    final usable = availableWidth - 32;
    final fixedTotal = cols.fold<double>(
      0,
      (s, c) => s + (c.flex == 0 ? c.minWidth : 0),
    );
    final flexTotal = cols.fold<int>(0, (s, c) => s + c.flex);
    final remaining = (usable - fixedTotal).clamp(0.0, double.infinity);
    final perFlex = flexTotal > 0 ? remaining / flexTotal : 0.0;

    return cols.map((c) {
      if (c.flex == 0) return c.minWidth;
      return (c.flex * perFlex);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);
    final headerBg = isDark ? const Color(0xFF1E1B3A) : const Color(0xFFF9F9FF);

    final cols = _cols;
    final widths = _computeWidths();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Container(
                color: headerBg,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                child: Row(
                  children: List.generate(
                    cols.length,
                    (i) => SizedBox(
                      width: widths[i],
                      child: Text(
                        cols[i].label,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: subColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Divider(height: 1, thickness: 1, color: borderColor),

              // ── Rows ──────────────────────────────────────────────────
              ...List.generate(transactions.length, (index) {
                final t = transactions[index];
                final isPeminjaman = t.isPeminjaman;
                final color = isPeminjaman
                    ? AppTheme.warning
                    : AppTheme.success;
                final dateStr = (t.transactionDate ?? '')
                    .toString()
                    .split('T')
                    .first;
                final isEven = index % 2 == 0;
                final rowBg = isDark
                    ? (isEven ? AppTheme.darkSurface : const Color(0xFF1A1730))
                    : (isEven ? Colors.white : const Color(0xFFFAFAFF));
                final isLast = index == transactions.length - 1;

                final cells = <Widget>[
                  // ID
                  Text(
                    t.id,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      color: subColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // TIPE — badge wrap intrinsic, tidak full-width
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _TxBadge(label: t.typeLabel, color: color),
                  ),
                  // ALAT
                  Text(
                    t.equipmentId,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // PEMINJAM
                  Text(
                    t.usedBy ?? '-',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      color: subColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // JUMLAH
                  Text(
                    '${t.quantity}x',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  // PETUGAS (desktop only)
                  if (showPetugas)
                    Text(
                      t.handledBy,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        color: subColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  // TANGGAL
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      color: subColor,
                    ),
                  ),
                ];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: rowBg,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(
                          cells.length,
                          (i) => SizedBox(width: widths[i], child: cells[i]),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(height: 1, thickness: 1, color: borderColor),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
class _ColDef {
  final String label;
  final double minWidth;
  final int flex;
  const _ColDef(this.label, this.minWidth, {this.flex = 0});
}

class _TxBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TxBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _InfoRow({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
