// lib/blocs/equipment/equipment_management_bloc.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/ui/equipment.dart';
import '../../repositories/equipment_repository.dart';

part 'equipment_management_event.dart';
part 'equipment_management_state.dart';

class EquipmentManagementBloc
    extends Bloc<EquipmentManagementEvent, EquipmentManagementState> {
  final EquipmentRepository equipmentRepository;

  EquipmentManagementBloc({required this.equipmentRepository})
      : super(EquipmentInitial()) {
    on<CreateEquipmentEvent>((event, emit) async {
      var validation = _validateInput(event.equipmentName, event.categoryId,
          event.totalQuantity, event.availableQuantity);
      if (validation.isNotEmpty) {
        emit(EquipmentError(message: validation.join(", ")));
        return;
      }

      emit(EquipmentLoading());
      var data = {
        "id": event.id,
        "equipmentName": event.equipmentName,
        "categoryId": event.categoryId,
        "totalQuantity": event.totalQuantity,
        "availableQuantity": event.availableQuantity,
        "conditionStatus": event.conditionStatus,
        "location": event.location,
      };

      var result = await equipmentRepository.createEquipment(data);
      if (result.isSuccess && result.data != null) {
        emit(EquipmentCreatedSuccessful(
            equipment: Equipment.fromRemote(result.data!)));
      } else {
        emit(EquipmentError(message: result.message));
      }
    });

    on<UpdateEquipmentDataEvent>((event, emit) async {
      var validation = _validateInput(event.equipmentName, event.categoryId,
          event.totalQuantity, event.availableQuantity);
      if (validation.isNotEmpty) {
        emit(EquipmentError(message: validation.join(", ")));
        return;
      }

      emit(EquipmentLoading());
      var data = {
        "equipmentName": event.equipmentName,
        "categoryId": event.categoryId,
        "totalQuantity": event.totalQuantity,
        "availableQuantity": event.availableQuantity,
        "conditionStatus": event.conditionStatus,
        "location": event.location,
      };

      var result = await equipmentRepository.updateEquipment(event.id, data);
      if (result.isSuccess && result.data != null) {
        emit(EquipmentUpdatedSuccessful(
            equipment: Equipment.fromRemote(result.data!)));
      } else {
        emit(EquipmentError(message: result.message));
      }
    });

    on<DeleteEquipmentDataEvent>((event, emit) async {
      emit(EquipmentLoading());
      var result = await equipmentRepository.deleteEquipment(event.id);
      if (result.isSuccess) {
        emit(EquipmentDeletedSuccessful());
      } else {
        emit(EquipmentError(message: result.message));
      }
    });
  }

  List<String> _validateInput(String name, String categoryId,
      int totalQty, int availableQty) {
    List<String> errors = [];
    if (name.isEmpty) errors.add("Nama alat tidak boleh kosong!");
    if (categoryId.isEmpty) errors.add("Kategori harus dipilih!");
    if (totalQty < 0) errors.add("Total kuantitas tidak valid!");
    if (availableQty < 0) errors.add("Kuantitas tersedia tidak valid!");
    if (availableQty > totalQty) {
      errors.add("Tersedia tidak boleh lebih dari total!");
    }
    return errors;
  }
}
