import '../../../domain/entities/expense_entity.dart';

class ExpensesState {
  final List<ExpenseEntity>? allExpenses;
  final bool isLoadingMore;

  const ExpensesState({this.allExpenses, this.isLoadingMore = false});

  ExpensesState copyWith({
    List<ExpenseEntity>? allExpenses,
    bool? isLoadingMore,
  }) {
    return ExpensesState(
      allExpenses: allExpenses ?? this.allExpenses,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
