// lib/screens/transaction/transaction_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/transaction/transaction_list_bloc.dart';
import '../../utils/app_theme.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/data_table_card.dart';
import 'transaction_detail_page.dart';

class TransactionListPage extends StatefulWidget {
  final TransactionListBloc transactionBloc;
  const TransactionListPage({super.key, required this.transactionBloc});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.transactionBloc,
      child: PageScaffold(
        title: 'Riwayat Transaksi',
        searchHint: 'Cari transaksi...',
        onSearch: (q) => setState(() => _searchQuery = q.toLowerCase()),
        actionLabel: '+ Transaksi Baru',
        onAction: () => _onCreateClick(context),
        body: BlocBuilder<TransactionListBloc, TransactionListState>(
          builder: (context, state) {
            final isLoading = state is TransactionListLoading;
            final transactions = state is TransactionListLoaded
                ? state.transactions.where((t) =>
                    t.id.toLowerCase().contains(_searchQuery) ||
                    t.equipmentId.toLowerCase().contains(_searchQuery) ||
                    (t.usedBy?.toLowerCase().contains(_searchQuery) ?? false)
                  ).toList()
                : [];

            return DataTableCard(
              isLoading: isLoading,
              emptyMessage: 'Belum ada transaksi',
              emptyIcon: Icons.swap_horiz_rounded,
              headers: const ['ID', 'TIPE', 'ALAT', 'PEMINJAM', 'JUMLAH', 'PETUGAS'],
              rows: transactions.map((t) {
                final isPeminjaman = t.isPeminjaman;
                final color = isPeminjaman ? AppTheme.warning : AppTheme.success;
                return [
                  Text(t.id, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
                  StatusBadge(label: t.typeLabel, color: color),
                  Text(t.equipmentId, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(t.usedBy ?? '-', style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
                  Text('${t.quantity}x', style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(t.handledBy, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
                ];
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  void _onCreateClick(BuildContext context) async {
    var result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionDetailPage(transaction: null)));
    if (result is TransactionCreatedResult) {
      widget.transactionBloc.add(AddNewTransactionEvent(newTransaction: result.transaction));
    }
  }
}