// lib/blocs/equipment/equipment_management_state.dart
part of 'equipment_management_bloc.dart';

@immutable
sealed class EquipmentManagementState {}

final class EquipmentInitial extends EquipmentManagementState {}

final class EquipmentLoading extends EquipmentManagementState {}

final class EquipmentCreatedSuccessful extends EquipmentManagementState {
  final Equipment equipment;
  EquipmentCreatedSuccessful({required this.equipment});
}

final class EquipmentUpdatedSuccessful extends EquipmentManagementState {
  final Equipment equipment;
  EquipmentUpdatedSuccessful({required this.equipment});
}

final class EquipmentDeletedSuccessful extends EquipmentManagementState {}

final class EquipmentError extends EquipmentManagementState {
  final String message;
  EquipmentError({required this.message});
}
