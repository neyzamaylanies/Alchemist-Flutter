// lib/screens/transaction/transaction_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ui/transaction.dart';
import '../../repositories/transaction_repository.dart';
import '../../utils/remote_helper.dart';
import '../../utils/app_theme.dart';

// ── Bottom sheet launcher ──────────────────────────────────────────────────
Future<dynamic> showTransactionForm(
  BuildContext context, {
  Transaction? transaction,
  Map<String, String> equipmentNames = const {},
  Map<String, String> studentNames   = const {},
  Map<String, String> userNames      = const {},
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TransactionFormSheet(
      transaction: transaction,
      equipmentNames: equipmentNames,
      studentNames:   studentNames,
      userNames:      userNames,
    ),
  );
}

// ── Wrapper page (dipakai routes) ──────────────────────────────────────────
class TransactionDetailPage extends StatelessWidget {
  final Transaction? transaction;
  final Map<String, String> equipmentNames;
  final Map<String, String> studentNames;
  final Map<String, String> userNames;

  const TransactionDetailPage({
    super.key,
    required this.transaction,
    this.equipmentNames = const {},
    this.studentNames   = const {},
    this.userNames      = const {},
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showTransactionForm(context,
        transaction: transaction,
        equipmentNames: equipmentNames,
        studentNames:   studentNames,
        userNames:      userNames,
      ).then((result) {
        if (context.mounted) Navigator.pop(context, result);
      });
    });
    return const Scaffold(backgroundColor: Colors.transparent);
  }
}

// ── Form bottom sheet ──────────────────────────────────────────────────────
class _TransactionFormSheet extends StatefulWidget {
  final Transaction? transaction;
  final Map<String, String> equipmentNames;
  final Map<String, String> studentNames;
  final Map<String, String> userNames;

  const _TransactionFormSheet({
    this.transaction,
    this.equipmentNames = const {},
    this.studentNames   = const {},
    this.userNames      = const {},
  });

  @override
  State<_TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<_TransactionFormSheet> {
  bool _isLoading = false;

  final _idController       = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _noteController     = TextEditingController();

  String  _selectedType        = 'OUT';
  String? _selectedEquipmentId;
  String? _selectedStudentId;
  String? _selectedUserId;
  DateTime _selectedDate       = DateTime.now();

  final TransactionRepository _repository = TransactionRepository(RemoteHelper.getDio());

  bool get _isEdit => widget.transaction != null;

  String _generateTransactionId() {
    final now  = DateTime.now();
    final y    = now.year.toString();
    final m    = now.month.toString().padLeft(2, '0');
    final d    = now.day.toString().padLeft(2, '0');
    final rand = (now.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    return 'TRX' + y + m + d + rand;
  }

  @override
  void initState() {
    super.initState();
    if (!_isEdit) {
      _idController.text = _generateTransactionId();
    } else {
      final t = widget.transaction!;
      _idController.text       = t.id;
      _quantityController.text = t.quantity.toString();
      _noteController.text     = t.note ?? '';
      _selectedType            = t.transactionType;
      _selectedEquipmentId     = t.equipmentId;
      _selectedStudentId       = t.usedBy;
      _selectedUserId          = t.handledBy;
      if (t.transactionDate != null) {
        _selectedDate = DateTime.tryParse(t.transactionDate!) ?? DateTime.now();
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020), lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppTheme.primary)),
        child: child!),
    );
    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day,
          time?.hour ?? _selectedDate.hour, time?.minute ?? _selectedDate.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final sheetBg   = isDark ? AppTheme.darkSurface : Colors.white;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor  = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;

    final equipmentList = widget.equipmentNames.entries.toList();
    final studentList   = widget.studentNames.entries.toList();
    final userList      = widget.userNames.entries.toList();

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(16, 0, 16,
        MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBorder : Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
            )),

            Text(_isEdit ? 'Detail Transaksi' : 'Catat Transaksi',
              style: TextStyle(fontFamily: AppTheme.fontFamily,
                fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
            const SizedBox(height: 16),

            // ID (read-only)
            _label('ID Transaksi', subColor),
            _readOnlyBox(_idController.text, isDark),
            const SizedBox(height: 14),

            // Tipe
            _label('Tipe Transaksi', subColor),
            const SizedBox(height: 6),
            _isEdit
              ? _readOnlyBox(_selectedType == 'OUT' ? 'OUT — Peminjaman' : 'IN — Pengembalian', isDark)
              : _dropdownField<String>(
                  value: _selectedType, hint: 'Pilih tipe...', isDark: isDark,
                  items: const [
                    DropdownMenuItem(value: 'OUT', child: Text('OUT — Peminjaman')),
                    DropdownMenuItem(value: 'IN',  child: Text('IN — Pengembalian')),
                  ],
                  onChanged: (v) => setState(() => _selectedType = v ?? 'OUT'),
                ),
            const SizedBox(height: 14),

            // Alat
            _label('Alat', subColor),
            const SizedBox(height: 6),
            _isEdit
              ? _readOnlyBox(widget.equipmentNames[_selectedEquipmentId] ?? _selectedEquipmentId ?? '-', isDark)
              : _dropdownField<String>(
                  value: _selectedEquipmentId, hint: 'Pilih alat...', isDark: isDark,
                  items: equipmentList.map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text('${e.value} (${e.key})',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                      overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedEquipmentId = v),
                ),
            const SizedBox(height: 14),

            // Jumlah
            _label('Jumlah', subColor),
            _inputField(controller: _quantityController, hint: '1',
              isDark: isDark, textColor: textColor,
              readOnly: _isEdit, keyboardType: TextInputType.number),
            const SizedBox(height: 14),

            // Tanggal
            _label('Tanggal Transaksi', subColor),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _isEdit ? null : _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurfaceVar : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0)),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_today_rounded, size: 17,
                    color: _isEdit ? subColor : AppTheme.primary),
                  const SizedBox(width: 10),
                  Text(DateFormat('dd MMMM yyyy, HH:mm', 'id').format(_selectedDate),
                    style: TextStyle(fontFamily: AppTheme.fontFamily,
                      fontSize: 13, color: _isEdit ? subColor : textColor)),
                  if (!_isEdit) ...[const Spacer(),
                    Icon(Icons.chevron_right_rounded, size: 18, color: subColor)],
                ]),
              ),
            ),
            const SizedBox(height: 14),

            // Petugas
            _label('Petugas', subColor),
            const SizedBox(height: 6),
            _isEdit
              ? _readOnlyBox(widget.userNames[_selectedUserId] ?? _selectedUserId ?? '-', isDark)
              : _dropdownField<String>(
                  value: _selectedUserId, hint: 'Pilih petugas...', isDark: isDark,
                  items: userList.map((u) => DropdownMenuItem(
                    value: u.key,
                    child: Text(u.value, style: TextStyle(fontFamily: AppTheme.fontFamily,
                      fontSize: 13, color: textColor)),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedUserId = v),
                ),
            const SizedBox(height: 14),

            // Mahasiswa
            _label('Mahasiswa (opsional)', subColor),
            const SizedBox(height: 6),
            _isEdit
              ? _readOnlyBox(_selectedStudentId != null
                  ? (widget.studentNames[_selectedStudentId!] ?? _selectedStudentId!) : '-', isDark)
              : _dropdownField<String?>(
                  value: _selectedStudentId, hint: 'Pilih mahasiswa...', isDark: isDark,
                  items: [
                    DropdownMenuItem<String?>(value: null,
                      child: Text('— Tidak ada —', style: TextStyle(
                        fontFamily: AppTheme.fontFamily, fontSize: 13, color: subColor))),
                    ...studentList.map((s) => DropdownMenuItem<String?>(
                      value: s.key,
                      child: Text(s.value, style: TextStyle(fontFamily: AppTheme.fontFamily,
                        fontSize: 13, color: textColor)))),
                  ],
                  onChanged: (v) => setState(() => _selectedStudentId = v),
                ),
            const SizedBox(height: 14),

            // Catatan
            _label('Catatan (opsional)', subColor),
            _inputField(controller: _noteController, hint: 'Catatan transaksi',
              isDark: isDark, textColor: textColor, readOnly: _isEdit, maxLines: 2),
            const SizedBox(height: 20),

            // Tombol simpan
            if (!_isEdit)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSaveClick,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Simpan Transaksi',
                        style: TextStyle(fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: TextStyle(fontFamily: AppTheme.fontFamily,
      fontSize: 12, fontWeight: FontWeight.w500, color: color)),
  );

  Widget _readOnlyBox(String value, bool isDark) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: BoxDecoration(
      color: isDark ? AppTheme.darkSurfaceVar : const Color(0xFFF0F0F8),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0)),
    ),
    child: Text(value, style: const TextStyle(fontFamily: AppTheme.fontFamily,
      fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary)),
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required Color textColor,
    bool readOnly = false,
    int maxLines  = 1,
    TextInputType keyboardType = TextInputType.text,
  }) => TextField(
    controller: controller,
    readOnly: readOnly,
    maxLines: maxLines,
    keyboardType: keyboardType,
    style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: readOnly
        ? (isDark ? AppTheme.darkSurfaceVar : const Color(0xFFF0F0F8))
        : (isDark ? AppTheme.darkSurfaceVar : Colors.white),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
    ),
  );

  Widget _dropdownField<T>({
    required T? value,
    required String hint,
    required bool isDark,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) => DropdownButtonFormField<T>(
    value: value,
    isExpanded: true,
    hint: Text(hint, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13,
      color: isDark ? AppTheme.darkTextSub : const Color(0xFFB0B0C0))),
    decoration: InputDecoration(
      filled: true,
      fillColor: isDark ? AppTheme.darkSurfaceVar : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
    ),
    items: items,
    onChanged: onChanged,
  );

  void _onSaveClick() async {
    if (_selectedEquipmentId == null) { _showMessage('Pilih alat!'); return; }
    if (_selectedUserId == null)      { _showMessage('Pilih petugas!'); return; }

    setState(() => _isLoading = true);
    final data = {
      'id':              _idController.text.trim(),
      'equipmentId':     _selectedEquipmentId,
      'transactionType': _selectedType,
      'quantity':        int.tryParse(_quantityController.text) ?? 1,
      'transactionDate': _selectedDate.toIso8601String(),
      'handledBy':       _selectedUserId,
      'usedBy':          _selectedStudentId,
      'note': _noteController.text.isNotEmpty ? _noteController.text : null,
    };

    final result = await _repository.createTransaction(data);
    setState(() => _isLoading = false);

    if (result.isSuccess && result.data != null) {
      if (!mounted) return;
      Navigator.pop(context,
        TransactionCreatedResult(transaction: Transaction.fromRemote(result.data!)));
    } else {
      _showMessage(result.message.isNotEmpty ? result.message : 'Gagal menyimpan transaksi!');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: AppTheme.fontFamily)),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

class TransactionCreatedResult {
  final Transaction transaction;
  TransactionCreatedResult({required this.transaction});
}