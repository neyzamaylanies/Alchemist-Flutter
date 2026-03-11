// lib/screens/transaction/transaction_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/transaction/transaction_list_bloc.dart';
import '../../models/ui/transaction.dart';
import '../../utils/app_theme.dart';
import 'transaction_detail_page.dart';

class TransactionListPage extends StatefulWidget {
  final TransactionListBloc transactionBloc;
  const TransactionListPage({super.key, required this.transactionBloc});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.transactionBloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.navyDark,
          title: const Text("Peminjaman & Pengembalian", style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => widget.transactionBloc.add(LoadTransactionListEvent()),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.primary,
          onPressed: () => _onCreateClick(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SafeArea(
          child: BlocBuilder<TransactionListBloc, TransactionListState>(
            builder: (context, state) {
              if (state is TransactionListLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TransactionListLoaded) {
                if (state.transactions.isEmpty) {
                  return const Center(child: Text("Belum ada transaksi"));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  primary: false,
                  itemCount: state.transactions.length,
                  itemBuilder: (context, index) {
                    final t = state.transactions[index];
                    return _TransactionCardWidget(transaction: t, onCardClicked: (trx) {});
                  },
                );
              } else if (state is TransactionListError) {
                return Center(child: Text("Error: ${state.message}"));
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  void _onCreateClick(BuildContext context) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TransactionDetailPage(transaction: null)),
    );
    if (result is TransactionCreatedResult) {
      widget.transactionBloc.add(AddNewTransactionEvent(newTransaction: result.transaction));
    }
  }
}

class _TransactionCardWidget extends StatelessWidget {
  final Transaction transaction;
  final Function(Transaction) onCardClicked;

  const _TransactionCardWidget({required this.transaction, required this.onCardClicked});

  @override
  Widget build(BuildContext context) {
    final isPeminjaman = transaction.isPeminjaman;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0DFFF)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isPeminjaman ? Colors.orange.shade50 : Colors.green.shade50,
            child: Icon(
              isPeminjaman ? Icons.arrow_upward : Icons.arrow_downward,
              color: isPeminjaman ? Colors.orange : Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.equipmentId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(transaction.typeLabel, style: TextStyle(color: isPeminjaman ? Colors.orange : Colors.green, fontSize: 12)),
                if (transaction.usedBy != null)
                  Text("Oleh: ${transaction.usedBy}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${transaction.quantity}x", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(transaction.handledBy, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}