// lib/models/remote/equipment_response.dart
class EquipmentResponse {
  final String id;
  final String equipmentName;
  final String categoryId;
  final int totalQuantity;
  final int availableQuantity;
  final String conditionStatus;
  final String location;
  final String? purchaseDate;
  final double? purchasePrice;

  EquipmentResponse({
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

  factory EquipmentResponse.fromJson(Map<String, dynamic> json) {
    return EquipmentResponse(
      id: json["id"] ?? "",
      equipmentName: json["equipmentName"] ?? "",
      categoryId: json["categoryId"] ?? "",
      totalQuantity: json["totalQuantity"] ?? 0,
      availableQuantity: json["availableQuantity"] ?? 0,
      conditionStatus: json["conditionStatus"] ?? "BAIK",
      location: json["location"] ?? "",
      purchaseDate: json["purchaseDate"],
      purchasePrice: json["purchasePrice"] != null
          ? double.tryParse(json["purchasePrice"].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "equipmentName": equipmentName,
      "categoryId": categoryId,
      "totalQuantity": totalQuantity,
      "availableQuantity": availableQuantity,
      "conditionStatus": conditionStatus,
      "location": location,
      "purchaseDate": purchaseDate,
      "purchasePrice": purchasePrice,
    };
  }
}
