import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/local_storage/shared_prefs_service.dart';
import 'core/providers/app_settings_providers.dart';
import 'core/theme/app_theme.dart';
import 'package:bookshelf/core/localization/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsServiceProvider.overrideWithValue(SharedPrefsService(sharedPreferences)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    final themeMode = ref.watch(themeModeProvider);
    
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'BookShelf App',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      locale: currentLocale,
      
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      
      routerConfig: router,
    );
  }
}