import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snappdf/core/constants/app_constants.dart';
import 'package:snappdf/core/router/app_router.dart';
import 'package:snappdf/domain/entities/scan_document.dart';
import 'package:snappdf/presentation/providers/document_list_provider.dart';
import 'package:snappdf/presentation/providers/repository_providers.dart';
import 'package:snappdf/presentation/widgets/page_thumbnail.dart';
import 'package:theme/theme.dart';

class PdfPreviewScreen extends ConsumerStatefulWidget {
  const PdfPreviewScreen({super.key, required this.document});

  final ScanDocument document;

  @override
  ConsumerState<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends ConsumerState<PdfPreviewScreen> {
  PdfPageSize _pageSize = PdfPageSize.a4;
  bool _protect = false;
  final _passwordController = TextEditingController();
  final _titleController = TextEditingController();
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.document.title;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  String _sizeLabel(PdfPageSize size) => switch (size) {
    PdfPageSize.a4 => 'A4',
    PdfPageSize.letter => 'Letter',
    PdfPageSize.legal => 'Legal',
  };

  Future<void> _generateAndSave() async {
    if (_protect && _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a password or disable protection.')));
      return;
    }

    setState(() => _generating = true);
    try {
      final titled = widget.document.copyWith(title: _titleController.text.trim());
      final pdfPath = await ref
          .read(documentRepositoryProvider)
          .generatePdf(
            document: titled,
            pageSize: _pageSize,
            password: _protect ? _passwordController.text.trim() : null,
          );
      final finalDoc = titled.copyWith(pdfPath: pdfPath, isPasswordProtected: _protect);
      await ref.read(documentListProvider.notifier).saveDocument(finalDoc);

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => route.isFirst);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final document = widget.document;

    return Scaffold(
      appBar: AppBar(title: const Text('Create PDF')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          UiTextField(controller: _titleController, label: 'Document title'),
          const SizedBox(height: 20),
          Text('Pages', style: context.text.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: document.pages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => PageThumbnail(page: document.pages[i], index: i),
            ),
          ),
          const SizedBox(height: 20),
          Text('Page size', style: context.text.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<PdfPageSize>(
            segments: PdfPageSize.values
                .map((s) => ButtonSegment(value: s, label: Text(_sizeLabel(s))))
                .toList(),
            selected: {_pageSize},
            onSelectionChanged: (s) => setState(() => _pageSize = s.first),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Password protect'),
            value: _protect,
            onChanged: (v) => setState(() => _protect = v),
          ),
          if (_protect) ...[
            const SizedBox(height: 8),
            UiPasswordField(controller: _passwordController, label: 'PDF password'),
          ],
          const SizedBox(height: 28),
          UiButton(
            _generating ? 'Generating…' : 'Generate PDF',
            icon: Icons.picture_as_pdf_outlined,
            expand: true,
            onPressed: _generating ? null : _generateAndSave,
          ),
        ],
      ),
    );
  }
}
