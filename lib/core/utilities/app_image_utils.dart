import 'package:app_image/app_image.dart';

/// Resolves the right [ImgProvider] for a stored image reference,
/// which may be a network URL or a local file path (offline-queued upload)
class AppImageUtils {
  // Prevents instantiation and extension
  AppImageUtils._();

  static ImgProvider providerFor(String? image) {
    if (image == null || image.isEmpty) return ImgProvider.networkImage;

    return image.startsWith('http') ? ImgProvider.networkImage : ImgProvider.fileImage;
  }
}
