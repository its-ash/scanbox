import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:snappdf/core/router/app_router.dart';
import 'package:snappdf/domain/entities/scan_document.dart';
import 'package:snappdf/presentation/providers/document_list_provider.dart';
import 'package:snappdf/presentation/providers/edit_session_provider.dart';
import 'package:theme/theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _startScan(BuildContext context, WidgetRef ref) async {
    ref.read(editSessionProvider.notifier).reset();
    try {
      await ref.read(editSessionProvider.notifier).scanAndAddPages();
      if (!context.mounted) return;
      Navigator.of(context).pushNamed(AppRoutes.editPages);
    } catch (_) {
      // Scan cancelled by user — no-op.
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, ScanDocument doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete document'),
        content: Text('Delete "${doc.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(documentListProvider.notifier).deleteDocument(doc.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(documentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SnapPDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: documentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => UiErrorState(message: '$error'),
        data: (documents) {
          if (documents.isEmpty) {
            return const UiEmptyState(
              icon: Icons.document_scanner_outlined,
              title: 'No documents yet',
              message: 'Tap the camera button to scan your first document.',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(documentListProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: UiSpace.md),
                  child: UiCard(
                    padding: EdgeInsets.zero,
                    child: UiListTile(
                      doc.title,
                      icon: Icons.picture_as_pdf_outlined,
                      subtitle:
                          '${doc.pages.length} page${doc.pages.length == 1 ? '' : 's'} · '
                          '${DateFormat.yMMMd().format(doc.createdAt)}',
                      trailing: UiIconButton(
                        Icons.delete_outline,
                        tooltip: 'Delete',
                        onPressed: () => _confirmDelete(context, ref, doc),
                      ),
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.documentViewer, arguments: doc),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startScan(context, ref),
        icon: const Icon(Icons.camera_alt_outlined),
        label: const Text('Scan'),
        shape: const StadiumBorder(),
      ),
    );
  }
}
