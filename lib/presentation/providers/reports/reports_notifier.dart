import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../domain/usecases/expense_usecases.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/transaction_usecases.dart';
import '../auth/auth_notifier.dart';
import 'reports_state.dart';

final reportsNotifierProvider = NotifierProvider.autoDispose<ReportsNotifier, ReportsState>(
  ReportsNotifier.new,
);

class ReportsNotifier extends AutoDisposeNotifier<ReportsState> {
  @override
  ReportsState build() {
    final now = DateTime.now();

    // Default to the current month
    return ReportsState(
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  String _requireUserId() {
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) return authState.user!.id;
    throw 'Unauthenticated!';
  }

  Future<void> loadReport() async {
    final userId = _requireUserId();

    state = state.copyWith(isLoading: true);

    final transactionRepository = ref.read(transactionRepositoryProvider);
    final expenseRepository = ref.read(expenseRepositoryProvider);

    final transactionsFuture = GetUserTransactionsUsecase(transactionRepository).call(
      BaseParams(param: userId, limit: 100000),
    );
    final expensesFuture = GetUserExpensesUsecase(expenseRepository).call(
      BaseParams(param: userId, orderBy: 'date', limit: 100000),
    );

    final transactionsRes = await transactionsFuture;
    final expensesRes = await expensesFuture;

    if (transactionsRes.isFailure || expensesRes.isFailure) {
      state = state.copyWith(isLoading: false);
      throw transactionsRes.error ?? expensesRes.error ?? 'Failed to load report data';
    }

    state = state.copyWith(
      transactions: (transactionsRes.data ?? []).where((trx) {
        return _isInRange(DateTime.tryParse(trx.createdAt ?? ''));
      }).toList(),
      expenses: (expensesRes.data ?? []).where((expense) {
        return _isInRange(DateTime.tryParse(expense.date));
      }).toList(),
      isLoading: false,
    );
  }

  void onChangedDateRange(DateTimeRange range) {
    state = state.copyWith(
      startDate: range.start,
      endDate: DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59),
    );

    loadReport();
  }

  bool _isInRange(DateTime? date) {
    if (date == null) return false;
    return !date.isBefore(state.startDate) && !date.isAfter(state.endDate);
  }
}
