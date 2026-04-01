// lib/screens/condition_log/condition_log_list_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';
import '../../widgets/data_table_card.dart';

class ConditionLogListPage extends StatefulWidget {
  const ConditionLogListPage({super.key});

  @override
  State<ConditionLogListPage> createState() => _ConditionLogListPageState();
}

class _ConditionLogListPageState extends State<ConditionLogListPage> {
  List<dynamic> _logs     = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  String _search  = '';

  Map<String, String> _equipmentNames = {};
  Map<String, String> _userNames      = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final dio     = RemoteHelper.getDio();
      final results = await Future.wait([
        dio.get('api/condition-logs'),
        dio.get('api/equipments'),
        dio.get('api/users'),
      ]);
      final logs = (results[0].data['data'] as List<dynamic>?) ?? [];
      logs.sort((a, b) {
        final dA = DateTime.tryParse(a['checkDate'] ?? '') ?? DateTime(2000);
        final dB = DateTime.tryParse(b['checkDate'] ?? '') ?? DateTime(2000);
        return dB.compareTo(dA);
      });
      final eqMap   = <String, String>{};
      for (final e in (results[1].data['data'] as List<dynamic>? ?? [])) {
        eqMap[e['id'] ?? ''] = e['equipmentName'] ?? e['id'] ?? '';
      }
      final userMap = <String, String>{};
      for (final u in (results[2].data['data'] as List<dynamic>? ?? [])) {
        userMap[u['id'] ?? ''] = u['name'] ?? u['id'] ?? '';
      }
      if (mounted) setState(() {
        _logs = logs; _filtered = logs;
        _equipmentNames = eqMap; _userNames = userMap;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearch(String q) {
    setState(() {
      _search   = q.toLowerCase();
      _filtered = _logs.where((l) {
        final eq   = _equipmentNames[l['equipmentId'] ?? '']?.toLowerCase() ?? '';
        final user = _userNames[l['checkedBy'] ?? '']?.toLowerCase() ?? '';
        return (l['id'] ?? '').toLowerCase().contains(_search) ||
            eq.contains(_search) || user.contains(_search);
      }).toList();
    });
  }

  String _nextLogId() {
    final today   = DateTime.now();
    final dateStr = '${today.year}${today.month.toString().padLeft(2,'0')}${today.day.toString().padLeft(2,'0')}';
    final prefix  = 'LOG$dateStr';
    int max = 0;
    for (final log in _logs) {
      final id = (log['id'] ?? '') as String;
      if (id.startsWith(prefix)) {
        final num = int.tryParse(id.substring(prefix.length)) ?? 0;
        if (num > max) max = num;
      }
    }
    return '$prefix${(max + 1).toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor  = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.background,
      appBar: AppBar(
        title: const Text('Log Kondisi Alat',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        foregroundColor: isDark ? AppTheme.darkText : AppTheme.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(children: [
              Expanded(
                child: TextField(
                  onChanged: _onSearch,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Cari log kondisi...',
                    prefixIcon: Icon(Icons.search_rounded, size: 18, color: subColor),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    constraints: const BoxConstraints(maxHeight: 42),
                    filled: true,
                    fillColor: isDark ? AppTheme.darkSurfaceVar : AppTheme.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showCreateBottomSheet(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Catat',
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ]),
          ),
          Expanded(child: DataTableCard(
            isLoading: _isLoading,
            emptyMessage: 'Belum ada log kondisi',
            emptyIcon: Icons.assignment_rounded,
            headers: const ['LOG ID', 'ALAT', 'SEBELUM', 'SESUDAH', 'TGL CEK', 'DICEK OLEH'],
            rows: _filtered.map((l) {
              final before   = l['previousCondition'] ?? '-';
              final after    = l['currentCondition']  ?? '-';
              final date     = (l['checkDate'] ?? '').toString().split('T').first;
              final eqName   = _equipmentNames[l['equipmentId']] ?? l['equipmentId'] ?? '-';
              final userName = _userNames[l['checkedBy']] ?? l['checkedBy'] ?? '-';
              return [
                Text(l['id'] ?? '', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: subColor)),
                Text(eqName, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                StatusBadge(label: AppTheme.getKondisiLabel(before), color: AppTheme.getKondisiColor(before)),
                StatusBadge(label: AppTheme.getKondisiLabel(after),  color: AppTheme.getKondisiColor(after)),
                Text(date, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: subColor)),
                Text(userName, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: textColor)),
              ];
            }).toList(),
          )),
        ],
      ),
    );
  }

  void _showCreateBottomSheet(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final generatedId = _nextLogId();
    final eqCtrl      = TextEditingController();
    final byCtrl      = TextEditingController();
    final noteCtrl    = TextEditingController();
    String prevCond   = 'BAIK';
    String currCond   = 'RUSAK_RINGAN';
    DateTime checkDate = DateTime.now();
    bool loading = false;
    const conditions = ['BAIK', 'RUSAK_RINGAN', 'RUSAK_BERAT', 'DALAM_PERBAIKAN'];

    final borderColor  = isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0);
    final fillColor    = isDark ? AppTheme.darkSurfaceVar : Colors.white;
    final subColor     = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;
    final textColor    = isDark ? AppTheme.darkText : AppTheme.textPrimary;

    InputDecoration _dropDeco(String label) => InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: subColor),
      filled: true, fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkBorder : const Color(0xFFE0E0E8),
                    borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),

                // Judul
                Text('Catat Kondisi Alat', style: TextStyle(
                  fontFamily: AppTheme.fontFamily, fontSize: 16,
                  fontWeight: FontWeight.w700, color: textColor)),
                const SizedBox(height: 20),

                // ID Log (read-only)
                Text('ID Log', style: TextStyle(fontFamily: AppTheme.fontFamily,
                  fontSize: 12, fontWeight: FontWeight.w500, color: subColor)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurfaceVar : const Color(0xFFF0F0F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(generatedId, style: const TextStyle(
                    fontFamily: AppTheme.fontFamily, fontSize: 13,
                    fontWeight: FontWeight.w600, color: AppTheme.primary)),
                ),
                const SizedBox(height: 14),

                // Alat
                Text('Alat', style: TextStyle(fontFamily: AppTheme.fontFamily,
                  fontSize: 12, fontWeight: FontWeight.w500, color: subColor)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  hint: Text('Pilih alat...', style: TextStyle(fontFamily: AppTheme.fontFamily,
                    fontSize: 13, color: subColor)),
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true, fillColor: fillColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                  ),
                  items: _equipmentNames.entries.map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text('${e.value} (${e.key})',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                      overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => eqCtrl.text = v ?? '',
                ),
                const SizedBox(height: 14),

                // Kondisi Sebelum & Sesudah
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Kondisi Sebelum', style: TextStyle(fontFamily: AppTheme.fontFamily,
                      fontSize: 12, fontWeight: FontWeight.w500, color: subColor)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: prevCond,
                      isExpanded: true,
                      decoration: _dropDeco(''),
                      items: conditions.map((c) => DropdownMenuItem(value: c,
                        child: Text(AppTheme.getKondisiLabel(c),
                          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: textColor)))).toList(),
                      onChanged: (v) => setS(() => prevCond = v ?? 'BAIK'),
                    ),
                  ])),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Kondisi Sesudah', style: TextStyle(fontFamily: AppTheme.fontFamily,
                      fontSize: 12, fontWeight: FontWeight.w500, color: subColor)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: currCond,
                      isExpanded: true,
                      decoration: _dropDeco(''),
                      items: conditions.map((c) => DropdownMenuItem(value: c,
                        child: Text(AppTheme.getKondisiLabel(c),
                          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: textColor)))).toList(),
                      onChanged: (v) => setS(() => currCond = v ?? 'RUSAK_RINGAN'),
                    ),
                  ])),
                ]),
                const SizedBox(height: 14),

                // Tanggal Pengecekan
                Text('Tanggal Pengecekan', style: TextStyle(fontFamily: AppTheme.fontFamily,
                  fontSize: 12, fontWeight: FontWeight.w500, color: subColor)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx, initialDate: checkDate,
                      firstDate: DateTime(2020), lastDate: DateTime(2030),
                      builder: (c, child) => Theme(
                        data: Theme.of(c).copyWith(colorScheme:
                          Theme.of(c).colorScheme.copyWith(primary: AppTheme.primary)),
                        child: child!),
                    );
                    if (picked != null) setS(() => checkDate = picked);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_rounded, size: 17, color: AppTheme.primary),
                      const SizedBox(width: 10),
                      Text(DateFormat('dd MMMM yyyy', 'id').format(checkDate),
                        style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor)),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded, size: 18, color: subColor),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),

                // Dicek Oleh
                Text('Dicek Oleh', style: TextStyle(fontFamily: AppTheme.fontFamily,
                  fontSize: 12, fontWeight: FontWeight.w500, color: subColor)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  hint: Text('Pilih petugas...', style: TextStyle(fontFamily: AppTheme.fontFamily,
                    fontSize: 13, color: subColor)),
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true, fillColor: fillColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                  ),
                  items: _userNames.entries.map((u) => DropdownMenuItem(
                    value: u.key,
                    child: Text(u.value, style: TextStyle(fontFamily: AppTheme.fontFamily,
                      fontSize: 13, color: textColor)))).toList(),
                  onChanged: (v) => byCtrl.text = v ?? '',
                ),
                const SizedBox(height: 14),

                // Catatan
                Text('Catatan (opsional)', style: TextStyle(fontFamily: AppTheme.fontFamily,
                  fontSize: 12, fontWeight: FontWeight.w500, color: subColor)),
                const SizedBox(height: 6),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Catatan kondisi...',
                    hintStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: subColor),
                    filled: true, fillColor: fillColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Batal & Simpan
                Row(children: [
                  Expanded(child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Batal',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(
                    onPressed: loading ? null : () async {
                      if (eqCtrl.text.isEmpty || byCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Alat dan Petugas wajib diisi!')));
                        return;
                      }
                      setS(() => loading = true);
                      try {
                        await RemoteHelper.getDio().post('api/condition-logs', data: {
                          'id':                generatedId,
                          'equipmentId':       eqCtrl.text,
                          'previousCondition': prevCond,
                          'currentCondition':  currCond,
                          'checkDate':         checkDate.toIso8601String(),
                          'checkedBy':         byCtrl.text,
                          'note': noteCtrl.text.isNotEmpty ? noteCtrl.text : null,
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadAll();
                      } catch (_) {
                        setS(() => loading = false);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Gagal menyimpan!')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan',
                          style: TextStyle(fontFamily: AppTheme.fontFamily,
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  )),
                ]),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}