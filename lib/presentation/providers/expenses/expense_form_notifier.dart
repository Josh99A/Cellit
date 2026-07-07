import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/usecases/expense_usecases.dart';
import '../auth/auth_notifier.dart';
import 'expense_form_state.dart';
import 'expenses_notifier.dart';

final expenseFormNotifierProvider = NotifierProvider.autoDispose<ExpenseFormNotifier, ExpenseFormState>(
  ExpenseFormNotifier.new,
);

class ExpenseFormNotifier extends AutoDisposeNotifier<ExpenseFormState> {
  @override
  ExpenseFormState build() {
    return const ExpenseFormState();
  }

  String _requireUserId() {
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) return authState.user!.id;
    throw 'Unauthenticated!';
  }

  Future<void> initExpenseForm(int? expenseId) async {
    if (expenseId == null) {
      state = state.copyWith(
        date: DateTime.now().toIso8601String(),
        isLoaded: true,
      );
      return;
    }

    final expenseRepository = ref.read(expenseRepositoryProvider);
    var res = await GetExpenseUsecase(expenseRepository).call(expenseId);

    if (res.isSuccess) {
      var expense = res.data;

      state = state.copyWith(
        category: expense?.category,
        amount: expense?.amount,
        description: expense?.description,
        date: expense?.date,
        isLoaded: true,
      );
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }

  Future<Result<int>> createExpense() async {
    try {
      final userId = _requireUserId();
      final expenseRepository = ref.read(expenseRepositoryProvider);

      var expense = ExpenseEntity(
        createdById: userId,
        category: state.category ?? '',
        amount: state.amount ?? 0,
        description: state.description,
        date: state.date ?? DateTime.now().toIso8601String(),
      );

      var res = await CreateExpenseUsecase(expenseRepository).call(expense);

      // Refresh expenses
      ref.read(expensesNotifierProvider.notifier).getAllExpenses();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<void>> updateExpense(int id) async {
    try {
      final userId = _requireUserId();
      final expenseRepository = ref.read(expenseRepositoryProvider);

      var expense = ExpenseEntity(
        id: id,
        createdById: userId,
        category: state.category ?? '',
        amount: state.amount ?? 0,
        description: state.description,
        date: state.date ?? DateTime.now().toIso8601String(),
      );

      var res = await UpdateExpenseUsecase(expenseRepository).call(expense);

      // Refresh expenses
      ref.read(expensesNotifierProvider.notifier).getAllExpenses();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<void>> deleteExpense(int id) async {
    try {
      final expenseRepository = ref.read(expenseRepositoryProvider);
      var res = await DeleteExpenseUsecase(expenseRepository).call(id);

      // Refresh expenses
      ref.read(expensesNotifierProvider.notifier).getAllExpenses();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  void onChangedCategory(String? value) {
    state = state.copyWith(category: value);
  }

  void onChangedAmount(String value) {
    state = state.copyWith(amount: int.tryParse(value));
  }

  void onChangedDescription(String value) {
    state = state.copyWith(description: value);
  }

  void onChangedDate(String value) {
    state = state.copyWith(date: value);
  }
}
