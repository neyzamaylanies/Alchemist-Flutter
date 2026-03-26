// lib/screens/transaction/transaction_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/transaction/transaction_list_bloc.dart';
import '../../repositories/transaction_repository.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';
import '../../widgets/data_table_card.dart';
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
            // ── Header + search
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

            // ── Tabel
            Expanded(
              child: BlocBuilder<TransactionListBloc, TransactionListState>(
                builder: (context, state) {
                  final isLoading = state is TransactionListLoading;
                  final transactions = state is TransactionListLoaded
                      ? state.transactions
                            .where(
                              (t) =>
                                  t.id.toLowerCase().contains(_searchQuery) ||
                                  t.equipmentId.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  (t.usedBy?.toLowerCase().contains(
                                        _searchQuery,
                                      ) ??
                                      false),
                            )
                            .toList()
                      : [];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: DataTableCard(
                      isLoading: isLoading,
                      emptyMessage: 'Belum ada transaksi',
                      emptyIcon: Icons.swap_horiz_rounded,
                      headers: const [
                        'ID',
                        'TIPE',
                        'ALAT',
                        'PEMINJAM',
                        'JUMLAH',
                        'PETUGAS',
                        'TANGGAL',
                      ],
                      rows: transactions.map((t) {
                        final isPeminjaman = t.isPeminjaman;
                        final color = isPeminjaman
                            ? AppTheme.warning
                            : AppTheme.success;
                        final dateStr = (t.transactionDate ?? '')
                            .toString()
                            .split('T')
                            .first;

                        return [
                          Text(
                            t.id,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              color: subColor,
                            ),
                          ),
                          StatusBadge(label: t.typeLabel, color: color),
                          Text(
                            t.equipmentId,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          Text(
                            t.usedBy ?? '-',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              color: subColor,
                            ),
                          ),
                          Text(
                            '${t.quantity}x',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          Text(
                            t.handledBy,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              color: subColor,
                            ),
                          ),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              color: subColor,
                            ),
                          ),
                        ];
                      }).toList(),
                    ),
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
