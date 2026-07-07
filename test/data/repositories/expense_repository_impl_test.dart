import 'package:cellit/core/services/connectivity/ping_service.dart';
import 'package:cellit/core/common/result.dart';
import 'package:cellit/data/datasources/local/expense_local_datasource_impl.dart';
import 'package:cellit/data/datasources/local/queued_action_local_datasource_impl.dart';
import 'package:cellit/data/datasources/remote/expense_remote_datasource_impl.dart';
import 'package:cellit/data/models/expense_model.dart';
import 'package:cellit/data/repositories/expense_repository_impl.dart';
import 'package:cellit/domain/entities/expense_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'expense_repository_impl_test.mocks.dart';

@GenerateMocks([
  PingService,
  ExpenseLocalDatasourceImpl,
  ExpenseRemoteDatasourceImpl,
  QueuedActionLocalDatasourceImpl,
])
void main() {
  late ExpenseRepositoryImpl repository;
  late MockPingService mockPingService;
  late MockExpenseLocalDatasourceImpl mockLocalDatasource;
  late MockExpenseRemoteDatasourceImpl mockRemoteDatasource;
  late MockQueuedActionLocalDatasourceImpl mockQueuedActionDatasource;

  setUp(() {
    mockPingService = MockPingService();
    mockLocalDatasource = MockExpenseLocalDatasourceImpl();
    mockRemoteDatasource = MockExpenseRemoteDatasourceImpl();
    mockQueuedActionDatasource = MockQueuedActionLocalDatasourceImpl();

    // Provide dummy values for Mockito
    provideDummy<Result<List<ExpenseModel>>>(
      Result.success(data: <ExpenseModel>[]),
    );
    provideDummy<Result<ExpenseModel?>>(
      Result.success(
        data: ExpenseModel(
          id: 0,
          createdById: '',
          category: '',
          amount: 0,
          date: '',
        ),
      ),
    );
    provideDummy<Result<int>>(
      Result.success(data: 0),
    );
    provideDummy<Result<void>>(
      Result.success(data: null),
    );

    repository = ExpenseRepositoryImpl(
      pingService: mockPingService,
      expenseLocalDatasource: mockLocalDatasource,
      expenseRemoteDatasource: mockRemoteDatasource,
      queuedActionLocalDatasource: mockQueuedActionDatasource,
    );
  });

  group('syncAllUserExpenses', () {
    const userId = 'user123';
    final localExpenses = [
      ExpenseModel(
        id: 1,
        createdById: userId,
        category: 'Rent',
        amount: 500000,
        description: 'Monthly rent',
        date: '2025-01-01',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      ),
    ];
    final remoteExpenses = [
      ExpenseModel(
        id: 2,
        createdById: userId,
        category: 'Supplies',
        amount: 75000,
        description: 'Receipt paper rolls',
        date: '2025-01-02',
        createdAt: '2025-01-02T11:00:00Z',
        updatedAt: '2025-01-02T11:00:00Z',
      ),
    ];

    test('returns 0 when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);

      final result = await repository.syncAllUserExpenses(userId);

      expect(result.isSuccess, true);
      expect(result.data, 0);
      verifyNever(mockLocalDatasource.getAllUserExpenses(any));
      verifyNever(mockRemoteDatasource.getAllUserExpenses(any));
    });

    test('syncs all expenses when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getAllUserExpenses(userId)).thenAnswer((_) async => Result.success(data: localExpenses));
      when(
        mockRemoteDatasource.getAllUserExpenses(userId),
      ).thenAnswer((_) async => Result.success(data: remoteExpenses));
      when(mockRemoteDatasource.createExpense(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockLocalDatasource.createExpense(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.syncAllUserExpenses(userId);

      expect(result.isSuccess, true);
      expect(result.data, 2); // Both expenses synced
      verify(mockLocalDatasource.getAllUserExpenses(userId)).called(1);
      verify(mockRemoteDatasource.getAllUserExpenses(userId)).called(1);
    });

    test('returns failure when local datasource fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockLocalDatasource.getAllUserExpenses(userId),
      ).thenAnswer((_) async => Result.failure(error: 'Local error'));

      final result = await repository.syncAllUserExpenses(userId);

      expect(result.isFailure, true);
      expect(result.error, 'Local error');
    });

    test('returns failure when remote datasource fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getAllUserExpenses(userId)).thenAnswer((_) async => Result.success(data: localExpenses));
      when(
        mockRemoteDatasource.getAllUserExpenses(userId),
      ).thenAnswer((_) async => Result.failure(error: 'Remote error'));

      final result = await repository.syncAllUserExpenses(userId);

      expect(result.isFailure, true);
      expect(result.error, 'Remote error');
    });
  });

  group('createExpense', () {
    const expense = ExpenseEntity(
      id: 1,
      createdById: 'user123',
      category: 'Utilities',
      amount: 120000,
      description: 'Electricity bill',
      date: '2025-01-05',
      createdAt: '2025-01-05T09:00:00Z',
      updatedAt: '2025-01-05T09:00:00Z',
    );

    test('creates locally and remotely when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.createExpense(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockRemoteDatasource.createExpense(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.createExpense(expense);

      expect(result.isSuccess, true);
      expect(result.data, 1);
      verify(mockLocalDatasource.createExpense(any)).called(1);
      verify(mockRemoteDatasource.createExpense(any)).called(1);
      verifyNever(mockQueuedActionDatasource.createQueuedAction(any));
    });

    test('creates locally and queues action when offline', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.createExpense(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.createExpense(expense);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.createExpense(any)).called(1);
      verifyNever(mockRemoteDatasource.createExpense(any));
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);
    });

    test('returns failure when local create fails', () async {
      when(mockLocalDatasource.createExpense(any)).thenAnswer((_) async => Result.failure(error: 'Local error'));

      final result = await repository.createExpense(expense);

      expect(result.isFailure, true);
      expect(result.error, 'Local error');
      verifyNever(mockRemoteDatasource.createExpense(any));
    });
  });

  group('updateExpense', () {
    const expense = ExpenseEntity(
      id: 1,
      createdById: 'user123',
      category: 'Utilities',
      amount: 130000,
      description: 'Electricity bill (corrected)',
      date: '2025-01-05',
      createdAt: '2025-01-05T09:00:00Z',
      updatedAt: '2025-01-06T09:00:00Z',
    );

    test('updates locally and remotely when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.updateExpense(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.updateExpense(any)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.updateExpense(expense);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.updateExpense(any)).called(1);
      verify(mockRemoteDatasource.updateExpense(any)).called(1);
      verifyNever(mockQueuedActionDatasource.createQueuedAction(any));
    });

    test('updates locally and queues action when offline', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.updateExpense(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.updateExpense(expense);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.updateExpense(any)).called(1);
      verifyNever(mockRemoteDatasource.updateExpense(any));
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);
    });
  });

  group('deleteExpense', () {
    const expenseId = 1;

    test('deletes locally and remotely when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.deleteExpense(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.deleteExpense(any)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.deleteExpense(expenseId);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.deleteExpense(expenseId)).called(1);
      verify(mockRemoteDatasource.deleteExpense(expenseId)).called(1);
      verifyNever(mockQueuedActionDatasource.createQueuedAction(any));
    });

    test('deletes locally and queues action when offline', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.deleteExpense(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.deleteExpense(expenseId);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.deleteExpense(expenseId)).called(1);
      verifyNever(mockRemoteDatasource.deleteExpense(any));
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);
    });
  });

  group('getUserExpenses', () {
    const userId = 'user123';
    final localExpenses = [
      ExpenseModel(
        id: 1,
        createdById: userId,
        category: 'Rent',
        amount: 500000,
        date: '2025-01-01',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      ),
    ];

    test('returns local data when offline', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(
        mockLocalDatasource.getUserExpenses(
          userId,
          orderBy: anyNamed('orderBy'),
          sortBy: anyNamed('sortBy'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
          contains: anyNamed('contains'),
        ),
      ).thenAnswer((_) async => Result.success(data: localExpenses));

      final result = await repository.getUserExpenses(userId);

      expect(result.isSuccess, true);
      expect(result.data?.length, 1);
      expect(result.data?.first.category, 'Rent');
    });

    test('returns failure when local datasource fails', () async {
      when(
        mockLocalDatasource.getUserExpenses(
          userId,
          orderBy: anyNamed('orderBy'),
          sortBy: anyNamed('sortBy'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
          contains: anyNamed('contains'),
        ),
      ).thenAnswer((_) async => Result.failure(error: 'Local error'));

      final result = await repository.getUserExpenses(userId);

      expect(result.isFailure, true);
      expect(result.error, 'Local error');
    });
  });
}
