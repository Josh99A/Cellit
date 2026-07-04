import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../repositories/storage_repository.dart';
import 'params/image_upload_params.dart';

class UploadUserPhotoUsecase extends Usecase<Result, String> {
  UploadUserPhotoUsecase(this._storageRepository);

  final StorageRepository _storageRepository;

  @override
  Future<Result<String?>> call(String imgPath) async => _storageRepository.uploadUserPhoto(imgPath);
}

class UploadProductImageUsecase extends Usecase<Result, String> {
  UploadProductImageUsecase(this._storageRepository);

  final StorageRepository _storageRepository;

  @override
  Future<Result<String?>> call(String imgPath) async => _storageRepository.uploadProductImage(imgPath);
}

class QueueProductImageUploadUsecase extends Usecase<Result, ProductImageUploadParams> {
  QueueProductImageUploadUsecase(this._storageRepository);

  final StorageRepository _storageRepository;

  @override
  Future<Result<void>> call(ProductImageUploadParams params) async =>
      _storageRepository.queueProductImageUpload(params.productId, params.imagePath);
}

class QueueUserPhotoUploadUsecase extends Usecase<Result, UserPhotoUploadParams> {
  QueueUserPhotoUploadUsecase(this._storageRepository);

  final StorageRepository _storageRepository;

  @override
  Future<Result<void>> call(UserPhotoUploadParams params) async =>
      _storageRepository.queueUserPhotoUpload(params.userId, params.imagePath);
}
