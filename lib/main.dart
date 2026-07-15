import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This channel name shows up in Android's notification settings, so it
  // needs to be localized too — but this runs before any widget/context
  // exists, so we read the device locale directly instead of going
  // through AppLocalizations.of(context).
  final deviceLanguage = ui.PlatformDispatcher.instance.locale.languageCode;
  final channelName = deviceLanguage == 'pt' ? 'Reprodução de Áudio' : 'Audio Playback';

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.jwstreamauto.channel.audio',
    androidNotificationChannelName: channelName,
    androidNotificationOngoing: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    // Loads the persisted light/dark preference; themeMode starts at
    // ThemeMode.system until this resolves, so there's no flash of the
    // wrong theme worth blocking startup for.
    _themeService.load();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeService.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          // Falls back to English for any locale we don't ship a translation
          // for (e.g. es, fr) instead of crashing or silently using the
          // default locale.
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return const Locale('en');
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) {
                return supported;
              }
            }
            return const Locale('en');
          },
          themeMode: mode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: HomeScreen(themeService: _themeService),
        );
      },
    );
  }
}
