enum PdfPageSize { a4, letter, legal }

enum ScanFilter { original, magicColor, blackAndWhite, grayscale, strongContrast }

class AppConstants {
  AppConstants._();

  static const String appName = 'Scanbox';
  static const String documentsDirName = 'snappdf_documents';
  static const String thumbnailsDirName = 'snappdf_thumbnails';
  static const double jpegQuality = 92;
  static const int maxPagesPerDocument = 200;
}
