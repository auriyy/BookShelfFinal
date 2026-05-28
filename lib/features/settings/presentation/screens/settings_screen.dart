import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/local_storage/shared_prefs_service.dart';
import '../../../../core/providers/app_settings_providers.dart';
import 'package:bookshelf/core/localization/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    final currentThemeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    
    final localizations = AppLocalizations.of(context)!;
    
    final sharedPrefs = ref.read(sharedPrefsServiceProvider);
    final lastSearch = sharedPrefs.getLastSearchQuery();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.settings_title, 
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          Text(
            localizations.appearance_section, 
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(localizations.theme_light),
                  secondary: const Icon(Icons.wb_sunny_rounded, color: Colors.orange),
                  value: ThemeMode.light,
                  groupValue: currentThemeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      ref.read(themeModeProvider.notifier).changeTheme(value);
                    }
                  },
                ),
                const Divider(height: 1, indent: 56),
                RadioListTile<ThemeMode>(
                  title: Text(localizations.theme_dark),
                  secondary: const Icon(Icons.nightlight_round, color: Colors.blueGrey),
                  value: ThemeMode.dark,
                  groupValue: currentThemeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      ref.read(themeModeProvider.notifier).changeTheme(value);
                    }
                  },
                ),
                const Divider(height: 1, indent: 56),
                RadioListTile<ThemeMode>(
                  title: Text(localizations.theme_system),
                  secondary: const Icon(Icons.brightness_auto_rounded, color: Colors.blue),
                  value: ThemeMode.system,
                  groupValue: currentThemeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      ref.read(themeModeProvider.notifier).changeTheme(value);
                    }
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Text(
            localizations.language_section, 
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.language_rounded, color: Colors.teal),
              title: const Text('Language / Мова / Język'),
              trailing: DropdownButton<String>(
                value: currentLocale.languageCode,
                underline: const SizedBox(), 
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: const [
                  DropdownMenuItem(value: 'uk', child: Text('Українська 🇺🇦')),
                  DropdownMenuItem(value: 'en', child: Text('English 🇬🇧')),
                  DropdownMenuItem(value: 'pl', child: Text('Polski 🇵🇱')),
                ],
                onChanged: (String? newLangCode) {
                  if (newLangCode != null) {
                    ref.read(localeProvider.notifier).changeLanguage(newLangCode);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            localizations.search_data_section,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.history_rounded),
              title: Text(localizations.last_search_label), // ВИПРАВЛЕНО: Прибрали hardcode перевірку
              subtitle: Text(
                lastSearch.isNotEmpty ? '"$lastSearch"' : localizations.history_empty, // ВИПРАВЛЕНО
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              trailing: lastSearch.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () async {
                        await sharedPrefs.saveLastSearchQuery('');
                        
                        if (context.mounted) {
                          ref.invalidate(localeProvider); 
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(localizations.done),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}