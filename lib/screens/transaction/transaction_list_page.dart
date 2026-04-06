// lib/screens/transaction/transaction_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/transaction/transaction_list_bloc.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';
import '../../widgets/data_table_card.dart';
import 'transaction_detail_page.dart';

enum _SortOrder { newestFirst, oldestFirst }

class TransactionListPage extends StatefulWidget {
  // ← Hapus required transactionBloc, ambil dari context via BlocProvider
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  String     _searchQuery = '';
  _SortOrder _sortOrder   = _SortOrder.newestFirst;

  Map<String, String> _equipmentNames = {};
  Map<String, String> _studentNames   = {};
  Map<String, String> _userNames      = {};

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    try {
      final dio = RemoteHelper.getDio();
      final results = await Future.wait([
        dio.get('api/equipments'),
        dio.get('api/students'),
        dio.get('api/users'),
      ]);
      final eqMap = <String, String>{};
      for (final e in (results[0].data['data'] as List<dynamic>? ?? [])) {
        eqMap[e['id'] ?? ''] = e['equipmentName'] ?? e['id'] ?? '';
      }
      final stuMap = <String, String>{};
      for (final s in (results[1].data['data'] as List<dynamic>? ?? [])) {
        stuMap[s['id'] ?? ''] = s['name'] ?? s['id'] ?? '';
      }
      final userMap = <String, String>{};
      for (final u in (results[2].data['data'] as List<dynamic>? ?? [])) {
        userMap[u['id'] ?? ''] = u['name'] ?? u['id'] ?? '';
      }
      if (mounted) setState(() {
        _equipmentNames = eqMap;
        _studentNames   = stuMap;
        _userNames      = userMap;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgColor   = isDark ? AppTheme.darkBg : AppTheme.background;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor  = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Container(
            color: isDark ? AppTheme.darkSurface : AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text('Riwayat Transaksi', style: TextStyle(
                    fontFamily: AppTheme.fontFamily, fontSize: 18,
                    fontWeight: FontWeight.w700, color: textColor))),
                  ElevatedButton.icon(
                    onPressed: () => _onCreateClick(context),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Tambah'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                  ),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: TextField(
                      onChanged: (q) => setState(() => _searchQuery = q.toLowerCase()),
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                      decoration: const InputDecoration(
                        hintText: 'Cari transaksi...',
                        prefixIcon: Icon(Icons.search_rounded, size: 18),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        constraints: BoxConstraints(maxHeight: 42),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: _sortOrder == _SortOrder.newestFirst
                        ? 'Terbaru → Terlama' : 'Terlama → Terbaru',
                    child: InkWell(
                      onTap: () => setState(() {
                        _sortOrder = _sortOrder == _SortOrder.newestFirst
                            ? _SortOrder.oldestFirst : _SortOrder.newestFirst;
                      }),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                            _sortOrder == _SortOrder.newestFirst
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            size: 16, color: AppTheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            _sortOrder == _SortOrder.newestFirst ? 'Terbaru' : 'Terlama',
                            style: const TextStyle(fontFamily: AppTheme.fontFamily,
                              fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<TransactionListBloc, TransactionListState>(
              builder: (context, state) {
                final isLoading = state is TransactionListLoading;
                var transactions = state is TransactionListLoaded
                    ? state.transactions.where((t) {
                        final eq  = _equipmentNames[t.equipmentId]?.toLowerCase() ?? t.equipmentId.toLowerCase();
                        final stu = _studentNames[t.usedBy ?? '']?.toLowerCase() ?? '';
                        final usr = _userNames[t.handledBy]?.toLowerCase() ?? t.handledBy.toLowerCase();
                        return t.id.toLowerCase().contains(_searchQuery) ||
                            eq.contains(_searchQuery) ||
                            stu.contains(_searchQuery) ||
                            usr.contains(_searchQuery);
                      }).toList()
                    : <dynamic>[];

                transactions.sort((a, b) {
                  final dateA = DateTime.tryParse(a.transactionDate ?? '') ?? DateTime(2000);
                  final dateB = DateTime.tryParse(b.transactionDate ?? '') ?? DateTime(2000);
                  return _sortOrder == _SortOrder.newestFirst
                      ? dateB.compareTo(dateA)
                      : dateA.compareTo(dateB);
                });

                return DataTableCard(
                  isLoading: isLoading,
                  emptyMessage: 'Belum ada transaksi',
                  emptyIcon: Icons.swap_horiz_rounded,
                  headers: const ['ID', 'TIPE', 'ALAT', 'PEMINJAM', 'JUMLAH', 'PETUGAS', 'TANGGAL'],
                  rows: transactions.map((t) {
                    final isPeminjaman = t.isPeminjaman;
                    final color    = isPeminjaman ? AppTheme.warning : AppTheme.success;
                    final dateStr  = (t.transactionDate ?? '').toString().split('T').first;
                    final eqName   = _equipmentNames[t.equipmentId] ?? t.equipmentId;
                    final stuName  = t.usedBy != null ? (_studentNames[t.usedBy!] ?? t.usedBy!) : '-';
                    final userName = _userNames[t.handledBy] ?? t.handledBy;
                    return [
                      Text(t.id, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: subColor)),
                      StatusBadge(label: t.typeLabel, color: color),
                      Text(eqName, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                      Text(stuName, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: subColor)),
                      Text('${t.quantity}x', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                      Text(userName, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: subColor)),
                      Text(dateStr, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: subColor)),
                    ];
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onCreateClick(BuildContext context) async {
    final result = await showTransactionForm(
      context,
      equipmentNames: _equipmentNames,
      studentNames:   _studentNames,
      userNames:      _userNames,
    );
    if (result is TransactionCreatedResult) {
      context.read<TransactionListBloc>().add(
        AddNewTransactionEvent(newTransaction: result.transaction));
      _loadLookups();
    }
  }
}