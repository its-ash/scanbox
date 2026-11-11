import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snappdf/core/errors/app_exception.dart';
import 'package:snappdf/core/router/app_router.dart';
import 'package:snappdf/presentation/providers/edit_session_provider.dart';
import 'package:theme/theme.dart';

/// Starts a new document from the camera scanner, then opens the page editor.
Future<void> startScan(BuildContext context, WidgetRef ref) =>
    _startNewDocument(context, ref, (notifier) => notifier.scanAndAddPages());

/// Starts a new document from gallery images, then opens the page editor.
Future<void> startImageImport(BuildContext context, WidgetRef ref) =>
    _startNewDocument(context, ref, (notifier) => notifier.importAndAddPages());

Future<void> _startNewDocument(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function(EditSessionNotifier notifier) addPages,
) async {
  final notifier = ref.read(editSessionProvider.notifier)..reset();
  try {
    await addPages(notifier);
    if (!context.mounted) return;
    Navigator.of(context).pushNamed(AppRoutes.editPages);
  } on ScanCancelledException {
    // Closed without picking anything — no-op.
  } on AppException catch (e) {
    if (context.mounted) context.showToast(e.message, status: UiStatus.danger);
  }
}
