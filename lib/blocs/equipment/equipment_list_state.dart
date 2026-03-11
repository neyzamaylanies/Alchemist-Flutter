// lib/blocs/equipment/equipment_list_state.dart
part of 'equipment_list_bloc.dart';

@immutable
sealed class EquipmentListState {}

final class EquipmentListInitial extends EquipmentListState {}

final class EquipmentListLoading extends EquipmentListState {}

final class EquipmentListLoaded extends EquipmentListState {
  final List<Equipment> equipments;
  final List<EquipmentCategory> categories;
  EquipmentListLoaded({required this.equipments, required this.categories});
}

final class EquipmentListError extends EquipmentListState {
  final String message;
  EquipmentListError({required this.message});
}
