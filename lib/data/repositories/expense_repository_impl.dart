import 'dart:convert';

import '../../core/common/result.dart';
import '../../core/constants/constants.dart';
import '../../core/services/connectivity/ping_service.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/local/expense_local_datasource_impl.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../datasources/remote/expense_remote_datasource_impl.dart';
import '../models/expense_model.dart';
import '../models/queued_action_model.dart';

class ExpenseRepositoryImpl extends ExpenseRepository {
  final PingService pingService;
  final ExpenseLocalDatasourceImpl expenseLocalDatasource;
  final ExpenseRemoteDatasourceImpl expenseRemoteDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  ExpenseRepositoryImpl({
    required this.pingService,
    required this.expenseLocalDatasource,
    required this.expenseRemoteDatasource,
    required this.queuedActionLocalDatasource,
  });

  @override
  Future<Result<int>> syncAllUserExpenses(String userId) async {
    try {
      if (pingService.isConnected) {
        final local = await expenseLocalDatasource.getAllUserExpenses(userId);
        if (local.isFailure) return Result.failure(error: local.error!);

        final remote = await expenseRemoteDatasource.getAllUserExpenses(userId);
        if (remote.isFailure) return Result.failure(error: remote.error!);

        final res = await _syncExpenses(local.data!, remote.data!);

        // Sum all local and remote sync counts
        int totalSyncedCount = res.$1 + res.$2;

        // Return synced data count
        return Result.success(data: totalSyncedCount);
      }

      return Result.success(data: 0);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ExpenseEntity>>> getUserExpenses(
    String userId, {
    String orderBy = 'date',
    String sortBy = 'DESC',
    int limit = 10,
    int? offset,
    String? contains,
  }) async {
    try {
      final local = await expenseLocalDatasource.getUserExpenses(
        userId,
        orderBy: orderBy,
        sortBy: sortBy,
        limit: limit,
        offset: offset,
        contains: contains,
      );

      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await expenseRemoteDatasource.getUserExpenses(
          userId,
          orderBy: orderBy,
          sortBy: sortBy,
          limit: limit,
          offset: offset,
          contains: contains,
        );

        if (remote.isFailure) return Result.failure(error: remote.error!);

        final res = await _syncExpenses(local.data!, remote.data!);

        int syncedToLocalCount = res.$1;
        int syncedToRemoteCount = res.$2;

        // If more data was synced to the local, return the remote data
        if (syncedToLocalCount > syncedToRemoteCount) {
          // Return remote data
          return Result.success(data: remote.data!.map((e) => e.toEntity()).toList());
        } else {
          // Return local data
          return Result.success(data: local.data!.map((e) => e.toEntity()).toList());
        }
      }

      return Result.success(data: local.data!.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<ExpenseEntity?>> getExpense(int expenseId) async {
    try {
      final local = await expenseLocalDatasource.getExpense(expenseId);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await expenseRemoteDatasource.getExpense(expenseId);
        if (remote.isFailure) return Result.failure(error: remote.error!);

        List<ExpenseModel> localToList = [if (local.data != null) local.data!];
        List<ExpenseModel> remoteToList = [if (remote.data != null) remote.data!];

        final res = await _syncExpenses(localToList, remoteToList);

        int syncedToLocalCount = res.$1;
        int syncedToRemoteCount = res.$2;

        // If more data was synced to the local, return the remote data
        if (syncedToLocalCount > syncedToRemoteCount) {
          // Return remote data
          return Result.success(data: remote.data?.toEntity());
        } else {
          // Return local data
          return Result.success(data: local.data?.toEntity());
        }
      }

      return Result.success(data: local.data?.toEntity());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createExpense(ExpenseEntity expense) async {
    try {
      final data = ExpenseModel.fromEntity(expense);

      final local = await expenseLocalDatasource.createExpense(data);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await expenseRemoteDatasource.createExpense(data);
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecond,
            repository: 'ExpenseRepositoryImpl',
            method: 'createExpense',
            param: jsonEncode(data.toJson()),
            isCritical: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        if (res.isFailure) return Result.failure(error: res.error!);
      }

      return Result.success(data: local.data!);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteExpense(int expenseId) async {
    try {
      final local = await expenseLocalDatasource.deleteExpense(expenseId);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await expenseRemoteDatasource.deleteExpense(expenseId);
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecond,
            repository: 'ExpenseRepositoryImpl',
            method: 'deleteExpense',
            param: expenseId.toString(),
            isCritical: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        if (res.isFailure) return Result.failure(error: res.error!);
      }

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateExpense(ExpenseEntity expense) async {
    try {
      final local = await expenseLocalDatasource.updateExpense(ExpenseModel.fromEntity(expense));
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await expenseRemoteDatasource.updateExpense(ExpenseModel.fromEntity(expense));
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecond,
            repository: 'ExpenseRepositoryImpl',
            method: 'updateExpense',
            param: jsonEncode(ExpenseModel.fromEntity(expense).toJson()),
            isCritical: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        if (res.isFailure) return Result.failure(error: res.error!);
      }

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  // Perform a sync between local and remote data
  Future<(int, int)> _syncExpenses(List<ExpenseModel> local, List<ExpenseModel> remote) async {
    int syncedToLocalCount = 0;
    int syncedToRemoteCount = 0;

    // Track processed IDs to avoid duplicate syncing
    final processedIds = <int>{};

    // Process local expenses first
    for (final localData in local) {
      final matchRemoteData = remote.where((remoteData) => remoteData.id == localData.id).firstOrNull;

      if (matchRemoteData != null) {
        // Mark as processed
        processedIds.add(localData.id);

        final updatedAtLocal = DateTime.tryParse(localData.updatedAt ?? '');
        final updatedAtRemote = DateTime.tryParse(matchRemoteData.updatedAt ?? '');

        // Skip if either timestamp is invalid
        if (updatedAtLocal == null || updatedAtRemote == null) continue;

        final differenceInMinutes = updatedAtRemote.difference(updatedAtLocal).inMinutes;
        final isDiffSignificant = differenceInMinutes.abs() > Constants.minSyncIntervalToleranceForCriticalInMinutes;

        // Check which is newer based on the difference
        final isRemoteNewer = isDiffSignificant && differenceInMinutes > 0;
        final isLocalNewer = isDiffSignificant && differenceInMinutes < 0;

        if (isRemoteNewer) {
          // Save remote data to local db
          final res = await expenseLocalDatasource.updateExpense(matchRemoteData);
          if (res.isSuccess) syncedToLocalCount += 1;
        } else if (isLocalNewer) {
          // Update remote with local data
          final res = await expenseRemoteDatasource.updateExpense(localData);
          if (res.isSuccess) syncedToRemoteCount += 1;
        }
        // If not significant difference, do nothing (already in sync)
      } else {
        // No matching remote expense, create it
        processedIds.add(localData.id);
        final res = await expenseRemoteDatasource.createExpense(localData);
        if (res.isSuccess) syncedToRemoteCount += 1;
      }
    }

    // Process remaining remote expenses that weren't in local
    for (final remoteData in remote) {
      // Skip if already processed in the first loop
      if (processedIds.contains(remoteData.id)) continue;

      // No matching local expense, create it locally
      final res = await expenseLocalDatasource.createExpense(remoteData);
      if (res.isSuccess) syncedToLocalCount += 1;
    }

    return (syncedToLocalCount, syncedToRemoteCount);
  }
}
