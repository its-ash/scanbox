import 'package:snappdf/core/constants/app_constants.dart';
import 'package:snappdf/domain/entities/scan_document.dart';

abstract interface class DocumentRepository {
  Future<List<ScanDocument>> loadAll();
  Future<void> save(ScanDocument document);
  Future<void> delete(String documentId);

  Future<List<String>> scanDocument();

  /// Picks images from the gallery and returns app-owned JPEG copies.
  Future<List<String>> importImages();

  Future<String> applyFilter(String imagePath, ScanFilter filter);
  Future<String> rotateImage(String imagePath, int degrees);

  Future<String> extractText(String imagePath);

  Future<String> generatePdf({
    required ScanDocument document,
    required PdfPageSize pageSize,
    String? password,
  });

  Future<void> shareFile(String path);
}
