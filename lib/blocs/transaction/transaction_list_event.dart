// lib/blocs/transaction/transaction_list_event.dart
part of 'transaction_list_bloc.dart';

@immutable
sealed class TransactionListEvent {}

class LoadTransactionListEvent extends TransactionListEvent {}

class AddNewTransactionEvent extends TransactionListEvent {
  final Transaction newTransaction;
  AddNewTransactionEvent({required this.newTransaction});
}

class DeleteTransactionEvent extends TransactionListEvent {
  final Transaction deletedTransaction;
  DeleteTransactionEvent({required this.deletedTransaction});
}
