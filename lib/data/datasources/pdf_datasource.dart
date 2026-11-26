import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:snappdf/core/constants/app_constants.dart';
import 'package:snappdf/core/errors/app_exception.dart';
import 'package:snappdf/domain/entities/scan_document.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

class PdfDatasource {
  const PdfDatasource();

  PdfPageFormat _formatFor(PdfPageSize size) => switch (size) {
    PdfPageSize.a4 => PdfPageFormat.a4,
    PdfPageSize.letter => PdfPageFormat.letter,
    PdfPageSize.legal => PdfPageFormat.legal,
  };

  Future<String> generate({
    required ScanDocument document,
    required PdfPageSize pageSize,
    String? password,
  }) async {
    try {
      final doc = pw.Document();
      final format = _formatFor(pageSize);

      for (final page in document.pages) {
        final bytes = await File(page.processedImagePath).readAsBytes();
        final image = pw.MemoryImage(bytes);
        doc.addPage(
          pw.Page(
            pageFormat: format,
            build: (context) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
          ),
        );
      }

      final dir = await getApplicationDocumentsDirectory();
      final outDir = Directory(p.join(dir.path, AppConstants.documentsDirName));
      if (!await outDir.exists()) await outDir.create(recursive: true);
      final outPath = p.join(outDir.path, '${document.id}.pdf');

      final generated = await doc.save();
      final bytes = (password != null && password.isNotEmpty)
          ? _encrypt(generated, password)
          : generated;

      final file = File(outPath);
      await file.writeAsBytes(bytes);
      return outPath;
    } catch (e) {
      throw PdfGenerationException('$e');
    }
  }

  List<int> _encrypt(List<int> bytes, String password) {
    final sfDoc = sf.PdfDocument(inputBytes: bytes);
    try {
      sfDoc.security.userPassword = password;
      sfDoc.security.ownerPassword = password;
      sfDoc.security.algorithm = sf.PdfEncryptionAlgorithm.aesx256Bit;
      return sfDoc.saveSync();
    } finally {
      sfDoc.dispose();
    }
  }
}
