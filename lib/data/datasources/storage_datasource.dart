import 'dart:convert';
import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snappdf/core/errors/app_exception.dart';
import 'package:snappdf/domain/entities/scan_document.dart';

class StorageDatasource {
  const StorageDatasource();

  static const _key = 'documents_index';

  Future<List<ScanDocument>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ScanDocument.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw StorageException('$e');
    }
  }

  Future<void> save(ScanDocument document) async {
    final prefs = await SharedPreferences.getInstance();
    final documents = await loadAll();
    final index = documents.indexWhere((d) => d.id == document.id);
    if (index >= 0) {
      documents[index] = document;
    } else {
      documents.add(document);
    }
    await prefs.setString(_key, jsonEncode(documents.map((d) => d.toJson()).toList()));
  }

  Future<void> delete(String documentId) async {
    final prefs = await SharedPreferences.getInstance();
    final documents = await loadAll();
    final target = documents.where((d) => d.id == documentId).firstOrNull;
    documents.removeWhere((d) => d.id == documentId);
    await prefs.setString(_key, jsonEncode(documents.map((d) => d.toJson()).toList()));

    if (target != null) {
      for (final page in target.pages) {
        _tryDelete(page.originalImagePath);
        _tryDelete(page.processedImagePath);
      }
      if (target.pdfPath != null) _tryDelete(target.pdfPath!);
    }
  }

  void _tryDelete(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    } on FileSystemException catch (_) {}
  }

  Future<void> shareFile(String path) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
  }
}
