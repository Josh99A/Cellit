import 'dart:async';
import 'dart:convert';

import '../../../../core/common/result.dart';
import '../../core/services/connectivity/ping_service.dart';
import '../../domain/repositories/storage_repository.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../datasources/remote/storage_remote_datasource_impl.dart';
import '../models/queued_action_model.dart';

class StorageRepositoryImpl implements StorageRepository {
  static const Duration _uploadTimeout = Duration(seconds: 30);

  final PingService pingService;
  final StorageRemoteDataSourceImpl storageRemoteDataSource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  StorageRepositoryImpl({
    required this.pingService,
    required this.storageRemoteDataSource,
    required this.queuedActionLocalDatasource,
  });

  @override
  Future<Result<String>> uploadUserPhoto(String imgPath) async {
    try {
      if (pingService.isKnownOffline) {
        return Result.failure(error: 'Photo upload failed. Please check your internet connection and try again');
      }

      final res = await storageRemoteDataSource.uploadUserPhoto(imgPath).timeout(_uploadTimeout);
      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: res.data!);
    } on TimeoutException {
      return Result.failure(error: 'Photo upload timed out. Please check your internet connection and try again');
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<String>> uploadProductImage(String imgPath) async {
    try {
      if (pingService.isKnownOffline) {
        return Result.failure(error: 'Image upload failed. Please check your internet connection and try again');
      }

      final res = await storageRemoteDataSource.uploadProductImage(imgPath).timeout(_uploadTimeout);
      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: res.data!);
    } on TimeoutException {
      return Result.failure(error: 'Image upload timed out. Please check your internet connection and try again');
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> queueProductImageUpload(int productId, String imagePath) async {
    try {
      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecondsSinceEpoch,
          repository: 'StorageRepositoryImpl',
          method: 'uploadProductImage',
          param: jsonEncode({'productId': productId, 'imagePath': imagePath}),
          isCritical: true,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> queueUserPhotoUpload(String userId, String imagePath) async {
    try {
      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecondsSinceEpoch,
          repository: 'StorageRepositoryImpl',
          method: 'uploadUserPhoto',
          param: jsonEncode({'userId': userId, 'imagePath': imagePath}),
          isCritical: true,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
