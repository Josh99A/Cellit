import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Persists picked images into app documents storage so offline-queued uploads
/// survive picker-cache cleanup and app restarts
class ImageFileService {
  // Prevents instantiation and extension
  ImageFileService._();

  static const String _queuedImagesDirName = 'queued_images';

  static Future<String> persistImage(String sourcePath) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(documentsDir.path, _queuedImagesDirName));

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}';
    final copied = await File(sourcePath).copy(p.join(imagesDir.path, fileName));

    return copied.path;
  }

  static Future<void> deleteImage(String path) async {
    final file = File(path);

    if (await file.exists()) {
      await file.delete();
    }
  }
}
