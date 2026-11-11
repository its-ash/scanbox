import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:snappdf/core/router/app_router.dart';
import 'package:snappdf/domain/entities/scan_document.dart';
import 'package:snappdf/presentation/providers/document_list_provider.dart';
import 'package:theme/theme.dart';

/// All saved documents, newest first.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(documentListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: documentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => UiErrorState(message: '$error'),
        data: (documents) {
          if (documents.isEmpty) {
            return const UiEmptyState(
              icon: Icons.history,
              title: 'No documents yet',
              message: 'Documents you scan or create from images show up here.',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(documentListProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(UiSpace.lg),
              itemCount: documents.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: UiSpace.md),
                child: DocumentCard(document: documents[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// One saved document: opens the viewer on tap, delete button with confirm.
class DocumentCard extends ConsumerWidget {
  const DocumentCard({super.key, required this.document});

  final ScanDocument document;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete document'),
        content: Text('Delete "${document.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(documentListProvider.notifier).deleteDocument(document.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = document.pages.length;
    return UiCard(
      padding: EdgeInsets.zero,
      child: UiListTile(
        document.title,
        icon: Icons.picture_as_pdf_outlined,
        subtitle:
            '$pages page${pages == 1 ? '' : 's'} · ${DateFormat.yMMMd().format(document.createdAt)}',
        trailing: UiIconButton(
          Icons.delete_outline,
          tooltip: 'Delete',
          onPressed: () => _confirmDelete(context, ref),
        ),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.documentViewer, arguments: document),
      ),
    );
  }
}
