import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snappdf/core/router/app_router.dart';
import 'package:snappdf/domain/entities/scan_document.dart';
import 'package:snappdf/presentation/providers/edit_session_provider.dart';
import 'package:snappdf/presentation/screens/edit_pages/page_edit_sheet.dart';
import 'package:snappdf/presentation/widgets/page_thumbnail.dart';
import 'package:theme/theme.dart';

class EditPagesScreen extends ConsumerWidget {
  const EditPagesScreen({super.key});

  Future<void> _addMorePages(WidgetRef ref) async {
    try {
      await ref.read(editSessionProvider.notifier).scanAndAddPages();
    } catch (_) {
      // Scan cancelled — no-op.
    }
  }

  Future<void> _openPageEditor(BuildContext context, WidgetRef ref, String pageId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => PageEditSheet(pageId: pageId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = ref.watch(editSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${document.pages.length} page${document.pages.length == 1 ? '' : 's'}'),
        actions: [
          TextButton(
            onPressed: document.pages.isEmpty
                ? null
                : () => Navigator.of(context).pushNamed(AppRoutes.pdfPreview, arguments: document),
            child: const Text('Next'),
          ),
        ],
      ),
      body: document.pages.isEmpty
          ? const UiEmptyState(
              icon: Icons.photo_library_outlined,
              title: 'No pages yet',
              message: 'Scan a document to add pages.',
            )
          : ReorderableGridView(
              document: document,
              onTap: (pageId) => _openPageEditor(context, ref, pageId),
              onDelete: (pageId) => ref.read(editSessionProvider.notifier).removePage(pageId),
              onReorder: (o, n) => ref.read(editSessionProvider.notifier).reorderPages(o, n),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addMorePages(ref),
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }
}

class ReorderableGridView extends StatelessWidget {
  const ReorderableGridView({
    super.key,
    required this.document,
    required this.onTap,
    required this.onDelete,
    required this.onReorder,
  });

  final ScanDocument document;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onDelete;
  final void Function(int, int) onReorder;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: document.pages.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final page = document.pages[index];
        return Padding(
          key: ValueKey(page.id),
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              PageThumbnail(
                page: page,
                index: index,
                onTap: () => onTap(page.id),
                onDelete: () => onDelete(page.id),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.drag_handle),
            ],
          ),
        );
      },
    );
  }
}
