import 'package:flutter/material.dart';
import 'package:snappdf/domain/entities/scan_document.dart';
import 'package:snappdf/presentation/screens/document_viewer/document_viewer_screen.dart';
import 'package:snappdf/presentation/screens/edit_pages/edit_pages_screen.dart';
import 'package:snappdf/presentation/screens/pdf_preview/pdf_preview_screen.dart';
import 'package:snappdf/presentation/screens/shell/main_shell.dart';

class AppRoutes {
  AppRoutes._();

  static const home = '/';
  static const editPages = '/edit-pages';
  static const pdfPreview = '/pdf-preview';
  static const documentViewer = '/document-viewer';
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const MainShell());
      case AppRoutes.editPages:
        return MaterialPageRoute(builder: (_) => const EditPagesScreen());
      case AppRoutes.pdfPreview:
        return MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(document: settings.arguments as ScanDocument),
        );
      case AppRoutes.documentViewer:
        return MaterialPageRoute(
          builder: (_) => DocumentViewerScreen(document: settings.arguments as ScanDocument),
        );
      default:
        return MaterialPageRoute(builder: (_) => const MainShell());
    }
  }
}
