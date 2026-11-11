import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snappdf/core/constants/app_constants.dart';
import 'package:snappdf/domain/entities/scan_document.dart';
import 'package:snappdf/domain/entities/scan_page.dart';
import 'package:snappdf/presentation/providers/repository_providers.dart';
import 'package:uuid/uuid.dart';

class EditSessionNotifier extends Notifier<ScanDocument> {
  @override
  ScanDocument build() => ScanDocument(
    id: const Uuid().v4(),
    title: 'Scan ${DateTime.now().toIso8601String().substring(0, 10)}',
    createdAt: DateTime.now(),
    pages: const [],
  );

  void reset() => state = build();

  void loadExisting(ScanDocument document) => state = document;

  Future<void> scanAndAddPages() async {
    _addPages(await ref.read(documentRepositoryProvider).scanDocument());
  }

  Future<void> importAndAddPages() async {
    _addPages(await ref.read(documentRepositoryProvider).importImages());
  }

  void _addPages(List<String> imagePaths) {
    final newPages = imagePaths
        .map((path) => ScanPage(id: const Uuid().v4(), originalImagePath: path, processedImagePath: path))
        .toList();
    state = state.copyWith(pages: [...state.pages, ...newPages]);
  }

  void renameDocument(String title) => state = state.copyWith(title: title);

  void removePage(String pageId) {
    state = state.copyWith(pages: state.pages.where((p) => p.id != pageId).toList());
  }

  void reorderPages(int oldIndex, int newIndex) {
    final pages = [...state.pages];
    final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final page = pages.removeAt(oldIndex);
    pages.insert(index, page);
    state = state.copyWith(pages: pages);
  }

  Future<void> applyFilter(String pageId, ScanFilter filter) async {
    final page = state.pages.firstWhere((p) => p.id == pageId);
    final processed = await ref
        .read(documentRepositoryProvider)
        .applyFilter(page.originalImagePath, filter);
    _updatePage(page.copyWith(processedImagePath: processed, filter: filter));
  }

  Future<void> rotatePage(String pageId) async {
    final page = state.pages.firstWhere((p) => p.id == pageId);
    final rotated = await ref.read(documentRepositoryProvider).rotateImage(page.processedImagePath, 90);
    _updatePage(
      page.copyWith(
        processedImagePath: rotated,
        rotationDegrees: (page.rotationDegrees + 90) % 360,
      ),
    );
  }

  Future<void> runOcr(String pageId) async {
    final page = state.pages.firstWhere((p) => p.id == pageId);
    final text = await ref.read(documentRepositoryProvider).extractText(page.processedImagePath);
    _updatePage(page.copyWith(ocrText: text));
  }

  void _updatePage(ScanPage updated) {
    state = state.copyWith(
      pages: state.pages.map((p) => p.id == updated.id ? updated : p).toList(),
    );
  }
}

final editSessionProvider = NotifierProvider<EditSessionNotifier, ScanDocument>(
  EditSessionNotifier.new,
);
