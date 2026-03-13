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
  const TransactionDetailPage({super.key, required this.transaction});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  bool _isLoading = false;

  final _idController          = TextEditingController();
  final _equipmentIdController = TextEditingController();
  final _quantityController    = TextEditingController();
  final _handledByController   = TextEditingController();
  final _usedByController      = TextEditingController();
  final _noteController        = TextEditingController();

  String _selectedType = 'OUT';
  DateTime _selectedDate = DateTime.now();

  final TransactionRepository _repository = TransactionRepository(RemoteHelper.getDio());

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _idController.text          = t.id;
      _equipmentIdController.text = t.equipmentId;
      _quantityController.text    = t.quantity.toString();
      _handledByController.text   = t.handledBy;
      _usedByController.text      = t.usedBy ?? '';
      _noteController.text        = t.note ?? '';
      _selectedType               = t.transactionType;
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
    if (picked != null) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor  = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;
    final isEdit    = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Detail Transaksi' : 'Catat Transaksi',
          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('ID Transaksi', textColor),
              TextField(controller: _idController, readOnly: isEdit,
                decoration: const InputDecoration(hintText: 'Contoh: TRX20250101001')),
              const SizedBox(height: 16),

              _label('Tipe Transaksi', textColor),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'OUT', child: Text('OUT - Peminjaman')),
                  DropdownMenuItem(value: 'IN',  child: Text('IN - Pengembalian')),
                ],
                onChanged: isEdit ? null : (v) => setState(() => _selectedType = v ?? 'OUT'),
              ),
              const SizedBox(height: 16),

              _label('ID Alat', textColor),
              TextField(controller: _equipmentIdController, readOnly: isEdit,
                decoration: const InputDecoration(hintText: 'Masukkan ID alat')),
              const SizedBox(height: 16),

              _label('Jumlah', textColor),
              TextField(controller: _quantityController, readOnly: isEdit,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '1')),
              const SizedBox(height: 16),

              _label('Tanggal Transaksi', textColor),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: isEdit ? null : _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurfaceVar : AppTheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : const Color(0xFFDDD8FF),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 18,
                        color: isEdit ? subColor : AppTheme.primary),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('dd MMMM yyyy, HH:mm', 'id').format(_selectedDate),
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          color: isEdit ? subColor : textColor,
                        ),
                      ),
                      if (!isEdit) ...[
                        const Spacer(),
                        Icon(Icons.edit_rounded, size: 16, color: subColor),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _label('ID Petugas', textColor),
              TextField(controller: _handledByController, readOnly: isEdit,
                decoration: const InputDecoration(hintText: 'Contoh: EMP001')),
              const SizedBox(height: 16),

              _label('ID Mahasiswa (opsional)', textColor),
              TextField(controller: _usedByController, readOnly: isEdit,
                decoration: const InputDecoration(hintText: 'Contoh: STU001')),
              const SizedBox(height: 16),

              _label('Catatan (opsional)', textColor),
              TextField(controller: _noteController, readOnly: isEdit,
                maxLines: 2,
                decoration: const InputDecoration(hintText: 'Catatan transaksi')),
              const SizedBox(height: 24),

              if (!isEdit)
                Row(children: [
                  Expanded(child: LoadingButton(
                    isLoading: _isLoading,
                    onPressed: _onSaveClick,
                    text: 'Simpan Transaksi',
                  )),
                ]),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(
        fontFamily: AppTheme.fontFamily, fontSize: 13,
        fontWeight: FontWeight.w500, color: color)),
    );
  }

  void _onSaveClick() async {
    if (_idController.text.isEmpty || _equipmentIdController.text.isEmpty || _handledByController.text.isEmpty) {
      _showMessage('ID, alat, dan petugas wajib diisi!');
      return;
    }
    setState(() => _isLoading = true);
    var data = {
      'id': _idController.text,
      'equipmentId': _equipmentIdController.text,
      'transactionType': _selectedType,
      'quantity': int.tryParse(_quantityController.text) ?? 1,
      'transactionDate': _selectedDate.toIso8601String(),
      'handledBy': _handledByController.text,
      'usedBy': _usedByController.text.isNotEmpty ? _usedByController.text : null,
      'note': _noteController.text.isNotEmpty ? _noteController.text : null,
    };
    var result = await _repository.createTransaction(data);
    setState(() => _isLoading = false);
    if (result.isSuccess && result.data != null) {
      final transaction = Transaction.fromRemote(result.data!);
      if (!mounted) return;
      Navigator.pop(context, TransactionCreatedResult(transaction: transaction));
    } else {
      _showMessage(result.message);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class TransactionCreatedResult {
  final Transaction transaction;
  TransactionCreatedResult({required this.transaction});
}