import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_app/core/screens/main_screen.dart';
import 'package:gather_app/core/services/preferences_service.dart';
import 'package:gather_app/core/services/settings_provider.dart';
import 'package:gather_app/l10n/generated/l10n.dart';

void main() async {
  // Load SharedPreferences before the app starts
  await PreferencesService.instance.init();
  final prefs = PreferencesService.instance.prefs;
  final bool? isOnboardingDone = prefs.getBool('onboarding_done');

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: GatherApp(isOnboardingDone: isOnboardingDone ?? false),
    ),
  );
}

class GatherApp extends ConsumerWidget {
  const GatherApp({super.key, required this.isOnboardingDone});

  final bool isOnboardingDone;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final currentTheme = ref.watch(themeModeProvider);
    final currentColor = ref.watch(appColorProvider);

    return MaterialApp(
      title: 'Gather App',
      debugShowCheckedModeBanner: false,

      // Theme Setup
      themeMode: currentTheme,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: currentColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: currentColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // Localization Setup
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('he'), // Hebrew
      ],

      // Startup Screen
      home: const MainScreen(),
    );
  }
}
