// lib/blocs/equipment/equipment_list_event.dart
part of 'equipment_list_bloc.dart';

@immutable
sealed class EquipmentListEvent {}

class LoadEquipmentListEvent extends EquipmentListEvent {}

class UpdateEquipmentEvent extends EquipmentListEvent {
  final Equipment updatedEquipment;
  UpdateEquipmentEvent({required this.updatedEquipment});
}

class AddNewEquipmentEvent extends EquipmentListEvent {
  final Equipment newEquipment;
  AddNewEquipmentEvent({required this.newEquipment});
}

class DeleteEquipmentEvent extends EquipmentListEvent {
  final Equipment deletedEquipment;
  DeleteEquipmentEvent({required this.deletedEquipment});
}
