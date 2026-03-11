// lib/blocs/equipment/equipment_management_event.dart
part of 'equipment_management_bloc.dart';

@immutable
sealed class EquipmentManagementEvent {}

final class CreateEquipmentEvent extends EquipmentManagementEvent {
  final String id;
  final String equipmentName;
  final String categoryId;
  final int totalQuantity;
  final int availableQuantity;
  final String conditionStatus;
  final String location;

  CreateEquipmentEvent({
    required this.id,
    required this.equipmentName,
    required this.categoryId,
    required this.totalQuantity,
    required this.availableQuantity,
    required this.conditionStatus,
    required this.location,
  });
}

final class UpdateEquipmentDataEvent extends EquipmentManagementEvent {
  final String id;
  final String equipmentName;
  final String categoryId;
  final int totalQuantity;
  final int availableQuantity;
  final String conditionStatus;
  final String location;

  UpdateEquipmentDataEvent({
    required this.id,
    required this.equipmentName,
    required this.categoryId,
    required this.totalQuantity,
    required this.availableQuantity,
    required this.conditionStatus,
    required this.location,
  });
}

final class DeleteEquipmentDataEvent extends EquipmentManagementEvent {
  final String id;
  DeleteEquipmentDataEvent({required this.id});
}
