// lib/screens/equipment/equipment_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/equipment/equipment_list_bloc.dart';
import '../../models/ui/equipment.dart';
import '../../utils/app_theme.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/data_table_card.dart';
import 'equipment_detail_page.dart';

class EquipmentListPage extends StatefulWidget {
  final EquipmentListBloc equipmentBloc;
  const EquipmentListPage({super.key, required this.equipmentBloc});

  @override
  State<EquipmentListPage> createState() => _EquipmentListPageState();
}

class _EquipmentListPageState extends State<EquipmentListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.equipmentBloc,
      child: PageScaffold(
        title: 'Peralatan Lab',
        searchHint: 'Cari peralatan...',
        onSearch: (q) => setState(() => _searchQuery = q.toLowerCase()),
        actionLabel: '+ Tambah Alat',
        onAction: () => _onCreateClick(context),
        body: BlocBuilder<EquipmentListBloc, EquipmentListState>(
          builder: (context, state) {
            final isLoading = state is EquipmentListLoading;
            List<Equipment> equipments = [];
            List<dynamic> categories = [];

            if (state is EquipmentListLoaded) {
              equipments = state.equipments.where((e) =>
                e.equipmentName.toLowerCase().contains(_searchQuery) ||
                e.id.toLowerCase().contains(_searchQuery) ||
                e.location.toLowerCase().contains(_searchQuery)
              ).toList();
              categories = state.categories;
            }

            return DataTableCard(
              isLoading: isLoading,
              emptyMessage: 'Belum ada data peralatan',
              emptyIcon: Icons.science_rounded,
              headers: const ['ID', 'NAMA', 'KATEGORI', 'TERSEDIA', 'TOTAL', 'STATUS', 'LOKASI', 'AKSI'],
              rows: equipments.map((eq) {
                final color = AppTheme.getKondisiColor(eq.conditionStatus);
                String catName = eq.categoryId;
                try {
                  catName = categories.firstWhere((c) => c.id == eq.categoryId)?.categoryName ?? eq.categoryId;
                } catch (_) {}

                return [
                  Text(eq.id, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
                  Text(eq.equipmentName, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(catName, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
                  Text('${eq.availableQuantity}', style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.success)),
                  Text('${eq.totalQuantity}', style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
                  StatusBadge(label: AppTheme.getKondisiLabel(eq.conditionStatus), color: color),
                  Text(eq.location, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
                  Row(children: [
                    ActionButton(icon: Icons.edit_rounded, color: AppTheme.primary, tooltip: 'Edit', onTap: () => _onEditClick(context, eq)),
                    const SizedBox(width: 6),
                    ActionButton(icon: Icons.delete_rounded, color: AppTheme.error, tooltip: 'Hapus', onTap: () => _onDeleteClick(context, eq)),
                  ]),
                ];
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  void _onCreateClick(BuildContext context) async {
    var result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const EquipmentDetailPage(equipment: null)));
    if (result is EquipmentCreatedResult) {
      widget.equipmentBloc.add(AddNewEquipmentEvent(newEquipment: result.equipment));
    }
  }

  void _onEditClick(BuildContext context, Equipment eq) async {
    var result = await Navigator.push(context, MaterialPageRoute(builder: (_) => EquipmentDetailPage(equipment: eq)));
    if (result is EquipmentUpdatedResult) {
      widget.equipmentBloc.add(UpdateEquipmentEvent(updatedEquipment: result.equipment));
    } else if (result is EquipmentDeletedResult) {
      widget.equipmentBloc.add(DeleteEquipmentEvent(deletedEquipment: result.equipment));
    }
  }

  void _onDeleteClick(BuildContext context, Equipment eq) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Alat', style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
        content: Text('Hapus "${eq.equipmentName}"?', style: const TextStyle(fontFamily: AppTheme.fontFamily)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _onEditClick(context, eq);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}