import 'package:snappdf/core/constants/app_constants.dart';
import 'package:snappdf/data/datasources/image_picker_datasource.dart';
import 'package:snappdf/data/datasources/image_processing_datasource.dart';
import 'package:snappdf/data/datasources/ocr_datasource.dart';
import 'package:snappdf/data/datasources/pdf_datasource.dart';
import 'package:snappdf/data/datasources/scanner_datasource.dart';
import 'package:snappdf/data/datasources/storage_datasource.dart';
import 'package:snappdf/domain/entities/scan_document.dart';
import 'package:snappdf/domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl({
    required ScannerDatasource scanner,
    required ImagePickerDatasource imagePicker,
    required ImageProcessingDatasource imageProcessing,
    required OcrDatasource ocr,
    required PdfDatasource pdf,
    required StorageDatasource storage,
  }) : _scanner = scanner,
       _imagePicker = imagePicker,
       _imageProcessing = imageProcessing,
       _ocr = ocr,
       _pdf = pdf,
       _storage = storage;

  final ScannerDatasource _scanner;
  final ImagePickerDatasource _imagePicker;
  final ImageProcessingDatasource _imageProcessing;
  final OcrDatasource _ocr;
  final PdfDatasource _pdf;
  final StorageDatasource _storage;

  @override
  Future<List<ScanDocument>> loadAll() => _storage.loadAll();

  @override
  Future<void> save(ScanDocument document) => _storage.save(document);

  @override
  Future<void> delete(String documentId) => _storage.delete(documentId);

  @override
  Future<List<String>> scanDocument() => _scanner.scan();

  @override
  Future<List<String>> importImages() async {
    final picked = await _imagePicker.pickImages();
    return _imageProcessing.importImages(picked);
  }

  @override
  Future<String> applyFilter(String imagePath, ScanFilter filter) =>
      _imageProcessing.applyFilter(imagePath, filter);

  @override
  Future<String> rotateImage(String imagePath, int degrees) =>
      _imageProcessing.rotate(imagePath, degrees);

  @override
  Future<String> extractText(String imagePath) => _ocr.recognize(imagePath);

  @override
  Future<String> generatePdf({
    required ScanDocument document,
    required PdfPageSize pageSize,
    String? password,
  }) => _pdf.generate(document: document, pageSize: pageSize, password: password);

  @override
  Future<void> shareFile(String path) => _storage.shareFile(path);
}
