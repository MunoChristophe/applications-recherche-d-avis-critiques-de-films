import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/search_query.dart';
import 'models/saved_result.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/history_provider.dart';
import 'providers/search_state_provider.dart';
import 'screens/main_shell.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CineAvisApp extends StatelessWidget {
  const CineAvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(
            queryBox: Hive.box<SearchQuery>('search_queries'),
            resultBox: Hive.box<SavedResult>('saved_results'),
          ),
        ),
        ChangeNotifierProvider(create: (_) => SearchStateProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return MaterialApp(
            title: 'CineAvis',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorSchemeSeed: Colors.deepOrange,
              brightness: Brightness.light,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorSchemeSeed: Colors.deepOrange,
              brightness: Brightness.dark,
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('fr'),
              Locale('en'),
            ],
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
