class ProductImageUploadParams {
  final int productId;
  final String imagePath;

  const ProductImageUploadParams({
    required this.productId,
    required this.imagePath,
  });
}

class UserPhotoUploadParams {
  final String userId;
  final String imagePath;

  const UserPhotoUploadParams({
    required this.userId,
    required this.imagePath,
  });
}
