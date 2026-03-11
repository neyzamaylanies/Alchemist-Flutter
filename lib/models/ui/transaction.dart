// lib/models/ui/transaction.dart
import '../remote/transaction_response.dart';

class Transaction {
  final String id;
  final String equipmentId;
  final String transactionType;
  final int quantity;
  final String? transactionDate;
  final String? note;
  final String handledBy;
  final String? usedBy;

  Transaction({
    required this.id,
    required this.equipmentId,
    required this.transactionType,
    required this.quantity,
    this.transactionDate,
    this.note,
    required this.handledBy,
    this.usedBy,
  });

  factory Transaction.fromRemote(TransactionResponse remote) {
    return Transaction(
      id: remote.id,
      equipmentId: remote.equipmentId,
      transactionType: remote.transactionType,
      quantity: remote.quantity,
      transactionDate: remote.transactionDate,
      note: remote.note,
      handledBy: remote.handledBy,
      usedBy: remote.usedBy,
    );
  }

  TransactionResponse toRemote() {
    return TransactionResponse(
      id: id,
      equipmentId: equipmentId,
      transactionType: transactionType,
      quantity: quantity,
      transactionDate: transactionDate,
      note: note,
      handledBy: handledBy,
      usedBy: usedBy,
    );
  }

  bool get isPeminjaman => transactionType == "OUT";
  bool get isPengembalian => transactionType == "IN";

  String get typeLabel => isPeminjaman ? "Peminjaman" : "Pengembalian";
}
