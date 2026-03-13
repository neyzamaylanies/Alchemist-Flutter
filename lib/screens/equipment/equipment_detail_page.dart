// lib/screens/equipment/equipment_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/equipment/equipment_management_bloc.dart';
import '../../models/ui/equipment.dart';
import '../../repositories/equipment_repository.dart';
import '../../utils/remote_helper.dart';
import '../../utils/app_theme.dart';
import '../../widgets/loading_button.dart';

class EquipmentDetailPage extends StatefulWidget {
  final Equipment? equipment;
  const EquipmentDetailPage({super.key, required this.equipment});

  @override
  State<EquipmentDetailPage> createState() => _EquipmentDetailPageState();
}

class _EquipmentDetailPageState extends State<EquipmentDetailPage> {
  bool _isLoading = false;

  final _idController            = TextEditingController();
  final _nameController          = TextEditingController();
  final _categoryIdController    = TextEditingController();
  final _totalQtyController      = TextEditingController();
  final _availableQtyController  = TextEditingController();
  final _locationController      = TextEditingController();

  String _selectedCondition  = 'BAIK';
  DateTime? _purchaseDate;

  final EquipmentManagementBloc _managementBloc = EquipmentManagementBloc(
    equipmentRepository: EquipmentRepository(RemoteHelper.getDio()),
  );

  final List<String> _conditions = ['BAIK', 'RUSAK_RINGAN', 'RUSAK_BERAT', 'DALAM_PERBAIKAN'];

  @override
  void initState() {
    super.initState();
    final eq = widget.equipment;
    if (eq != null) {
      _idController.text           = eq.id;
      _nameController.text         = eq.equipmentName;
      _categoryIdController.text   = eq.categoryId;
      _totalQtyController.text     = eq.totalQuantity.toString();
      _availableQtyController.text = eq.availableQuantity.toString();
      _locationController.text     = eq.location;
      _selectedCondition           = eq.conditionStatus;
      if (eq.purchaseDate != null) {
        _purchaseDate = DateTime.tryParse(eq.purchaseDate!);
      }
    }
  }

  Future<void> _pickPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor  = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;
    final isCreate  = widget.equipment == null;

    return BlocProvider<EquipmentManagementBloc>(
      create: (_) => _managementBloc,
      child: BlocListener<EquipmentManagementBloc, EquipmentManagementState>(
        listener: (context, state) {
          if (state is EquipmentLoading) {
            setState(() => _isLoading = true);
          } else if (state is EquipmentCreatedSuccessful) {
            Navigator.pop(context, EquipmentCreatedResult(equipment: state.equipment));
          } else if (state is EquipmentUpdatedSuccessful) {
            Navigator.pop(context, EquipmentUpdatedResult(equipment: state.equipment));
          } else if (state is EquipmentDeletedSuccessful) {
            Navigator.pop(context, EquipmentDeletedResult(equipment: widget.equipment!));
          } else if (state is EquipmentError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(isCreate ? 'Tambah Alat' : 'Edit Alat',
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
                  if (isCreate) ...[
                    _label('ID Alat', textColor),
                    TextField(controller: _idController,
                      decoration: const InputDecoration(hintText: 'Contoh: EQ001')),
                    const SizedBox(height: 16),
                  ],
                  _label('Nama Alat', textColor),
                  TextField(controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Masukkan nama alat')),
                  const SizedBox(height: 16),

                  _label('ID Kategori', textColor),
                  TextField(controller: _categoryIdController,
                    decoration: const InputDecoration(hintText: 'Contoh: CAT001')),
                  const SizedBox(height: 16),

                  Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Total Qty', textColor),
                        TextField(controller: _totalQtyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0')),
                      ],
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Tersedia', textColor),
                        TextField(controller: _availableQtyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0')),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 16),

                  _label('Lokasi', textColor),
                  TextField(controller: _locationController,
                    decoration: const InputDecoration(hintText: 'Contoh: Lab A Lt.2')),
                  const SizedBox(height: 16),

                  _label('Kondisi', textColor),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCondition,
                    items: _conditions.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(AppTheme.getKondisiLabel(c),
                        style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedCondition = v ?? 'BAIK'),
                  ),
                  const SizedBox(height: 16),

                  // DateTime picker untuk tanggal beli
                  _label('Tanggal Pembelian (opsional)', textColor),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickPurchaseDate,
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
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primary),
                          const SizedBox(width: 10),
                          Text(
                            _purchaseDate != null
                                ? DateFormat('dd MMMM yyyy', 'id').format(_purchaseDate!)
                                : 'Pilih tanggal pembelian',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              color: _purchaseDate != null ? textColor : subColor,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.edit_rounded, size: 16, color: subColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(children: [
                    Expanded(child: LoadingButton(
                      isLoading: _isLoading,
                      onPressed: _onSaveClick,
                      text: isCreate ? 'Tambah Alat' : 'Simpan Perubahan',
                    )),
                  ]),

                  if (!isCreate) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: LoadingButton(
                        isLoading: _isLoading,
                        onPressed: _onDeleteClick,
                        text: 'Hapus Alat',
                        buttonColor: AppTheme.error,
                      )),
                    ]),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
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

  void _onSaveClick() {
    if (widget.equipment == null) {
      _managementBloc.add(CreateEquipmentEvent(
        id: _idController.text,
        equipmentName: _nameController.text,
        categoryId: _categoryIdController.text,
        totalQuantity: int.tryParse(_totalQtyController.text) ?? 0,
        availableQuantity: int.tryParse(_availableQtyController.text) ?? 0,
        conditionStatus: _selectedCondition,
        location: _locationController.text,
      ));
    } else {
      _managementBloc.add(UpdateEquipmentDataEvent(
        id: widget.equipment!.id,
        equipmentName: _nameController.text,
        categoryId: _categoryIdController.text,
        totalQuantity: int.tryParse(_totalQtyController.text) ?? 0,
        availableQuantity: int.tryParse(_availableQtyController.text) ?? 0,
        conditionStatus: _selectedCondition,
        location: _locationController.text,
      ));
    }
  }

  void _onDeleteClick() {
    _managementBloc.add(DeleteEquipmentDataEvent(id: widget.equipment!.id));
  }
}

class EquipmentCreatedResult {
  final Equipment equipment;
  EquipmentCreatedResult({required this.equipment});
}
class EquipmentUpdatedResult {
  final Equipment equipment;
  EquipmentUpdatedResult({required this.equipment});
}
class EquipmentDeletedResult {
  final Equipment equipment;
  EquipmentDeletedResult({required this.equipment});
}