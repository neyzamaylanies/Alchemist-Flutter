// lib/models/ui/equipment.dart
import '../remote/equipment_response.dart';

class Equipment {
  final String id;
  final String equipmentName;
  final String categoryId;
  final int totalQuantity;
  final int availableQuantity;
  final String conditionStatus;
  final String location;
  final String? purchaseDate;
  final double? purchasePrice;

  Equipment({
    required this.id,
    required this.equipmentName,
    required this.categoryId,
    required this.totalQuantity,
    required this.availableQuantity,
    required this.conditionStatus,
    required this.location,
    this.purchaseDate,
    this.purchasePrice,
  });

  factory Equipment.fromRemote(EquipmentResponse remote) {
    return Equipment(
      id: remote.id,
      equipmentName: remote.equipmentName,
      categoryId: remote.categoryId,
      totalQuantity: remote.totalQuantity,
      availableQuantity: remote.availableQuantity,
      conditionStatus: remote.conditionStatus,
      location: remote.location,
      purchaseDate: remote.purchaseDate,
      purchasePrice: remote.purchasePrice,
    );
  }

  EquipmentResponse toRemote() {
    return EquipmentResponse(
      id: id,
      equipmentName: equipmentName,
      categoryId: categoryId,
      totalQuantity: totalQuantity,
      availableQuantity: availableQuantity,
      conditionStatus: conditionStatus,
      location: location,
      purchaseDate: purchaseDate,
      purchasePrice: purchasePrice,
    );
  }

  bool get isAvailable =>
      conditionStatus == "BAIK" || conditionStatus == "RUSAK_RINGAN";

  String get conditionLabel {
    switch (conditionStatus) {
      case "BAIK": return "Baik";
      case "RUSAK_RINGAN": return "Rusak Ringan";
      case "RUSAK_BERAT": return "Rusak Berat";
      case "DALAM_PERBAIKAN": return "Dalam Perbaikan";
      default: return conditionStatus;
    }
  }
}
