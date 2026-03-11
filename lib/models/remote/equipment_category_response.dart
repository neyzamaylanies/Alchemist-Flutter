// lib/models/remote/equipment_category_response.dart
class EquipmentCategoryResponse {
  final String id;
  final String categoryName;
  final String description;

  EquipmentCategoryResponse({
    required this.id,
    required this.categoryName,
    required this.description,
  });

  factory EquipmentCategoryResponse.fromJson(Map<String, dynamic> json) {
    return EquipmentCategoryResponse(
      id: json["id"] ?? "",
      categoryName: json["categoryName"] ?? "",
      description: json["description"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "categoryName": categoryName,
      "description": description,
    };
  }
}
