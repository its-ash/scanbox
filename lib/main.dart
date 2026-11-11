import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snappdf/core/router/app_router.dart';
import 'package:snappdf/presentation/screens/shell/main_shell.dart';
import 'package:theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _migrateThemeMode();
  runApp(const ProviderScope(child: ScanboxApp()));
}

/// One-time: carry the old app-local `theme_mode` choice over to the shared
/// appearance setting.
Future<void> _migrateThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final old = prefs.getString('theme_mode');
  if (old == null) return;
  if (await UiAppearance.load() == null) {
    for (final m in ThemeMode.values) {
      if (m.name == old) await UiAppearance.save(m);
    }
  }
  await prefs.remove('theme_mode');
}

class ScanboxApp extends StatelessWidget {
  const ScanboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const UiApp(
      title: 'Scanbox',
      home: MainShell(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
