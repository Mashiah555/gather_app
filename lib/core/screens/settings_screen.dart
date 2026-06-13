import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_app/l10n/generated/l10n.dart';
import 'package:gather_app/core/services/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A handy variable to access translated strings
    final l10n = AppLocalizations.of(context);

    final currentTheme = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // Theme Selection
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(l10n.themeMode),
            trailing: DropdownButton<ThemeMode>(
              value: currentTheme,
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  ref.read(themeModeProvider.notifier).setTheme(newMode);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.light),
                ),
                DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.dark)),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.system),
                ),
              ],
            ),
          ),
          const Divider(),
          // Language Selection
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            trailing: DropdownButton<String>(
              value: currentLocale.languageCode,
              onChanged: (String? newLang) {
                if (newLang != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(newLang));
                }
              },
              items: [
                const DropdownMenuItem(value: 'he', child: Text('עברית')),
                const DropdownMenuItem(value: 'en', child: Text('English')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
