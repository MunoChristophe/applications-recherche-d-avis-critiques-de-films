import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/search_query.dart';
import '../providers/history_provider.dart';
import '../providers/search_state_provider.dart';
import '../services/query_generator.dart';
import '../widgets/nav_bar_widget.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatDate(DateTime dt) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  void _rerunQuery(BuildContext context, SearchQuery query) {
    final selectedSites = QueryGeneratorService.defaultSites
        .where((s) => query.siteKeys.contains(s.key))
        .toList();
    context.read<SearchStateProvider>().setSearch(query, selectedSites);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recherche relancée / Search re-run')),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir l\'URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.historyTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: theme.colorScheme.primaryContainer,
          actions: const [NavBarWidget()],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.searches),
              Tab(text: l10n.savedResults),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SearchesTab(
              onRerun: (q) => _rerunQuery(context, q),
              formatDate: _formatDate,
            ),
            _SavedTab(
              onOpen: (url) => _openUrl(context, url),
              formatDate: _formatDate,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchesTab extends StatelessWidget {
  final void Function(SearchQuery) onRerun;
  final String Function(DateTime) formatDate;

  const _SearchesTab({required this.onRerun, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final history = context.watch<HistoryProvider>();
    final queries = history.queries;

    if (queries.isEmpty) {
      return Center(
        child: Text(l10n.noHistory, style: theme.textTheme.titleMedium),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: queries.length,
      itemBuilder: (context, index) {
        final q = queries[index];
        final parts = <String>[];
        if (q.title != null && q.title!.isNotEmpty) parts.add(q.title!);
        if (q.genre != null && q.genre!.isNotEmpty) parts.add(q.genre!);
        if (q.keywords != null && q.keywords!.isNotEmpty) parts.add(q.keywords!);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.history, color: theme.colorScheme.primary),
            title: Text(
              parts.isEmpty ? '(vide)' : parts.join(' • '),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${q.siteKeys.length} sites • ${formatDate(q.createdAt)}',
              style: theme.textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.replay, color: theme.colorScheme.secondary),
                  tooltip: l10n.rerunButton,
                  onPressed: () => onRerun(q),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: l10n.deleteButton,
                  onPressed: () => context.read<HistoryProvider>().deleteQuery(q.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SavedTab extends StatelessWidget {
  final void Function(String) onOpen;
  final String Function(DateTime) formatDate;

  const _SavedTab({required this.onOpen, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final history = context.watch<HistoryProvider>();
    final results = history.results;

    if (results.isEmpty) {
      return Center(
        child: Text(l10n.noSaved, style: theme.textTheme.titleMedium),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final r = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.bookmark, color: theme.colorScheme.secondary),
            title: Text(r.siteName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.query,
                    style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('${l10n.savedOn} ${formatDate(r.savedAt)}',
                    style: theme.textTheme.bodySmall),
              ],
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.open_in_new, color: theme.colorScheme.primary),
                  tooltip: l10n.openButton,
                  onPressed: () => onOpen(r.url),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: l10n.deleteButton,
                  onPressed: () => context.read<HistoryProvider>().deleteResult(r.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
