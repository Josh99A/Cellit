import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../domain/usecases/expense_usecases.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../auth/auth_notifier.dart';
import 'expenses_state.dart';

final expensesNotifierProvider = NotifierProvider<ExpensesNotifier, ExpensesState>(
  ExpensesNotifier.new,
);

class ExpensesNotifier extends Notifier<ExpensesState> {
  @override
  ExpensesState build() {
    return const ExpensesState();
  }

  String _requireUserId() {
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) return authState.user!.id;
    throw 'Unauthenticated!';
  }

  void resetExpenses() {
    state = const ExpensesState();
  }

  Future<void> getAllExpenses({int? offset, String? contains}) async {
    final userId = _requireUserId();

    if (offset != null) {
      state = state.copyWith(isLoadingMore: true);
    }

    var params = BaseParams(
      param: userId,
      orderBy: 'date',
      offset: offset,
      contains: contains,
    );

    final expenseRepository = ref.read(expenseRepositoryProvider);
    var res = await GetUserExpensesUsecase(expenseRepository).call(params);

    if (res.isSuccess) {
      if (offset == null) {
        state = state.copyWith(allExpenses: res.data ?? [], isLoadingMore: false);
      } else {
        final current = state.allExpenses ?? [];
        state = state.copyWith(
          allExpenses: [...current, ...res.data ?? []],
          isLoadingMore: false,
        );
      }
    } else {
      state = state.copyWith(isLoadingMore: false);
      throw Exception(res.error?.toString() ?? 'Failed to load data');
    }
  }
}
