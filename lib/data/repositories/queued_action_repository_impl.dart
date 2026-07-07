import 'dart:convert';
import 'dart:io';

import '../../core/common/result.dart';
import '../../core/services/connectivity/ping_service.dart';
import '../../core/services/image/image_file_service.dart';
import '../../core/utilities/console_logger.dart';
import '../../domain/entities/queued_action_entity.dart';
import '../../domain/repositories/queued_action_repository.dart';
import '../datasources/local/product_local_datasource_impl.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../datasources/local/user_local_datasource_impl.dart';
import '../datasources/remote/expense_remote_datasource_impl.dart';
import '../datasources/remote/product_remote_datasource_impl.dart';
import '../datasources/remote/storage_remote_datasource_impl.dart';
import '../datasources/remote/transaction_remote_datasource_impl.dart';
import '../datasources/remote/user_remote_datasource_impl.dart';
import '../models/expense_model.dart';
import '../models/product_model.dart';
import '../models/queued_action_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class QueuedActionRepositoryImpl extends QueuedActionRepository {
  final PingService pingService;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;
  final UserRemoteDatasourceImpl userRemoteDatasource;
  final TransactionRemoteDatasourceImpl transactionRemoteDatasource;
  final ProductRemoteDatasourceImpl productRemoteDatasource;
  final ExpenseRemoteDatasourceImpl expenseRemoteDatasource;
  final StorageRemoteDataSourceImpl storageRemoteDataSource;
  final ProductLocalDatasourceImpl productLocalDatasource;
  final UserLocalDatasourceImpl userLocalDatasource;

  QueuedActionRepositoryImpl({
    required this.pingService,
    required this.queuedActionLocalDatasource,
    required this.userRemoteDatasource,
    required this.transactionRemoteDatasource,
    required this.productRemoteDatasource,
    required this.expenseRemoteDatasource,
    required this.storageRemoteDataSource,
    required this.productLocalDatasource,
    required this.userLocalDatasource,
  });

  @override
  Future<Result<List<QueuedActionEntity>>> getAllQueuedAction() async {
    try {
      final res = await queuedActionLocalDatasource.getAllUserQueuedAction();
      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: res.data!.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<bool>>> executeAllQueuedActions(List<QueuedActionEntity> queues) async {
    try {
      if (queues.isEmpty) return Result.success(data: []);

      List<bool> result = [];

      for (final queue in queues) {
        // Pass if the internet goes off in the process
        if (!pingService.isConnected) continue;

        final res = await executeQueuedAction(queue);

        result.add(res.isSuccess);
      }

      return Result.success(data: result);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<bool>> executeQueuedAction(QueuedActionEntity queue) async {
    try {
      cl(QueuedActionModel.fromEntity(queue).toJson());

      final res = await _functionSelector(queue);

      if (res.isSuccess) {
        // Delete executed queue from db
        final deleteRes = await queuedActionLocalDatasource.deleteQueuedAction(queue.id!);
        if (deleteRes.isFailure) return Result.failure(error: res.error!);

        return Result.success(data: true);
      } else {
        return Result.failure(error: res.error ?? 'Unknown error');
      }
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<Null>> _functionSelector(QueuedActionEntity queue) async {
    try {
      if (queue.repository == 'UserRepositoryImpl') {
        if (queue.method == 'createUser') {
          UserModel param = UserModel.fromJson(jsonDecode(queue.param));

          final res = await userRemoteDatasource.createUser(param);
          if (res.isFailure) return Result.failure(error: res.error!);

          return Result.success(data: null);
        }

        if (queue.method == 'deleteUser') {
          final param = queue.param;

          final res = await userRemoteDatasource.deleteUser(param);
          if (res.isFailure) return Result.failure(error: res.error!);

          return Result.success(data: null);
        }

        if (queue.method == 'updateUser') {
          UserModel param = UserModel.fromJson(jsonDecode(queue.param));

          final res = await userRemoteDatasource.updateUser(param);
          if (res.isFailure) return Result.failure(error: res.error!);

          return Result.success(data: null);
        }
      }

      if (queue.repository == 'TransactionRepositoryImpl') {
        if (queue.method == 'createTransaction') {
          TransactionModel param = TransactionModel.fromJson(jsonDecode(queue.param));

          final res = await transactionRemoteDatasource.createTransaction(param);
          if (res.isFailure) return Result.failure(error: res.error!);

          return Result.success(data: null);
        }

        if (queue.method == 'deleteTransaction') {
          final param = int.parse(queue.param);

          final res = await transactionRemoteDatasource.deleteTransaction(param);
          if (res.isFailure) return Result.failure(error: res.error!);

          return Result.success(data: null);
        }

        if (queue.method == 'updateTransaction') {
          TransactionModel param = TransactionModel.fromJson(jsonDecode(queue.param));

          final res = await transactionRemoteDatasource.updateTransaction(param);
          if (res.isFailure) return Result.failure(error: res.error!);

          return Result.success(data: null);
        }
      }

      if (queue.repository == 'ProductRepositoryImpl') {
        if (queue.method == 'createProduct') {
          ProductModel param = ProductModel.fromJson(jsonDecode(queue.param));

          final res = await productRemoteDatasource.createProduct(param);
          if (res.isFailure) return Result.failure(error: res.error!);

          return Result.success(data: null);
        }

        if (queue.method == 'deleteProduct') {
          final param = int.parse(queue.param);

          final res = await productRemoteDatasource.deleteProduct(param);
          if (res.isFailure) return Result.failure(error: res.error!);

          return Result.success(data: null);
        }

        if (queue.method == 'updateProduct') {
          ProductModel param = ProductModel.fromJson(jsonDecode(queue.param));

          final res = await productRemoteDatasource.updateProduct(param);
          if (res.isFailure) return Result.failure(error: res.error!);

          return Result.success(data: null);
        }
      }

      if (queue.repository == 'ExpenseRepositoryImpl') {
        if (queue.method == 'createExpense') {
          ExpenseModel param = ExpenseModel.fromJson(jsonDecode(queue.param));

          final res = await expenseRemoteDatasource.createExpense(param);
          if (res.isFailure) return Result.failure(error: res.error!);

          return Result.success(data: null);
        }

        if (queue.method == 'deleteExpense') {
          final param = int.parse(queue.param);

          final res = await expenseRemoteDatasource.deleteExpense(param);
          if (res.isFailure) return Result.failure(error: res.error!);

          return Result.success(data: null);
        }

        if (queue.method == 'updateExpense') {
          ExpenseModel param = ExpenseModel.fromJson(jsonDecode(queue.param));

          final res = await expenseRemoteDatasource.updateExpense(param);
          if (res.isFailure) return Result.failure(error: res.error!);

          return Result.success(data: null);
        }
      }

      if (queue.repository == 'StorageRepositoryImpl') {
        if (queue.method == 'uploadProductImage') {
          final param = jsonDecode(queue.param);
          final int productId = param['productId'];
          final String imagePath = param['imagePath'];

          // Image file no longer exists, nothing to upload; clear the queue
          if (!File(imagePath).existsSync()) return Result.success(data: null);

          final upload = await storageRemoteDataSource.uploadProductImage(imagePath);
          if (upload.isFailure) return Result.failure(error: upload.error!);

          final local = await productLocalDatasource.getProduct(productId);
          if (local.isFailure) return Result.failure(error: local.error!);

          final product = local.data;

          if (product != null) {
            product.imageUrl = upload.data!;

            final localUpdate = await productLocalDatasource.updateProduct(product);
            if (localUpdate.isFailure) return Result.failure(error: localUpdate.error!);

            final remoteUpdate = await productRemoteDatasource.updateProduct(product);
            if (remoteUpdate.isFailure) return Result.failure(error: remoteUpdate.error!);
          }

          await ImageFileService.deleteImage(imagePath);

          return Result.success(data: null);
        }

        if (queue.method == 'uploadUserPhoto') {
          final param = jsonDecode(queue.param);
          final String userId = param['userId'];
          final String imagePath = param['imagePath'];

          // Image file no longer exists, nothing to upload; clear the queue
          if (!File(imagePath).existsSync()) return Result.success(data: null);

          final upload = await storageRemoteDataSource.uploadUserPhoto(imagePath);
          if (upload.isFailure) return Result.failure(error: upload.error!);

          final local = await userLocalDatasource.getUser(userId);
          if (local.isFailure) return Result.failure(error: local.error!);

          final user = local.data;

          if (user != null) {
            user.imageUrl = upload.data!;

            final localUpdate = await userLocalDatasource.updateUser(user);
            if (localUpdate.isFailure) return Result.failure(error: localUpdate.error!);

            final remoteUpdate = await userRemoteDatasource.updateUser(user);
            if (remoteUpdate.isFailure) return Result.failure(error: remoteUpdate.error!);
          }

          await ImageFileService.deleteImage(imagePath);

          return Result.success(data: null);
        }
      }

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
