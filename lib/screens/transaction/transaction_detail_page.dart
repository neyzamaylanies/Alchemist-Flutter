// lib/screens/transaction/transaction_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ui/transaction.dart';
import '../../repositories/transaction_repository.dart';
import '../../utils/remote_helper.dart';
import '../../utils/app_theme.dart';
import '../../widgets/loading_button.dart';

class TransactionDetailPage extends StatefulWidget {
  final Transaction? transaction;
  // Lookup maps dari parent (sudah di-fetch di list page)
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
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  bool _isLoading = false;

  final _idController       = TextEditingController();

  /// Generate ID format: TRX + YYYYMMDD + 3 digit = 14 karakter (max 15)
  String _generateTransactionId() {
    final now = DateTime.now();
    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final rand = (now.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    return 'TRX' + y + m + d + rand;
  }
  final _quantityController = TextEditingController(text: '1');
  final _noteController     = TextEditingController();

  String  _selectedType        = 'OUT';
  String? _selectedEquipmentId;
  String? _selectedStudentId;
  String? _selectedUserId;
  DateTime _selectedDate       = DateTime.now();

  final TransactionRepository _repository = TransactionRepository(RemoteHelper.getDio());

  bool get _isEdit => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (!_isEdit) {
      // Auto-generate ID saat buka form tambah baru
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      setState(() {
        _selectedDate = DateTime(
          picked.year, picked.month, picked.day,
          time?.hour ?? _selectedDate.hour,
          time?.minute ?? _selectedDate.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor  = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;

    // Siapkan list untuk dropdown
    final equipmentList = widget.equipmentNames.entries.toList();
    final studentList   = widget.studentNames.entries.toList();
    final userList      = widget.userNames.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Detail Transaksi' : 'Catat Transaksi',
          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.surface,
        foregroundColor: isDark ? AppTheme.darkText : AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── ID Transaksi (auto-generate, readonly saat add) ──
              Row(children: [
                Text('ID Transaksi', style: TextStyle(fontFamily: AppTheme.fontFamily,
                  fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
                const SizedBox(width: 6),
                if (!_isEdit)
                  Tooltip(
                    message: 'ID otomatis dibuat oleh sistem',
                    child: Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.primary),
                  ),
              ]),
              const SizedBox(height: 6),
              TextField(
                controller: _idController,
                readOnly: true, // selalu readonly — auto-generate saat add, fix saat view
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13,
                  color: _isEdit ? textColor : AppTheme.primary),
                decoration: InputDecoration(
                  hintText: 'Auto-generate',
                  suffixIcon: _isEdit ? null : Icon(Icons.auto_awesome_rounded,
                    size: 16, color: AppTheme.primary),
                  filled: true,
                  fillColor: AppTheme.primary.withValues(alpha: 0.05),
                ),
              ),
              const SizedBox(height: 16),

              // ── Tipe ─────────────────────────────────────
              _label('Tipe Transaksi', textColor),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? AppTheme.darkSurfaceVar : AppTheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFDDD8FF))),
                ),
                items: const [
                  DropdownMenuItem(value: 'OUT', child: Text('OUT — Peminjaman')),
                  DropdownMenuItem(value: 'IN',  child: Text('IN — Pengembalian')),
                ],
                onChanged: _isEdit ? null : (v) => setState(() => _selectedType = v ?? 'OUT'),
              ),
              const SizedBox(height: 16),

              // ── Pilih Alat (dropdown nama, kirim ID) ─────
              _label('Alat', textColor),
              const SizedBox(height: 8),
              _isEdit
                ? _readonlyField(
                    widget.equipmentNames[_selectedEquipmentId] ?? _selectedEquipmentId ?? '-',
                    subColor)
                : DropdownButtonFormField<String>(
                    value: _selectedEquipmentId,
                    hint: Text('Pilih alat...', style: TextStyle(color: subColor, fontFamily: AppTheme.fontFamily)),
                    isExpanded: true,
                    decoration: _dropdownDecor(isDark),
                    items: equipmentList.map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text('${e.value} (${e.key})',
                        style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                        overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedEquipmentId = v),
                  ),
              const SizedBox(height: 16),

              // ── Jumlah ────────────────────────────────────
              _label('Jumlah', textColor),
              TextField(
                controller: _quantityController,
                readOnly: _isEdit,
                keyboardType: TextInputType.number,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                decoration: const InputDecoration(hintText: '1'),
              ),
              const SizedBox(height: 16),

              // ── Tanggal ───────────────────────────────────
              _label('Tanggal Transaksi', textColor),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isEdit ? null : _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurfaceVar : AppTheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : const Color(0xFFDDD8FF)),
                  ),
                  child: Row(children: [
                    Icon(Icons.calendar_today_rounded, size: 18,
                      color: _isEdit ? subColor : AppTheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('dd MMMM yyyy, HH:mm', 'id').format(_selectedDate),
                      style: TextStyle(fontFamily: AppTheme.fontFamily,
                        fontSize: 14, color: _isEdit ? subColor : textColor)),
                    if (!_isEdit) ...[
                      const Spacer(),
                      Icon(Icons.edit_rounded, size: 16, color: subColor),
                    ],
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // ── Petugas (dropdown nama, kirim ID) ────────
              _label('Petugas', textColor),
              const SizedBox(height: 8),
              _isEdit
                ? _readonlyField(
                    widget.userNames[_selectedUserId] ?? _selectedUserId ?? '-',
                    subColor)
                : DropdownButtonFormField<String>(
                    value: _selectedUserId,
                    hint: Text('Pilih petugas...', style: TextStyle(color: subColor, fontFamily: AppTheme.fontFamily)),
                    isExpanded: true,
                    decoration: _dropdownDecor(isDark),
                    items: userList.map((u) => DropdownMenuItem(
                      value: u.key,
                      child: Text(u.value,
                        style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor)),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedUserId = v),
                  ),
              const SizedBox(height: 16),

              // ── Mahasiswa (dropdown nama, kirim ID, opsional) ──
              _label('Mahasiswa (opsional)', textColor),
              const SizedBox(height: 8),
              _isEdit
                ? _readonlyField(
                    _selectedStudentId != null
                      ? (widget.studentNames[_selectedStudentId!] ?? _selectedStudentId!)
                      : '-',
                    subColor)
                : DropdownButtonFormField<String>(
                    value: _selectedStudentId,
                    hint: Text('Pilih mahasiswa...', style: TextStyle(color: subColor, fontFamily: AppTheme.fontFamily)),
                    isExpanded: true,
                    decoration: _dropdownDecor(isDark),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('— Tidak ada —',
                          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: subColor)),
                      ),
                      ...studentList.map((s) => DropdownMenuItem(
                        value: s.key,
                        child: Text(s.value,
                          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor)),
                      )),
                    ],
                    onChanged: (v) => setState(() => _selectedStudentId = v),
                  ),
              const SizedBox(height: 16),

              // ── Catatan ───────────────────────────────────
              _label('Catatan (opsional)', textColor),
              TextField(
                controller: _noteController,
                readOnly: _isEdit,
                maxLines: 2,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                decoration: const InputDecoration(hintText: 'Catatan transaksi'),
              ),
              const SizedBox(height: 24),

              if (!_isEdit)
                SizedBox(
                  width: double.infinity,
                  child: LoadingButton(
                    isLoading: _isLoading,
                    onPressed: _onSaveClick,
                    text: 'Simpan Transaksi',
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Readonly display (mode view) ──────────────────────────────────────────
  Widget _readonlyField(String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(value, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: color)),
    );
  }

  InputDecoration _dropdownDecor(bool isDark) => InputDecoration(
    filled: true,
    fillColor: isDark ? AppTheme.darkSurfaceVar : AppTheme.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFDDD8FF))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFDDD8FF))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
  );

  Widget _label(String text, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: TextStyle(fontFamily: AppTheme.fontFamily,
      fontSize: 13, fontWeight: FontWeight.w500, color: color)),
  );

  // ── Save ──────────────────────────────────────────────────────────────────
  void _onSaveClick() async {
    if (_idController.text.isEmpty) {
      _showMessage('ID Transaksi wajib diisi!'); return;
    }
    if (_selectedEquipmentId == null) {
      _showMessage('Pilih alat terlebih dahulu!'); return;
    }
    if (_selectedUserId == null) {
      _showMessage('Pilih petugas terlebih dahulu!'); return;
    }

    setState(() => _isLoading = true);

    final data = {
      'id':              _idController.text.trim(),
      'equipmentId':     _selectedEquipmentId,       // kirim ID ke API
      'transactionType': _selectedType,
      'quantity':        int.tryParse(_quantityController.text) ?? 1,
      'transactionDate': _selectedDate.toIso8601String(),
      'handledBy':       _selectedUserId,            // kirim ID ke API
      'usedBy':          _selectedStudentId,         // kirim ID ke API (nullable)
      'note':            _noteController.text.isNotEmpty ? _noteController.text : null,
    };

    final result = await _repository.createTransaction(data);
    setState(() => _isLoading = false);

    if (result.isSuccess && result.data != null) {
      final transaction = Transaction.fromRemote(result.data!);
      if (!mounted) return;
      Navigator.pop(context, TransactionCreatedResult(transaction: transaction));
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