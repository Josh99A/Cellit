import '../../../../core/common/result.dart';

abstract class StorageRepository {
  Future<Result<String>> uploadUserPhoto(String imgPath);

  Future<Result<String?>> uploadProductImage(String imgPath);

  Future<Result<void>> queueProductImageUpload(int productId, String imagePath);

  Future<Result<void>> queueUserPhotoUpload(String userId, String imagePath);
}
