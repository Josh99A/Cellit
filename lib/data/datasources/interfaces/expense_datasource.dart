import '../../../core/common/result.dart';
import '../../models/expense_model.dart';

abstract class ExpenseDatasource {
  Future<Result<int>> createExpense(ExpenseModel expense);

  Future<Result<void>> updateExpense(ExpenseModel expense);

  Future<Result<void>> deleteExpense(int id);

  Future<Result<ExpenseModel?>> getExpense(int id);

  Future<Result<List<ExpenseModel>>> getAllUserExpenses(String userId);

  Future<Result<List<ExpenseModel>>> getUserExpenses(
    String userId, {
    String orderBy,
    String sortBy,
    int limit,
    int? offset,
    String? contains,
  });
}
