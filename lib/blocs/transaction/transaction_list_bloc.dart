// lib/blocs/transaction/transaction_list_bloc.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/ui/transaction.dart';
import '../../repositories/transaction_repository.dart';

part 'transaction_list_event.dart';
part 'transaction_list_state.dart';

class TransactionListBloc
    extends Bloc<TransactionListEvent, TransactionListState> {
  final TransactionRepository transactionRepository;
  final List<Transaction> _currentList = [];

  TransactionListBloc({required this.transactionRepository})
      : super(TransactionListInitial()) {
    on<LoadTransactionListEvent>((event, emit) async {
      emit(TransactionListLoading());
      var result = await transactionRepository.getTransactionList();
      if (result.isSuccess) {
        var mapped = result.data
                ?.map((e) => Transaction.fromRemote(e))
                .toList() ??
            [];
        _currentList.clear();
        _currentList.addAll(mapped);
        emit(TransactionListLoaded(transactions: List.from(_currentList)));
      } else {
        emit(TransactionListError(message: result.message));
      }
    });

    on<AddNewTransactionEvent>((event, emit) {
      _currentList.insert(0, event.newTransaction);
      emit(TransactionListLoaded(transactions: List.from(_currentList)));
    });

    on<DeleteTransactionEvent>((event, emit) {
      _currentList.removeWhere((t) => t.id == event.deletedTransaction.id);
      emit(TransactionListLoaded(transactions: List.from(_currentList)));
    });
  }
}
