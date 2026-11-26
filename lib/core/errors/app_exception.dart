sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

final class ScanCancelledException extends AppException {
  const ScanCancelledException() : super('Document scan was cancelled.');
}

final class ScanException extends AppException {
  const ScanException(String reason) : super('Failed to scan document: $reason.');
}

final class PermissionDeniedException extends AppException {
  const PermissionDeniedException(String permission)
    : super('Permission denied: $permission.');
}

final class PdfGenerationException extends AppException {
  const PdfGenerationException(String reason) : super('Failed to generate PDF: $reason.');
}

final class OcrException extends AppException {
  const OcrException(String reason) : super('Failed to extract text: $reason.');
}

final class StorageException extends AppException {
  const StorageException(String reason) : super('Storage error: $reason.');
}
