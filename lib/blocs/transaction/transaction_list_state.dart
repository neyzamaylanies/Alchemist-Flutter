// lib/blocs/transaction/transaction_list_state.dart
part of 'transaction_list_bloc.dart';

@immutable
sealed class TransactionListState {}

final class TransactionListInitial extends TransactionListState {}

final class TransactionListLoading extends TransactionListState {}

final class TransactionListLoaded extends TransactionListState {
  final List<Transaction> transactions;
  TransactionListLoaded({required this.transactions});
}

final class TransactionListError extends TransactionListState {
  final String message;
  TransactionListError({required this.message});
}
