import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snappdf/presentation/providers/document_list_provider.dart';
import 'package:snappdf/presentation/screens/history/history_screen.dart';
import 'package:snappdf/presentation/screens/home/new_document_actions.dart';
import 'package:theme/theme.dart';

/// Start tab: create a document (scan or images) and see the latest ones.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.onSeeAll});

  /// Opens the History tab.
  final VoidCallback? onSeeAll;

  static const _recentCount = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(documentListProvider).valueOrNull?.take(_recentCount).toList() ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Scanbox')),
      body: ListView(
        padding: const EdgeInsets.all(UiSpace.lg),
        children: [
          _ActionCard(
            icon: Icons.document_scanner_outlined,
            title: 'Scan document',
            subtitle: 'Use the camera with edge detection and cropping',
            onTap: () => startScan(context, ref),
          ),
          const SizedBox(height: UiSpace.md),
          _ActionCard(
            icon: Icons.photo_library_outlined,
            title: 'Images to PDF',
            subtitle: 'Pick photos from your gallery and turn them into a PDF',
            onTap: () => startImageImport(context, ref),
          ),
          if (recent.isNotEmpty) ...[
            const SizedBox(height: UiSpace.xl),
            UiSectionHeader('Recent', actionLabel: 'See all', onAction: onSeeAll),
            const SizedBox(height: UiSpace.md),
            for (final doc in recent)
              Padding(
                padding: const EdgeInsets.only(bottom: UiSpace.md),
                child: DocumentCard(document: doc),
              ),
          ],
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return UiCard(
      padding: EdgeInsets.zero,
      child: UiListTile(title, icon: icon, subtitle: subtitle, chevron: true, onTap: onTap),
    );
  }
}
