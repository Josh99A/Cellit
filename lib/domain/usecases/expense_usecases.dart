import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';
import 'params/base_params.dart';

class SyncAllUserExpensesUsecase extends Usecase<Result, String> {
  SyncAllUserExpensesUsecase(this._expenseRepository);

  final ExpenseRepository _expenseRepository;

  @override
  Future<Result<int>> call(String params) async => _expenseRepository.syncAllUserExpenses(params);
}

class GetUserExpensesUsecase extends Usecase<Result, BaseParams> {
  GetUserExpensesUsecase(this._expenseRepository);

  final ExpenseRepository _expenseRepository;

  @override
  Future<Result<List<ExpenseEntity>>> call(BaseParams params) async => _expenseRepository.getUserExpenses(
    params.param,
    orderBy: params.orderBy,
    sortBy: params.sortBy,
    limit: params.limit,
    offset: params.offset,
    contains: params.contains,
  );
}

class GetExpenseUsecase extends Usecase<Result, int> {
  GetExpenseUsecase(this._expenseRepository);

  final ExpenseRepository _expenseRepository;

  @override
  Future<Result<ExpenseEntity?>> call(int params) async => _expenseRepository.getExpense(params);
}

class CreateExpenseUsecase extends Usecase<Result, ExpenseEntity> {
  CreateExpenseUsecase(this._expenseRepository);

  final ExpenseRepository _expenseRepository;

  @override
  Future<Result<int>> call(ExpenseEntity params) async => _expenseRepository.createExpense(params);
}

class UpdateExpenseUsecase extends Usecase<Result<void>, ExpenseEntity> {
  UpdateExpenseUsecase(this._expenseRepository);

  final ExpenseRepository _expenseRepository;

  @override
  Future<Result<void>> call(ExpenseEntity params) async => _expenseRepository.updateExpense(params);
}

class DeleteExpenseUsecase extends Usecase<Result<void>, int> {
  DeleteExpenseUsecase(this._expenseRepository);

  final ExpenseRepository _expenseRepository;

  @override
  Future<Result<void>> call(int params) async => _expenseRepository.deleteExpense(params);
}
