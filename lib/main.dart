import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'providers/search_provider.dart';
import 'services/tmdb_client.dart';
import 'services/history_service.dart';
import 'screens/search_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger le fichier .env (silencieux si absent ou non configuré)
  await dotenv.load(fileName: '.env', mergeWith: <String, String>{}).catchError((_) {});

  // Hive (stockage local)
  await Hive.initFlutter();

  // Initialiser les services
  final historyService = HistoryService();
  await historyService.init();

  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  final tmdbClient = TmdbClient();
  final searchProvider = SearchProvider(
    tmdb: tmdbClient,
    history: historyService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: searchProvider),
      ],
      child: const CineAvisApp(),
    ),
  );
}

class CineAvisApp extends StatelessWidget {
  const CineAvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        // Synchroniser la langue TMDB avec la locale
        final tmdbLang =
            settings.locale.languageCode == 'fr' ? 'fr-FR' : 'en-US';
        context.read<SearchProvider>().tmdbLanguage = tmdbLang;

        return MaterialApp(
          title: 'CineAvis',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: const [Locale('fr'), Locale('en')],
          home: const SearchScreen(),
        );
      },
    );
  }
}
