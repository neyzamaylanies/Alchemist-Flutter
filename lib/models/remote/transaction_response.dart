// lib/models/remote/transaction_response.dart
class TransactionResponse {
  final String id;
  final String equipmentId;
  final String transactionType;
  final int quantity;
  final String? transactionDate;
  final String? note;
  final String handledBy;
  final String? usedBy;

  TransactionResponse({
    required this.id,
    required this.equipmentId,
    required this.transactionType,
    required this.quantity,
    this.transactionDate,
    this.note,
    required this.handledBy,
    this.usedBy,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      id: json["id"] ?? "",
      equipmentId: json["equipmentId"] ?? "",
      transactionType: json["transactionType"] ?? "",
      quantity: json["quantity"] ?? 0,
      transactionDate: json["transactionDate"],
      note: json["note"],
      handledBy: json["handledBy"] ?? "",
      usedBy: json["usedBy"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "equipmentId": equipmentId,
      "transactionType": transactionType,
      "quantity": quantity,
      "transactionDate": transactionDate,
      "note": note,
      "handledBy": handledBy,
      "usedBy": usedBy,
    };
  }
}
