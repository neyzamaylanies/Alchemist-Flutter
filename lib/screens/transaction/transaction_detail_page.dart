// lib/screens/transaction/transaction_detail_page.dart
import 'package:flutter/material.dart';
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
  late ThemeData _theme;
  bool _isLoading = false;

  final _idController = TextEditingController();
  final _equipmentIdController = TextEditingController();
  final _quantityController = TextEditingController();
  final _handledByController = TextEditingController();
  final _usedByController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedType = "OUT";

  final TransactionRepository _repository = TransactionRepository(RemoteHelper.getDio());

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _idController.text = widget.transaction!.id;
      _equipmentIdController.text = widget.transaction!.equipmentId;
      _quantityController.text = widget.transaction!.quantity.toString();
      _handledByController.text = widget.transaction!.handledBy;
      _usedByController.text = widget.transaction!.usedBy ?? "";
      _noteController.text = widget.transaction!.note ?? "";
      _selectedType = widget.transaction!.transactionType;
    }
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.navyDark,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.transaction == null ? "Catat Transaksi" : "Detail Transaksi",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ID Transaksi", style: _theme.textTheme.labelMedium),
              TextField(controller: _idController, decoration: const InputDecoration(hintText: "Contoh: TRX20250101001")),
              const SizedBox(height: 16),
              Text("Tipe Transaksi", style: _theme.textTheme.labelMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: "OUT", child: Text("OUT - Peminjaman")),
                  DropdownMenuItem(value: "IN", child: Text("IN - Pengembalian")),
                ],
                onChanged: (val) => setState(() => _selectedType = val ?? "OUT"),
              ),
              const SizedBox(height: 16),
              Text("ID Alat", style: _theme.textTheme.labelMedium),
              TextField(controller: _equipmentIdController, decoration: const InputDecoration(hintText: "Masukkan ID alat")),
              const SizedBox(height: 16),
              Text("Jumlah", style: _theme.textTheme.labelMedium),
              TextField(controller: _quantityController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "1")),
              const SizedBox(height: 16),
              Text("ID Petugas (handledBy)", style: _theme.textTheme.labelMedium),
              TextField(controller: _handledByController, decoration: const InputDecoration(hintText: "Contoh: EMP001")),
              const SizedBox(height: 16),
              Text("ID Mahasiswa (usedBy) - opsional", style: _theme.textTheme.labelMedium),
              TextField(controller: _usedByController, decoration: const InputDecoration(hintText: "Contoh: STU001")),
              const SizedBox(height: 16),
              Text("Catatan (opsional)", style: _theme.textTheme.labelMedium),
              TextField(controller: _noteController, maxLines: 2, decoration: const InputDecoration(hintText: "Catatan transaksi")),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: LoadingButton(isLoading: _isLoading, onPressed: _onSaveClick, text: "Simpan Transaksi")),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _onSaveClick() async {
    if (_idController.text.isEmpty || _equipmentIdController.text.isEmpty || _handledByController.text.isEmpty) {
      _showMessage("ID, alat, dan petugas wajib diisi!");
      return;
    }
    setState(() => _isLoading = true);
    var data = {
      "id": _idController.text,
      "equipmentId": _equipmentIdController.text,
      "transactionType": _selectedType,
      "quantity": int.tryParse(_quantityController.text) ?? 1,
      "handledBy": _handledByController.text,
      "usedBy": _usedByController.text.isNotEmpty ? _usedByController.text : null,
      "note": _noteController.text.isNotEmpty ? _noteController.text : null,
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class TransactionCreatedResult {
  final Transaction transaction;
  TransactionCreatedResult({required this.transaction});
}