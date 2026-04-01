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

// ── Bottom sheet launcher ──────────────────────────────────────────────────
Future<dynamic> showEquipmentForm(BuildContext context, {Equipment? equipment}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EquipmentFormSheet(equipment: equipment),
  );
}

// ── Wrapper page (dipakai routes) ──────────────────────────────────────────
class EquipmentDetailPage extends StatelessWidget {
  final Equipment? equipment;
  const EquipmentDetailPage({super.key, required this.equipment});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showEquipmentForm(context, equipment: equipment).then((result) {
        if (context.mounted) Navigator.pop(context, result);
      });
    });
    return const Scaffold(backgroundColor: Colors.transparent);
  }
}

// ── Form bottom sheet ──────────────────────────────────────────────────────
class _EquipmentFormSheet extends StatefulWidget {
  final Equipment? equipment;
  const _EquipmentFormSheet({this.equipment});

  @override
  State<_EquipmentFormSheet> createState() => _EquipmentFormSheetState();
}

class _EquipmentFormSheetState extends State<_EquipmentFormSheet> {
  bool _isLoading          = false;
  bool _isLoadingId        = false;
  bool _isLoadingCategories = false;

  final _idController           = TextEditingController();
  final _nameController         = TextEditingController();
  final _categoryIdController   = TextEditingController();
  final _totalQtyController     = TextEditingController();
  final _availableQtyController = TextEditingController();
  final _locationController     = TextEditingController();

  String _selectedCondition  = 'BAIK';
  DateTime? _purchaseDate;
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;

  final EquipmentManagementBloc _managementBloc = EquipmentManagementBloc(
    equipmentRepository: EquipmentRepository(RemoteHelper.getDio()),
  );

  final List<String> _conditions = ['BAIK', 'RUSAK_RINGAN', 'RUSAK_BERAT', 'DALAM_PERBAIKAN'];

  bool get _isCreate => widget.equipment == null;

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
      _selectedCategoryId          = eq.categoryId;
      if (eq.purchaseDate != null) _purchaseDate = DateTime.tryParse(eq.purchaseDate!);
    } else {
      _generateNextId();
    }
    _loadCategories();
  }

  @override
  void dispose() {
    _managementBloc.close();
    super.dispose();
  }

  Future<void> _generateNextId() async {
    setState(() => _isLoadingId = true);
    try {
      final res  = await RemoteHelper.getDio().get('api/equipments');
      final list = (res.data['data'] as List<dynamic>?) ?? [];
      const prefix = 'EQP';
      int max = 0;
      for (final e in list) {
        final id = (e['id'] ?? '') as String;
        if (id.startsWith(prefix)) {
          final num = int.tryParse(id.substring(prefix.length)) ?? 0;
          if (num > max) max = num;
        }
      }
      final nextId = '$prefix${(max + 1).toString().padLeft(3, '0')}';
      if (mounted) setState(() { _idController.text = nextId; _isLoadingId = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingId = false);
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final res  = await RemoteHelper.getDio().get('api/categories');
      final list = (res.data['data'] as List<dynamic>?) ?? [];
      final cats = list.map((c) => {
        'id': c['id'] as String? ?? '',
        'categoryName': c['categoryName'] as String? ?? '',
      }).toList();
      if (mounted) setState(() {
        _categories = cats;
        _isLoadingCategories = false;
        if (_selectedCategoryId == null && cats.isNotEmpty) {
          _selectedCategoryId = cats.first['id'];
          _categoryIdController.text = cats.first['id']!;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000), lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppTheme.primary)),
        child: child!),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final sheetBg   = isDark ? AppTheme.darkSurface : Colors.white;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor  = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;

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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)));
          }
        },
        child: Container(
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

                Text(_isCreate ? 'Tambah Alat' : 'Edit Alat',
                  style: TextStyle(fontFamily: AppTheme.fontFamily,
                    fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
                const SizedBox(height: 16),

                // ID
                if (_isCreate) ...[
                  _label('ID Alat', subColor),
                  _isLoadingId ? _loadingBox() : _readOnlyBox(_idController.text, isDark),
                  const SizedBox(height: 14),
                ],

                // Nama
                _label('Nama Alat', subColor),
                _inputField(controller: _nameController, hint: 'Masukkan nama alat',
                  isDark: isDark, textColor: textColor),
                const SizedBox(height: 14),

                // Kategori
                _label('Kategori', subColor),
                const SizedBox(height: 6),
                _isLoadingCategories
                  ? _loadingBox()
                  : _dropdownField<String>(
                      value: _selectedCategoryId,
                      hint: 'Pilih kategori...',
                      isDark: isDark,
                      items: _categories.map((cat) => DropdownMenuItem<String>(
                        value: cat['id'],
                        child: Text(cat['categoryName'] ?? '',
                          style: TextStyle(fontFamily: AppTheme.fontFamily,
                            fontSize: 13, color: textColor),
                          overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: (v) => setState(() {
                        _selectedCategoryId = v;
                        _categoryIdController.text = v ?? '';
                      }),
                    ),
                const SizedBox(height: 14),

                // Total & Tersedia
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('Total Qty', subColor),
                    _inputField(controller: _totalQtyController, hint: '0',
                      isDark: isDark, textColor: textColor, keyboardType: TextInputType.number),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('Tersedia', subColor),
                    _inputField(controller: _availableQtyController, hint: '0',
                      isDark: isDark, textColor: textColor, keyboardType: TextInputType.number),
                  ])),
                ]),
                const SizedBox(height: 14),

                // Lokasi
                _label('Lokasi', subColor),
                _inputField(controller: _locationController, hint: 'Contoh: Lab A Lt.2',
                  isDark: isDark, textColor: textColor),
                const SizedBox(height: 14),

                // Kondisi
                _label('Kondisi', subColor),
                const SizedBox(height: 6),
                _dropdownField<String>(
                  value: _selectedCondition,
                  hint: 'Pilih kondisi...',
                  isDark: isDark,
                  items: _conditions.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(AppTheme.getKondisiLabel(c),
                      style: TextStyle(fontFamily: AppTheme.fontFamily,
                        fontSize: 13, color: textColor)),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedCondition = v ?? 'BAIK'),
                ),
                const SizedBox(height: 14),

                // Tanggal Pembelian
                _label('Tanggal Pembelian (opsional)', subColor),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickPurchaseDate,
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
                        color: _purchaseDate != null ? AppTheme.primary : subColor),
                      const SizedBox(width: 10),
                      Text(
                        _purchaseDate != null
                          ? DateFormat('dd MMMM yyyy', 'id').format(_purchaseDate!)
                          : 'Pilih tanggal pembelian',
                        style: TextStyle(fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          color: _purchaseDate != null ? textColor : subColor)),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded, size: 18, color: subColor),
                    ]),
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol
                Row(children: [
                  if (!_isCreate) ...[
                    Expanded(child: OutlinedButton(
                      onPressed: _isLoading ? null : _onDeleteClick,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Hapus',
                        style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
                    )),
                    const SizedBox(width: 12),
                  ],
                  Expanded(child: ElevatedButton(
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
                      : Text(_isCreate ? 'Tambah Alat' : 'Simpan Perubahan',
                          style: const TextStyle(fontFamily: AppTheme.fontFamily,
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

  Widget _loadingBox() => Container(
    height: 48,
    decoration: BoxDecoration(
      color: const Color(0xFFF0F0F8),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE8E8F0)),
    ),
    child: const Center(child: SizedBox(width: 18, height: 18,
      child: CircularProgressIndicator(strokeWidth: 2))),
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required Color textColor,
    TextInputType keyboardType = TextInputType.text,
  }) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? AppTheme.darkSurfaceVar : Colors.white,
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

class EquipmentCreatedResult { final Equipment equipment; EquipmentCreatedResult({required this.equipment}); }
class EquipmentUpdatedResult { final Equipment equipment; EquipmentUpdatedResult({required this.equipment}); }
class EquipmentDeletedResult { final Equipment equipment; EquipmentDeletedResult({required this.equipment}); }