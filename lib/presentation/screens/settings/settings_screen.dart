import 'package:flutter/material.dart';
import 'package:snappdf/core/constants/app_constants.dart';
import 'package:theme/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Offline document scanner & PDF creator'),
            subtitle: Text(AppConstants.appName),
          ),
          const SizedBox(height: 16),
          const UiAppearanceSection(),
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
