import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:snappdf/core/constants/app_constants.dart';
import 'package:snappdf/core/errors/app_exception.dart';
import 'package:uuid/uuid.dart';

class ImageProcessingDatasource {
  const ImageProcessingDatasource();

  Future<String> applyFilter(String imagePath, ScanFilter filter) async {
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const StorageException('unreadable image');

    final processed = switch (filter) {
      ScanFilter.original => decoded,
      ScanFilter.magicColor => img.adjustColor(
        decoded,
        contrast: 1.15,
        saturation: 1.2,
        brightness: 1.05,
      ),
      ScanFilter.blackAndWhite => img.contrast(img.grayscale(decoded), contrast: 160),
      ScanFilter.grayscale => img.grayscale(decoded),
      ScanFilter.strongContrast => img.adjustColor(decoded, contrast: 1.5, saturation: 1.1),
    };

    return _writeJpg(processed);
  }

  Future<String> rotate(String imagePath, int degrees) async {
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const StorageException('unreadable image');
    final rotated = img.copyRotate(decoded, angle: degrees);
    return _writeJpg(rotated);
  }

  /// Copies picked images into the app documents dir as upright JPEGs (EXIF
  /// orientation baked in, so PDF pages are not sideways). Unreadable images
  /// are skipped.
  Future<List<String>> importImages(List<String> paths) async {
    final workDir = await _workDir();
    final quality = AppConstants.jpegQuality.toInt();
    // Decoding full-size photos is slow; keep it off the UI isolate.
    final out = await Isolate.run(() {
      final written = <String>[];
      for (final path in paths) {
        final decoded = img.decodeImage(File(path).readAsBytesSync());
        if (decoded == null) continue;
        final outPath = p.join(workDir, '${const Uuid().v4()}.jpg');
        File(outPath).writeAsBytesSync(img.encodeJpg(img.bakeOrientation(decoded), quality: quality));
        written.add(outPath);
      }
      return written;
    });
    if (out.isEmpty) throw const StorageException('none of the selected images could be read');
    return out;
  }

  Future<Uint8List> readBytes(String imagePath) => File(imagePath).readAsBytes();

  Future<String> _workDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final workDir = Directory(p.join(dir.path, AppConstants.documentsDirName));
    if (!await workDir.exists()) await workDir.create(recursive: true);
    return workDir.path;
  }

  Future<String> _writeJpg(img.Image image) async {
    final outPath = p.join(await _workDir(), '${const Uuid().v4()}.jpg');
    final jpg = img.encodeJpg(image, quality: AppConstants.jpegQuality.toInt());
    await File(outPath).writeAsBytes(jpg);
    return outPath;
  }
}
