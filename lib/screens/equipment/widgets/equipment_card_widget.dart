// lib/screens/equipment/widgets/equipment_card_widget.dart
import 'package:flutter/material.dart';
import '../../../models/ui/equipment.dart';

class EquipmentCardWidget extends StatelessWidget {
  final Equipment equipment;
  final String categoryName;
  final Function(Equipment) onCardClicked;

  const EquipmentCardWidget({
    super.key,
    required this.equipment,
    required this.categoryName,
    required this.onCardClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onCardClicked(equipment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _conditionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.science, color: _conditionColor, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.equipmentName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(categoryName,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildChip(equipment.conditionLabel, _conditionColor),
                      const SizedBox(width: 8),
                      _buildChip(
                          "Tersedia: ${equipment.availableQuantity}",
                          Colors.blue.shade700),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Color get _conditionColor {
    switch (equipment.conditionStatus) {
      case "BAIK": return Colors.green;
      case "RUSAK_RINGAN": return Colors.orange;
      case "RUSAK_BERAT": return Colors.red;
      case "DALAM_PERBAIKAN": return Colors.blue;
      default: return Colors.grey;
    }
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
