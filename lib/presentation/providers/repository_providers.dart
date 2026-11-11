import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snappdf/data/datasources/image_picker_datasource.dart';
import 'package:snappdf/data/datasources/image_processing_datasource.dart';
import 'package:snappdf/data/datasources/ocr_datasource.dart';
import 'package:snappdf/data/datasources/pdf_datasource.dart';
import 'package:snappdf/data/datasources/scanner_datasource.dart';
import 'package:snappdf/data/datasources/storage_datasource.dart';
import 'package:snappdf/data/repositories/document_repository_impl.dart';
import 'package:snappdf/domain/repositories/document_repository.dart';

final scannerDatasourceProvider = Provider<ScannerDatasource>((ref) {
  final datasource = ScannerDatasource();
  ref.onDispose(datasource.dispose);
  return datasource;
});

final ocrDatasourceProvider = Provider<OcrDatasource>((ref) {
  final datasource = OcrDatasource();
  ref.onDispose(datasource.dispose);
  return datasource;
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl(
    scanner: ref.watch(scannerDatasourceProvider),
    imagePicker: ImagePickerDatasource(),
    imageProcessing: const ImageProcessingDatasource(),
    ocr: ref.watch(ocrDatasourceProvider),
    pdf: const PdfDatasource(),
    storage: const StorageDatasource(),
  );
});
