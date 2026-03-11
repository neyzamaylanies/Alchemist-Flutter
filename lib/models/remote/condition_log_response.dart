// lib/models/remote/condition_log_response.dart
class ConditionLogResponse {
  final String id;
  final String equipmentId;
  final String previousCondition;
  final String currentCondition;
  final String? checkDate;
  final String checkedBy;
  final String? note;

  ConditionLogResponse({
    required this.id,
    required this.equipmentId,
    required this.previousCondition,
    required this.currentCondition,
    this.checkDate,
    required this.checkedBy,
    this.note,
  });

  factory ConditionLogResponse.fromJson(Map<String, dynamic> json) {
    return ConditionLogResponse(
      id: json["id"] ?? "",
      equipmentId: json["equipmentId"] ?? "",
      previousCondition: json["previousCondition"] ?? "",
      currentCondition: json["currentCondition"] ?? "",
      checkDate: json["checkDate"],
      checkedBy: json["checkedBy"] ?? "",
      note: json["note"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "equipmentId": equipmentId,
      "previousCondition": previousCondition,
      "currentCondition": currentCondition,
      "checkDate": checkDate,
      "checkedBy": checkedBy,
      "note": note,
    };
  }
}
