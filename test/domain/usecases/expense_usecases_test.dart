import 'package:cellit/core/common/result.dart';
import 'package:cellit/domain/entities/expense_entity.dart';
import 'package:cellit/domain/repositories/expense_repository.dart';
import 'package:cellit/domain/usecases/expense_usecases.dart';
import 'package:cellit/domain/usecases/params/base_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'expense_usecases_test.mocks.dart';

// This will generate the mock class
@GenerateMocks([ExpenseRepository])
void main() {
  late MockExpenseRepository mockExpenseRepository;

  setUpAll(() {
    // Provide dummy values for complex types
    provideDummy<Result<int>>(Result<int>.success(data: 0));
    provideDummy<Result<void>>(Result<void>.success(data: null));
    provideDummy<Result<List<ExpenseEntity>>>(Result<List<ExpenseEntity>>.success(data: []));
    provideDummy<Result<ExpenseEntity?>>(Result<ExpenseEntity?>.success(data: null));
  });

  setUp(() {
    mockExpenseRepository = MockExpenseRepository();
  });

  group('SyncAllUserExpensesUsecase', () {
    late SyncAllUserExpensesUsecase usecase;

    setUp(() {
      usecase = SyncAllUserExpensesUsecase(mockExpenseRepository);
    });

    test('should sync all user expenses successfully', () async {
      // arrange
      const userId = 'user123';
      const syncedCount = 5;
      final result = Result<int>.success(data: syncedCount);

      when(mockExpenseRepository.syncAllUserExpenses(userId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(userId);

      // assert
      expect(response, result);
      verify(mockExpenseRepository.syncAllUserExpenses(userId));
      verifyNoMoreInteractions(mockExpenseRepository);
    });

    test('should return failure when sync fails', () async {
      // arrange
      const userId = 'user123';
      final result = Result<int>.failure(error: 'Sync failed');

      when(mockExpenseRepository.syncAllUserExpenses(userId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(userId);

      // assert
      expect(response, result);
      verify(mockExpenseRepository.syncAllUserExpenses(userId));
    });
  });

  group('GetUserExpensesUsecase', () {
    late GetUserExpensesUsecase usecase;

    setUp(() {
      usecase = GetUserExpensesUsecase(mockExpenseRepository);
    });

    test('should get user expenses with all parameters', () async {
      // arrange
      final params = BaseParams(
        param: 'user123',
        orderBy: 'date',
        sortBy: 'DESC',
        limit: 10,
        offset: 0,
        contains: 'Rent',
      );
      const expenses = [
        ExpenseEntity(id: 1, createdById: 'user123', category: 'Rent', amount: 500000, date: '2025-01-01'),
        ExpenseEntity(id: 2, createdById: 'user123', category: 'Supplies', amount: 75000, date: '2025-01-02'),
      ];
      final result = Result<List<ExpenseEntity>>.success(data: expenses);

      when(
        mockExpenseRepository.getUserExpenses(
          params.param,
          orderBy: params.orderBy,
          sortBy: params.sortBy,
          limit: params.limit,
          offset: params.offset,
          contains: params.contains,
        ),
      ).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(params);

      // assert
      expect(response, result);
      verify(
        mockExpenseRepository.getUserExpenses(
          params.param,
          orderBy: params.orderBy,
          sortBy: params.sortBy,
          limit: params.limit,
          offset: params.offset,
          contains: params.contains,
        ),
      );
      verifyNoMoreInteractions(mockExpenseRepository);
    });
  });

  group('GetExpenseUsecase', () {
    late GetExpenseUsecase usecase;

    setUp(() {
      usecase = GetExpenseUsecase(mockExpenseRepository);
    });

    test('should get expense by id', () async {
      // arrange
      const expenseId = 1;
      const expense = ExpenseEntity(
        id: expenseId,
        createdById: 'user123',
        category: 'Rent',
        amount: 500000,
        date: '2025-01-01',
      );
      final result = Result<ExpenseEntity?>.success(data: expense);

      when(mockExpenseRepository.getExpense(expenseId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(expenseId);

      // assert
      expect(response, result);
      verify(mockExpenseRepository.getExpense(expenseId));
      verifyNoMoreInteractions(mockExpenseRepository);
    });
  });

  group('CreateExpenseUsecase', () {
    late CreateExpenseUsecase usecase;

    setUp(() {
      usecase = CreateExpenseUsecase(mockExpenseRepository);
    });

    test('should create expense successfully', () async {
      // arrange
      const expense = ExpenseEntity(
        createdById: 'user123',
        category: 'Utilities',
        amount: 120000,
        date: '2025-01-05',
      );
      final result = Result<int>.success(data: 1);

      when(mockExpenseRepository.createExpense(expense)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(expense);

      // assert
      expect(response, result);
      verify(mockExpenseRepository.createExpense(expense));
      verifyNoMoreInteractions(mockExpenseRepository);
    });
  });

  group('UpdateExpenseUsecase', () {
    late UpdateExpenseUsecase usecase;

    setUp(() {
      usecase = UpdateExpenseUsecase(mockExpenseRepository);
    });

    test('should update expense successfully', () async {
      // arrange
      const expense = ExpenseEntity(
        id: 1,
        createdById: 'user123',
        category: 'Utilities',
        amount: 130000,
        date: '2025-01-05',
      );
      final result = Result<void>.success(data: null);

      when(mockExpenseRepository.updateExpense(expense)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(expense);

      // assert
      expect(response, result);
      verify(mockExpenseRepository.updateExpense(expense));
      verifyNoMoreInteractions(mockExpenseRepository);
    });
  });

  group('DeleteExpenseUsecase', () {
    late DeleteExpenseUsecase usecase;

    setUp(() {
      usecase = DeleteExpenseUsecase(mockExpenseRepository);
    });

    test('should delete expense successfully', () async {
      // arrange
      const expenseId = 1;
      final result = Result<void>.success(data: null);

      when(mockExpenseRepository.deleteExpense(expenseId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(expenseId);

      // assert
      expect(response, result);
      verify(mockExpenseRepository.deleteExpense(expenseId));
      verifyNoMoreInteractions(mockExpenseRepository);
    });
  });
}
