import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../theme.dart';

/// Écran des paramètres (thème + langue).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _labels = {
    'fr': {
      'title': 'Paramètres',
      'appearance': 'Apparence',
      'darkMode': 'Thème sombre',
      'language': 'Langue',
      'french': 'Français',
      'english': 'English',
      'about': 'À propos',
      'aboutText':
          'CineAvis — Moteur de recherche d\'avis et critiques de films.\n'
              'Données fournies par TMDB (The Movie Database).\n'
              'Les résultats s\'ouvrent dans votre navigateur.',
    },
    'en': {
      'title': 'Settings',
      'appearance': 'Appearance',
      'darkMode': 'Dark mode',
      'language': 'Language',
      'french': 'Français',
      'english': 'English',
      'about': 'About',
      'aboutText':
          'CineAvis — Movie reviews search engine.\n'
              'Data provided by TMDB (The Movie Database).\n'
              'Results open in your browser.',
    },
  };

  String _label(String key, BuildContext context) {
    final locale = context.read<SettingsProvider>().locale.languageCode;
    return _labels[locale]?[key] ?? _labels['fr']![key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_label('title', context)),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Apparence ─────────────────────────────────────────────────
              Text(
                _label('appearance', context),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              Card(
                child: SwitchListTile(
                  secondary: Icon(
                    settings.themeMode == ThemeMode.dark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(_label('darkMode', context)),
                  value: settings.themeMode == ThemeMode.dark,
                  activeColor: AppColors.primary,
                  onChanged: (_) => settings.toggleTheme(),
                ),
              ),

              const SizedBox(height: 20),

              // ── Langue ────────────────────────────────────────────────────
              Text(
                _label('language', context),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              Card(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Text('🇫🇷  ${_label('french', context)}'),
                      value: 'fr',
                      groupValue: settings.locale.languageCode,
                      activeColor: AppColors.primary,
                      onChanged: (_) =>
                          settings.setLocale(const Locale('fr')),
                    ),
                    RadioListTile<String>(
                      title: Text('🇬🇧  ${_label('english', context)}'),
                      value: 'en',
                      groupValue: settings.locale.languageCode,
                      activeColor: AppColors.primary,
                      onChanged: (_) =>
                          settings.setLocale(const Locale('en')),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── À propos ──────────────────────────────────────────────────
              Text(
                _label('about', context),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _label('aboutText', context),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
