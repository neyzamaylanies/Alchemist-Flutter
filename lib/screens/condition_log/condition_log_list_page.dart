// lib/screens/condition_log/condition_log_list_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.background;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Log Kondisi Alat',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? AppTheme.darkSurface : AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _onSearch,
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                    decoration: const InputDecoration(
                      hintText: 'Cari log kondisi...',
                      prefixIcon: Icon(Icons.search_rounded, size: 18),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      constraints: BoxConstraints(maxHeight: 42),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showCreateDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Catat'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                ),
              ],
            ),
          ),
          Expanded(
            child: DataTableCard(
              isLoading: _isLoading,
              emptyMessage: 'Belum ada log kondisi',
              emptyIcon: Icons.assignment_rounded,
              headers: const ['LOG ID', 'ALAT', 'SEBELUM', 'SESUDAH', 'TGL CEK', 'DICEK OLEH'],
              rows: _filtered.map((l) {
                final before = l['previousCondition'] ?? '-';
                final after  = l['currentCondition'] ?? '-';
                final date   = (l['checkDate'] ?? '').toString().split('T').first;
                return [
                  Text(l['id'] ?? '', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11,
                    color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary)),
                  Text(l['equipmentId'] ?? '', style: TextStyle(fontFamily: AppTheme.fontFamily,
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkText : AppTheme.textPrimary)),
                  StatusBadge(label: AppTheme.getKondisiLabel(before), color: AppTheme.getKondisiColor(before)),
                  StatusBadge(label: AppTheme.getKondisiLabel(after),  color: AppTheme.getKondisiColor(after)),
                  Text(date, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12,
                    color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary)),
                  Text(l['checkedBy'] ?? '-', style: TextStyle(fontFamily: AppTheme.fontFamily,
                    fontSize: 12, color: isDark ? AppTheme.darkText : AppTheme.textPrimary)),
                ];
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final idCtrl   = TextEditingController();
    final eqCtrl   = TextEditingController();
    final byCtrl   = TextEditingController();
    final noteCtrl = TextEditingController();
    String prevCond = 'BAIK';
    String currCond = 'RUSAK_RINGAN';
    DateTime checkDate = DateTime.now();
    bool loading = false;
    const conditions = ['BAIK', 'RUSAK_RINGAN', 'RUSAK_BERAT', 'DALAM_PERBAIKAN'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16,
            MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                const Text('Catat Kondisi Alat', style: TextStyle(
                  fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                _formField('ID Log', idCtrl, 'LOG20250101001'),
                const SizedBox(height: 12),
                _formField('ID Alat', eqCtrl, 'EQ001'),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: DropdownButtonFormField<String>(
                    value: prevCond,
                    decoration: const InputDecoration(labelText: 'Kondisi Sebelum'),
                    items: conditions.map((c) => DropdownMenuItem(value: c,
                      child: Text(AppTheme.getKondisiLabel(c),
                        style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12)))).toList(),
                    onChanged: (v) => setS(() => prevCond = v ?? 'BAIK'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: DropdownButtonFormField<String>(
                    value: currCond,
                    decoration: const InputDecoration(labelText: 'Kondisi Sesudah'),
                    items: conditions.map((c) => DropdownMenuItem(value: c,
                      child: Text(AppTheme.getKondisiLabel(c),
                        style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12)))).toList(),
                    onChanged: (v) => setS(() => currCond = v ?? 'RUSAK_RINGAN'),
                  )),
                ]),
                const SizedBox(height: 12),
                // Date picker
                const Text('Tanggal Pengecekan', style: TextStyle(
                  fontFamily: AppTheme.fontFamily, fontSize: 12,
                  fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: checkDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (c, child) => Theme(
                        data: Theme.of(c).copyWith(colorScheme:
                          Theme.of(c).colorScheme.copyWith(primary: AppTheme.primary)),
                        child: child!),
                    );
                    if (picked != null) setS(() => checkDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFDDD8FF)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(DateFormat('dd MMMM yyyy', 'id').format(checkDate),
                        style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
                      const Spacer(),
                      const Icon(Icons.edit_rounded, size: 14, color: AppTheme.textMuted),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                _formField('Dicek Oleh', byCtrl, 'EMP001'),
                const SizedBox(height: 12),
                _formField('Catatan', noteCtrl, 'Catatan kondisi...'),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Batal'),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: LoadingButton(
                    isLoading: loading,
                    text: 'Simpan',
                    onPressed: () async {
                      setS(() => loading = true);
                      try {
                        await RemoteHelper.getDio().post('api/condition-logs', data: {
                          'id': idCtrl.text,
                          'equipmentId': eqCtrl.text,
                          'previousCondition': prevCond,
                          'currentCondition': currCond,
                          'checkDate': checkDate.toIso8601String(),
                          'checkedBy': byCtrl.text,
                          'note': noteCtrl.text.isNotEmpty ? noteCtrl.text : null,
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadLogs();
                      } catch (_) {
                        setS(() => loading = false);
                      }
                    },
                  )),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formField(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: AppTheme.fontFamily,
          fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        TextField(controller: ctrl, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13),
          decoration: InputDecoration(hintText: hint)),
      ],
    );
  }
}