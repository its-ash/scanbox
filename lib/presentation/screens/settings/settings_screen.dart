import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snappdf/core/constants/app_constants.dart';
import 'package:snappdf/presentation/providers/theme_mode_provider.dart';
import 'package:theme/theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _label(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System default',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          RadioGroup<ThemeMode>(
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
            child: Column(
              children: [
                for (final mode in ThemeMode.values)
                  RadioListTile<ThemeMode>(title: Text(_label(mode)), value: mode),
              ],
            ),
          ),
          const Divider(),
          const ListTile(
            title: Text('Offline document scanner & PDF creator'),
            subtitle: Text(AppConstants.appName),
          ),
          const SizedBox(height: 16),
          // No INTERNET permission: the row opens the latest APK download in the browser.
          const UiUpdateSection(storeId: 'scanbox', checkForUpdates: false),
          const SizedBox(height: 16),
          const UiDeveloperSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
