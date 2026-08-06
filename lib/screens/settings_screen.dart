import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../services/query_generator.dart';
import '../widgets/nav_bar_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: const [NavBarWidget()],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _SectionHeader(title: l10n.languageLabel),
          ListTile(
            leading: const Text('🌐', style: TextStyle(fontSize: 24)),
            title: Text(l10n.languageLabel),
            subtitle: Text(localeProvider.isFrench ? 'Français' : 'English'),
            trailing: Switch(
              value: !localeProvider.isFrench,
              onChanged: (_) => localeProvider.toggle(),
              activeColor: theme.colorScheme.primary,
            ),
            onTap: () => localeProvider.toggle(),
          ),
          const Divider(),
          _SectionHeader(title: l10n.themeLabel),
          ListTile(
            leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.primary),
            title: Text(l10n.themeLabel),
            subtitle: Text(isDark ? l10n.darkTheme : l10n.lightTheme),
            trailing: Switch(
              value: isDark,
              onChanged: (_) => themeProvider.toggle(),
              activeColor: theme.colorScheme.primary,
            ),
            onTap: () => themeProvider.toggle(),
          ),
          const Divider(),
          _SectionHeader(title: l10n.sitesLabel),
          ...QueryGeneratorService.defaultSites.map(
            (site) => ListTile(
              leading: Icon(Icons.language, color: theme.colorScheme.secondary),
              title: Text(site.name),
              subtitle: Text(site.domain),
              dense: true,
            ),
          ),
          const Divider(),
          _SectionHeader(title: l10n.about),
          ListTile(
            leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
            title: Text(l10n.appTitle),
            subtitle: Text(l10n.appVersion),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
