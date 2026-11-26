import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:snappdf/core/errors/app_exception.dart';

class ScannerDatasource {
  final _scanner = DocumentScanner(
    options: DocumentScannerOptions(
      documentFormats: const {DocumentFormat.jpeg},
      mode: ScannerMode.full,
      isGalleryImport: true,
      pageLimit: 50,
    ),
  );

  Future<List<String>> scan() async {
    try {
      final result = await _scanner.scanDocument();
      final images = result.images;
      if (images == null || images.isEmpty) throw const ScanCancelledException();
      return images;
    } on ScanCancelledException {
      rethrow;
    } on PlatformException catch (e) {
      final code = e.code.toLowerCase();
      final msg = (e.message ?? '').toLowerCase();
      if (e.message == 'Operation cancelled' || code.contains('cancel') || msg.contains('cancel')) {
        throw const ScanCancelledException();
      }
      throw ScanException(e.message ?? e.code);
    } catch (e) {
      throw ScanException('$e');
    }
  }

  Future<void> dispose() => _scanner.close();
}
