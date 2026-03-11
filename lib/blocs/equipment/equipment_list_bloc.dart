// lib/blocs/equipment/equipment_list_bloc.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/ui/equipment.dart';
import '../../models/ui/equipment_category.dart';
import '../../repositories/equipment_repository.dart';

part 'equipment_list_event.dart';
part 'equipment_list_state.dart';

class EquipmentListBloc extends Bloc<EquipmentListEvent, EquipmentListState> {
  final EquipmentRepository equipmentRepository;
  final List<Equipment> _currentList = [];
  final List<EquipmentCategory> _categories = [];

  EquipmentListBloc({required this.equipmentRepository})
      : super(EquipmentListInitial()) {
    on<LoadEquipmentListEvent>((event, emit) async {
      emit(EquipmentListLoading());

      // Load categories dan equipments sekaligus
      var categoryResult = await equipmentRepository.getCategoryList();
      var equipmentResult = await equipmentRepository.getEquipmentList();

      if (equipmentResult.isSuccess) {
        var equipmentsMapped = equipmentResult.data
                ?.map((e) => Equipment.fromRemote(e))
                .toList() ??
            [];
        var categoriesMapped = categoryResult.data
                ?.map((e) => EquipmentCategory.fromRemote(e))
                .toList() ??
            [];

        _currentList.clear();
        _currentList.addAll(equipmentsMapped);
        _categories.clear();
        _categories.addAll(categoriesMapped);

        emit(EquipmentListLoaded(
            equipments: List.from(_currentList),
            categories: List.from(_categories)));
      } else {
        emit(EquipmentListError(message: equipmentResult.message));
      }
    });

    on<UpdateEquipmentEvent>((event, emit) {
      var updated = event.updatedEquipment;
      var index =
          _currentList.indexWhere((e) => e.id == updated.id);
      if (index != -1) _currentList[index] = updated;
      emit(EquipmentListLoaded(
          equipments: List.from(_currentList),
          categories: List.from(_categories)));
    });

    on<AddNewEquipmentEvent>((event, emit) {
      _currentList.add(event.newEquipment);
      emit(EquipmentListLoaded(
          equipments: List.from(_currentList),
          categories: List.from(_categories)));
    });

    on<DeleteEquipmentEvent>((event, emit) {
      _currentList.removeWhere((e) => e.id == event.deletedEquipment.id);
      emit(EquipmentListLoaded(
          equipments: List.from(_currentList),
          categories: List.from(_categories)));
    });
  }
}
