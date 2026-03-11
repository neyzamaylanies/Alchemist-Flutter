// lib/screens/equipment/equipment_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late ThemeData _theme;
  bool _isLoading = false;

  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryIdController = TextEditingController();
  final _totalQtyController = TextEditingController();
  final _availableQtyController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedCondition = "BAIK";

  final EquipmentManagementBloc _managementBloc = EquipmentManagementBloc(
    equipmentRepository: EquipmentRepository(RemoteHelper.getDio()),
  );

  final List<String> _conditions = [
    "BAIK", "RUSAK_RINGAN", "RUSAK_BERAT", "DALAM_PERBAIKAN"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.equipment != null) {
      _idController.text = widget.equipment!.id;
      _nameController.text = widget.equipment!.equipmentName;
      _categoryIdController.text = widget.equipment!.categoryId;
      _totalQtyController.text = widget.equipment!.totalQuantity.toString();
      _availableQtyController.text = widget.equipment!.availableQuantity.toString();
      _locationController.text = widget.equipment!.location;
      _selectedCondition = widget.equipment!.conditionStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
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
            _showMessage(state.message);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppTheme.navyDark,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              widget.equipment == null ? "Tambah Alat" : "Edit Alat",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.equipment == null) ...[
                    Text("ID Alat", style: _theme.textTheme.labelMedium),
                    TextField(controller: _idController, decoration: const InputDecoration(hintText: "Contoh: EQ001")),
                    const SizedBox(height: 16),
                  ],
                  Text("Nama Alat", style: _theme.textTheme.labelMedium),
                  TextField(controller: _nameController, decoration: const InputDecoration(hintText: "Masukkan nama alat")),
                  const SizedBox(height: 16),
                  Text("ID Kategori", style: _theme.textTheme.labelMedium),
                  TextField(controller: _categoryIdController, decoration: const InputDecoration(hintText: "Contoh: CAT001")),
                  const SizedBox(height: 16),
                  Text("Total Kuantitas", style: _theme.textTheme.labelMedium),
                  TextField(controller: _totalQtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "0")),
                  const SizedBox(height: 16),
                  Text("Kuantitas Tersedia", style: _theme.textTheme.labelMedium),
                  TextField(controller: _availableQtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "0")),
                  const SizedBox(height: 16),
                  Text("Lokasi", style: _theme.textTheme.labelMedium),
                  TextField(controller: _locationController, decoration: const InputDecoration(hintText: "Contoh: Lab A")),
                  const SizedBox(height: 16),
                  Text("Kondisi", style: _theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCondition,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _selectedCondition = val ?? "BAIK"),
                  ),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: LoadingButton(isLoading: _isLoading, onPressed: _onSaveClick, text: widget.equipment == null ? "Tambah" : "Simpan")),
                  ]),
                  if (widget.equipment != null) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: LoadingButton(isLoading: _isLoading, onPressed: _onDeleteClick, text: "Hapus", buttonColor: _theme.colorScheme.error)),
                    ]),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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