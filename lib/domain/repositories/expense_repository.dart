import '../../core/common/result.dart';
import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<Result<int>> syncAllUserExpenses(String userId);

  Future<Result<ExpenseEntity?>> getExpense(int expenseId);

  Future<Result<int>> createExpense(ExpenseEntity expense);

  Future<Result<void>> updateExpense(ExpenseEntity expense);

  Future<Result<void>> deleteExpense(int expenseId);

  Future<Result<List<ExpenseEntity>>> getUserExpenses(
    String userId, {
    String orderBy,
    String sortBy,
    int limit,
    int? offset,
    String? contains,
  });
}
