import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../models/expense_model.dart';
import '../interfaces/expense_datasource.dart';

class ExpenseLocalDatasourceImpl extends ExpenseDatasource {
  final DatabaseService _databaseService;

  ExpenseLocalDatasourceImpl(this._databaseService);

  @override
  Future<Result<int>> createExpense(ExpenseModel expense) async {
    try {
      await _databaseService.database.insert(
        DatabaseConfig.expenseTableName,
        expense.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // The id has been generated in models
      return Result.success(data: expense.id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateExpense(ExpenseModel expense) async {
    try {
      await _databaseService.database.update(
        DatabaseConfig.expenseTableName,
        expense.toJson(),
        where: 'id = ?',
        whereArgs: [expense.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteExpense(int id) async {
    try {
      await _databaseService.database.delete(
        DatabaseConfig.expenseTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<ExpenseModel?>> getExpense(int id) async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.expenseTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (res.isEmpty) return Result.success(data: null);

      return Result.success(data: ExpenseModel.fromJson(res.first));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ExpenseModel>>> getAllUserExpenses(String userId) async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.expenseTableName,
        where: 'createdById = ?',
        whereArgs: [userId],
      );

      return Result.success(
        data: res.map((e) => ExpenseModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ExpenseModel>>> getUserExpenses(
    String userId, {
    String orderBy = 'date',
    String sortBy = 'DESC',
    int limit = 10,
    int? offset,
    String? contains,
  }) async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.expenseTableName,
        where: 'createdById = ? AND category LIKE ?',
        whereArgs: [userId, "%${contains ?? ''}%"],
        orderBy: '$orderBy $sortBy',
        limit: limit,
        offset: offset,
      );

      return Result.success(
        data: res.map((e) => ExpenseModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
