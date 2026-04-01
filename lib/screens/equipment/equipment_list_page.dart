// lib/screens/equipment/equipment_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/equipment/equipment_list_bloc.dart';
import '../../models/ui/equipment.dart';
import '../../repositories/equipment_repository.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';
import '../../widgets/data_table_card.dart';
import '../condition_log/condition_log_list_page.dart';
import '../category/category_list_page.dart';
import 'equipment_detail_page.dart';

class EquipmentListPage extends StatefulWidget {
  const EquipmentListPage({super.key});

  @override
  State<EquipmentListPage> createState() => _EquipmentListPageState();
}

class _EquipmentListPageState extends State<EquipmentListPage> {
  late final EquipmentListBloc _bloc;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _bloc = EquipmentListBloc(
      equipmentRepository: EquipmentRepository(RemoteHelper.getDio()),
    )..add(LoadEquipmentListEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.background;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header (fixed, tidak ikut scroll)
            Container(
              color: isDark ? AppTheme.darkSurface : AppTheme.surface,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Peralatan Lab',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _onCreateClick(context),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Tambah'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (q) =>
                        setState(() => _searchQuery = q.toLowerCase()),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      color: textColor,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Cari peralatan...',
                      prefixIcon: Icon(Icons.search_rounded, size: 18),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      constraints: BoxConstraints(maxHeight: 42),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Sub-nav buttons — wrap agar tidak overflow di layar sempit
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _SubNavButton(
                        icon: Icons.assignment_rounded,
                        label: 'Kondisi Log',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ConditionLogListPage(),
                          ),
                        ),
                      ),
                      _SubNavButton(
                        icon: Icons.category_rounded,
                        label: 'Kategori',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryListPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Tabel (scrollable vertikal)
            Expanded(
              child: BlocBuilder<EquipmentListBloc, EquipmentListState>(
                builder: (context, state) {
                  final isLoading = state is EquipmentListLoading;
                  List<Equipment> equipments = [];
                  List<dynamic> categories = [];

                  if (state is EquipmentListLoaded) {
                    equipments = state.equipments
                        .where(
                          (e) =>
                              e.equipmentName.toLowerCase().contains(
                                _searchQuery,
                              ) ||
                              e.id.toLowerCase().contains(_searchQuery) ||
                              e.location.toLowerCase().contains(_searchQuery),
                        )
                        .toList();
                    categories = state.categories;
                  }

                  return DataTableCard(
                    isLoading: isLoading,
                    emptyMessage: 'Belum ada data peralatan',
                    emptyIcon: Icons.science_rounded,
                    headers: const [
                      'ID',
                      'NAMA',
                      'KATEGORI',
                      'TERSEDIA',
                      'TOTAL',
                      'STATUS',
                      'LOKASI',
                      'AKSI',
                    ],
                    rows: equipments.map((eq) {
                      final color = AppTheme.getKondisiColor(
                        eq.conditionStatus,
                      );
                      String catName = eq.categoryId;
                      try {
                        catName =
                            categories
                                .firstWhere((c) => c.id == eq.categoryId)
                                ?.categoryName ??
                            eq.categoryId;
                      } catch (_) {}

                      return [
                        Text(
                          eq.id,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            color: subColor,
                          ),
                        ),
                        Text(
                          eq.equipmentName,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          catName,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            color: subColor,
                          ),
                        ),
                        Text(
                          '${eq.availableQuantity}',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.success,
                          ),
                        ),
                        Text(
                          '${eq.totalQuantity}',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 13,
                            color: textColor,
                          ),
                        ),
                        StatusBadge(
                          label: AppTheme.getKondisiLabel(eq.conditionStatus),
                          color: color,
                        ),
                        Text(
                          eq.location,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            color: subColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            ActionButton(
                              icon: Icons.edit_rounded,
                              color: AppTheme.primary,
                              tooltip: 'Edit',
                              onTap: () => _onEditClick(context, eq),
                            ),
                            const SizedBox(width: 6),
                            ActionButton(
                              icon: Icons.delete_rounded,
                              color: AppTheme.error,
                              tooltip: 'Hapus',
                              onTap: () => _onDeleteClick(context, eq),
                            ),
                          ],
                        ),
                      ];
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCreateClick(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EquipmentDetailPage(equipment: null),
      ),
    );
    if (result is EquipmentCreatedResult) {
      _bloc.add(AddNewEquipmentEvent(newEquipment: result.equipment));
    }
  }

  void _onEditClick(BuildContext context, Equipment eq) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EquipmentDetailPage(equipment: eq)),
    );
    if (result is EquipmentUpdatedResult) {
      _bloc.add(UpdateEquipmentEvent(updatedEquipment: result.equipment));
    } else if (result is EquipmentDeletedResult) {
      _bloc.add(DeleteEquipmentEvent(deletedEquipment: result.equipment));
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: AppTheme.fontFamily)),
      backgroundColor: isError ? AppTheme.error : AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _onDeleteClick(BuildContext context, Equipment eq) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Alat',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Yakin ingin menghapus "${eq.equipmentName}"?',
          style: const TextStyle(fontFamily: AppTheme.fontFamily),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await RemoteHelper.getDio().delete('api/equipments/${eq.id}');
                _bloc.add(DeleteEquipmentEvent(deletedEquipment: eq));
                _showSnack('Alat berhasil dihapus!');
              } catch (_) {
                _showSnack('Gagal menghapus alat!', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _SubNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SubNavButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFDDD8FF),
        ),
        foregroundColor: isDark ? AppTheme.primaryLighter : AppTheme.primary,
      ),
    );
  }
}