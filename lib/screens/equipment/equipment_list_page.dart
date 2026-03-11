// lib/screens/equipment/equipment_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/equipment/equipment_list_bloc.dart';
import '../../blocs/equipment/equipment_management_bloc.dart';
import '../../repositories/equipment_repository.dart';
import '../../utils/remote_helper.dart';
import '../../utils/app_theme.dart';
import '../../models/ui/equipment.dart';
import 'equipment_detail_page.dart';
import 'widgets/equipment_card_widget.dart';

class EquipmentListPage extends StatefulWidget {
  final EquipmentListBloc equipmentBloc;
  const EquipmentListPage({super.key, required this.equipmentBloc});

  @override
  State<EquipmentListPage> createState() => _EquipmentListPageState();
}

class _EquipmentListPageState extends State<EquipmentListPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.equipmentBloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.navyDark,
          title: const Text("Alat Laboratorium",
              style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () =>
                  widget.equipmentBloc.add(LoadEquipmentListEvent()),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.primary,
          onPressed: () => _onCreateClick(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SafeArea(
          child: BlocBuilder<EquipmentListBloc, EquipmentListState>(
            builder: (context, state) {
              if (state is EquipmentListLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is EquipmentListLoaded) {
                if (state.equipments.isEmpty) {
                  return const Center(child: Text("Belum ada data alat"));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  primary: false,
                  itemCount: state.equipments.length,
                  itemBuilder: (context, position) {
                    return EquipmentCardWidget(
                      equipment: state.equipments[position],
                      categoryName: _getCategoryName(
                          state.equipments[position].categoryId,
                          state.categories
                              .map((c) => {'id': c.id, 'name': c.categoryName})
                              .toList()),
                      onCardClicked: _onCardClicked,
                    );
                  },
                );
              } else if (state is EquipmentListError) {
                return Center(child: Text("Error: ${state.message}"));
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  String _getCategoryName(
      String categoryId, List<Map<String, String>> categories) {
    try {
      return categories.firstWhere((c) => c['id'] == categoryId)['name'] ??
          categoryId;
    } catch (_) {
      return categoryId;
    }
  }

  void _onCardClicked(Equipment equipment) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EquipmentDetailPage(equipment: equipment),
      ),
    );
    if (result is EquipmentUpdatedResult) {
      widget.equipmentBloc
          .add(UpdateEquipmentEvent(updatedEquipment: result.equipment));
    } else if (result is EquipmentDeletedResult) {
      widget.equipmentBloc
          .add(DeleteEquipmentEvent(deletedEquipment: result.equipment));
    }
  }

  void _onCreateClick(BuildContext context) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EquipmentDetailPage(equipment: null),
      ),
    );
    if (result is EquipmentCreatedResult) {
      widget.equipmentBloc
          .add(AddNewEquipmentEvent(newEquipment: result.equipment));
    }
  }
}