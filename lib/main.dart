import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snappdf/core/router/app_router.dart';
import 'package:snappdf/presentation/providers/theme_mode_provider.dart';
import 'package:theme/theme.dart';

void main() {
  runApp(const ProviderScope(child: ScanboxApp()));
}

class ScanboxApp extends ConsumerWidget {
  const ScanboxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Scanbox',
      debugShowCheckedModeBanner: false,
      theme: UiTheme.light(),
      darkTheme: UiTheme.dark(),
      themeMode: themeMode,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
