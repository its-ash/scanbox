import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snappdf/core/errors/app_exception.dart';
import 'package:snappdf/presentation/providers/edit_session_provider.dart';
import 'package:snappdf/presentation/widgets/filter_selector.dart';
import 'package:theme/theme.dart';

class PageEditSheet extends ConsumerStatefulWidget {
  const PageEditSheet({super.key, required this.pageId});

  final String pageId;

  @override
  ConsumerState<PageEditSheet> createState() => _PageEditSheetState();
}

class _PageEditSheetState extends ConsumerState<PageEditSheet> {
  bool _busy = false;
  String? _ocrText;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on AppException catch (e) {
      if (mounted) context.showToast(e.message, status: UiStatus.danger);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final document = ref.watch(editSessionProvider);
    final page = document.pages.where((p) => p.id == widget.pageId).firstOrNull;
    if (page == null) return const SizedBox.shrink();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.45),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: _busy
                      ? const Center(child: CircularProgressIndicator())
                      : Image.file(File(page.processedImagePath), fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilterSelector(
              selected: page.filter,
              enabled: !_busy,
              onSelected: (filter) => _run(
                () => ref.read(editSessionProvider.notifier).applyFilter(widget.pageId, filter),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.rotate_right_outlined),
                  tooltip: 'Rotate',
                  onPressed: _busy
                      ? null
                      : () => _run(
                          () => ref.read(editSessionProvider.notifier).rotatePage(widget.pageId),
                        ),
                ),
                IconButton(
                  icon: const Icon(Icons.text_snippet_outlined),
                  tooltip: 'Extract text',
                  onPressed: _busy
                      ? null
                      : () => _run(() async {
                          await ref.read(editSessionProvider.notifier).runOcr(widget.pageId);
                          if (!mounted) return;
                          final updated = ref
                              .read(editSessionProvider)
                              .pages
                              .where((p) => p.id == widget.pageId)
                              .firstOrNull;
                          if (updated != null) setState(() => _ocrText = updated.ocrText);
                        }),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete page',
                  onPressed: _busy
                      ? null
                      : () {
                          ref.read(editSessionProvider.notifier).removePage(widget.pageId);
                          Navigator.of(context).pop();
                        },
                ),
              ],
            ),
            if (_ocrText != null) ...[
              const SizedBox(height: 8),
              UiCard(
                padding: const EdgeInsets.all(UiSpace.md),
                child: Text(
                  _ocrText!.isEmpty ? 'No text found.' : _ocrText!,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 8),
            UiButton('Done', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
