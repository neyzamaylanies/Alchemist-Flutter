// lib/screens/condition_log/condition_log_list_page.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/data_table_card.dart';
import '../../widgets/loading_button.dart';

class ConditionLogListPage extends StatefulWidget {
  const ConditionLogListPage({super.key});

  @override
  State<ConditionLogListPage> createState() => _ConditionLogListPageState();
}

class _ConditionLogListPageState extends State<ConditionLogListPage> {
  List<dynamic> _logs = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final res = await RemoteHelper.getDio().get('api/condition-logs');
      final data = (res.data['data'] as List<dynamic>?) ?? [];
      setState(() { _logs = data; _filtered = data; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch(String q) {
    setState(() {
      _search = q.toLowerCase();
      _filtered = _logs.where((l) =>
        (l['id'] ?? '').toLowerCase().contains(_search) ||
        (l['equipmentId'] ?? '').toLowerCase().contains(_search) ||
        (l['checkedBy'] ?? '').toLowerCase().contains(_search)
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Kondisi Alat',
      searchHint: 'Cari log kondisi...',
      onSearch: _onSearch,
      actionLabel: '+ Catat Kondisi',
      onAction: () => _showCreateDialog(context),
      body: DataTableCard(
        isLoading: _isLoading,
        emptyMessage: 'Belum ada log kondisi',
        emptyIcon: Icons.assignment_rounded,
        headers: const ['LOG ID', 'ALAT', 'KONDISI SEBELUM', 'KONDISI SESUDAH', 'TGL CEK', 'DICEK OLEH', 'CATATAN'],
        rows: _filtered.map((l) {
          final before = l['previousCondition'] ?? '-';
          final after = l['currentCondition'] ?? '-';
          return [
            Text(l['id'] ?? '', style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textSecondary)),
            Text(l['equipmentId'] ?? '', style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600)),
            StatusBadge(label: AppTheme.getKondisiLabel(before), color: AppTheme.getKondisiColor(before)),
            StatusBadge(label: AppTheme.getKondisiLabel(after), color: AppTheme.getKondisiColor(after)),
            Text((l['checkDate'] ?? '').toString().split('T').first, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
            Text(l['checkedBy'] ?? '-', style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12)),
            Tooltip(
              message: l['note'] ?? '',
              child: Text(
                l['note'] ?? '-',
                style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ];
        }).toList(),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final idCtrl = TextEditingController();
    final eqCtrl = TextEditingController();
    final byCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String prevCond = 'BAIK';
    String currCond = 'RUSAK_RINGAN';
    bool loading = false;
    const conditions = ['BAIK', 'RUSAK_RINGAN', 'RUSAK_BERAT', 'DALAM_PERBAIKAN'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Catat Kondisi Alat', style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field('ID Log', idCtrl, 'Contoh: LOG20250101001'),
                const SizedBox(height: 12),
                _field('ID Alat', eqCtrl, 'Contoh: EQ001'),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: DropdownButtonFormField<String>(
                    value: prevCond,
                    decoration: const InputDecoration(labelText: 'Kondisi Sebelum'),
                    items: conditions.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) => setStateDialog(() => prevCond = v ?? 'BAIK'),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: DropdownButtonFormField<String>(
                    value: currCond,
                    decoration: const InputDecoration(labelText: 'Kondisi Sesudah'),
                    items: conditions.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) => setStateDialog(() => currCond = v ?? 'RUSAK_RINGAN'),
                  )),
                ]),
                const SizedBox(height: 12),
                _field('Dicek Oleh', byCtrl, 'Contoh: EMP001'),
                const SizedBox(height: 12),
                _field('Catatan', noteCtrl, 'Catatan kondisi...'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            LoadingButton(
              isLoading: loading,
              text: 'Simpan',
              onPressed: () async {
                setStateDialog(() => loading = true);
                try {
                  await RemoteHelper.getDio().post('api/condition-logs', data: {
                    'id': idCtrl.text,
                    'equipmentId': eqCtrl.text,
                    'previousCondition': prevCond,
                    'currentCondition': currCond,
                    'checkDate': DateTime.now().toIso8601String(),
                    'checkedBy': byCtrl.text,
                    'note': noteCtrl.text.isNotEmpty ? noteCtrl.text : null,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadLogs();
                } catch (_) {
                  setStateDialog(() => loading = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}