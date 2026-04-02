import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/search_provider.dart';
import '../providers/settings_provider.dart';
import '../models/search_query.dart';
import 'results_screen.dart';

/// Écran de l'historique des recherches.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const _labels = {
    'fr': {
      'title': 'Historique',
      'empty': 'Aucun historique de recherche.',
      'clear': 'Tout effacer',
      'clearConfirm': 'Vider l\'historique ?',
      'yes': 'Oui',
      'no': 'Non',
      'relaunch': 'Relancer',
      'delete': 'Supprimer',
    },
    'en': {
      'title': 'History',
      'empty': 'No search history.',
      'clear': 'Clear all',
      'clearConfirm': 'Clear history?',
      'yes': 'Yes',
      'no': 'No',
      'relaunch': 'Relaunch',
      'delete': 'Delete',
    },
  };

  String _label(String key, BuildContext context) {
    final locale = context.read<SettingsProvider>().locale.languageCode;
    return _labels[locale]?[key] ?? _labels['fr']![key]!;
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_label('clearConfirm', context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_label('no', context)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_label('yes', context)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<SearchProvider>().clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_label('title', context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: _label('clear', context),
            onPressed: () => _confirmClear(context),
          ),
        ],
      ),
      body: Consumer<SearchProvider>(
        builder: (context, sp, _) {
          final history = sp.history;
          if (history.isEmpty) {
            return Center(
              child: Text(
                _label('empty', context),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: history.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final item = history[i];
              return ListTile(
                leading: item.posterPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w92${item.posterPath}',
                          width: 36,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.movie),
                        ),
                      )
                    : const Icon(Icons.history_rounded),
                title: Text(item.summary),
                subtitle: Text(
                  _formatDate(item.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Relancer
                    IconButton(
                      icon: const Icon(Icons.play_arrow_rounded),
                      tooltip: _label('relaunch', context),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultsScreen(query: item),
                          ),
                        );
                      },
                    ),
                    // Supprimer
                    IconButton(
                      icon: const Icon(Icons.delete_rounded),
                      tooltip: _label('delete', context),
                      onPressed: () => sp.removeFromHistory(item.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
