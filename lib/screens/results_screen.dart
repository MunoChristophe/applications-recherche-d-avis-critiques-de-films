import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../models/saved_result.dart';
import '../providers/history_provider.dart';
import '../providers/search_state_provider.dart';
import '../services/query_generator.dart';
import '../widgets/nav_bar_widget.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url, String l10nError) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10nError)),
        );
      }
    }
  }

  void _saveResult(BuildContext context, String siteKey, String siteName, String url, String query, String savedMsg) {
    final result = SavedResult(
      id: const Uuid().v4(),
      siteKey: siteKey,
      siteName: siteName,
      url: url,
      query: query,
      savedAt: DateTime.now(),
    );
    context.read<HistoryProvider>().addResult(result);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(savedMsg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final searchState = context.watch<SearchStateProvider>();
    final query = searchState.lastQuery;
    final sites = searchState.selectedSites;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resultsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: const [NavBarWidget()],
      ),
      body: query == null || sites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_filter, size: 64, color: theme.colorScheme.primary.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text(l10n.noResults,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: sites.length,
              itemBuilder: (context, index) {
                final site = sites[index];
                final url = QueryGeneratorService.generateSearchUrl(
                  site,
                  genre: query.genre,
                  title: query.title,
                  keywords: query.keywords,
                );
                final queryStr = QueryGeneratorService.buildQueryString(
                  genre: query.genre,
                  title: query.title,
                  keywords: query.keywords,
                  domain: site.domain,
                );

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.language, color: theme.colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(site.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary)),
                            const SizedBox(width: 8),
                            Text('(${site.domain})',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${l10n.generatedQuery}:',
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(queryStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.bookmark_add, color: theme.colorScheme.secondary),
                              tooltip: l10n.saveButton,
                              onPressed: () => _saveResult(
                                  context, site.key, site.name, url, queryStr, l10n.linkSaved),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _openUrl(context, url, l10n.cannotOpenUrl),
                              icon: const Icon(Icons.open_in_new, size: 18),
                              label: Text(l10n.openButton),
                              style: ElevatedButton.styleFrom(
                                elevation: 3,
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
