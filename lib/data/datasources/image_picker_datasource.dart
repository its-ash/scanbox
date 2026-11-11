import 'package:image_picker/image_picker.dart';
import 'package:snappdf/core/errors/app_exception.dart';

/// Picks existing photos from the device gallery (Android photo picker, no
/// storage permission needed).
class ImagePickerDatasource {
  ImagePickerDatasource();

  final _picker = ImagePicker();

  /// Returns the temporary paths of the picked images, in selection order.
  /// Throws [ScanCancelledException] if the user picked nothing.
  Future<List<String>> pickImages({int? limit}) async {
    try {
      // imageQuality < 100 makes the picker re-encode HEIC/WebP/etc. as JPEG.
      final files = await _picker.pickMultiImage(imageQuality: 95, limit: limit);
      if (files.isEmpty) throw const ScanCancelledException();
      return files.map((f) => f.path).toList();
    } on ScanCancelledException {
      rethrow;
    } catch (e) {
      throw StorageException('could not pick images: $e');
    }
  }
}
