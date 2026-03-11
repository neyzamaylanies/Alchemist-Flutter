// lib/models/ui/equipment_category.dart
import '../remote/equipment_category_response.dart';

class EquipmentCategory {
  final String id;
  final String categoryName;
  final String description;

  EquipmentCategory({
    required this.id,
    required this.categoryName,
    required this.description,
  });

  factory EquipmentCategory.fromRemote(EquipmentCategoryResponse remote) {
    return EquipmentCategory(
      id: remote.id,
      categoryName: remote.categoryName,
      description: remote.description,
    );
  }

  EquipmentCategoryResponse toRemote() {
    return EquipmentCategoryResponse(
      id: id,
      categoryName: categoryName,
      description: description,
    );
  }
}
