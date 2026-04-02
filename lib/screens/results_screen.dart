import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/search_query.dart';
import '../providers/search_provider.dart';
import '../providers/settings_provider.dart';
import '../theme.dart';

/// Écran affichant le poster, les infos du film et les liens vers les critiques.
class ResultsScreen extends StatelessWidget {
  final SearchQuery query;

  const ResultsScreen({super.key, required this.query});

  static const _labels = {
    'fr': {
      'title': 'Résultats',
      'poster': 'Affiche',
      'reviewLinks': 'Critiques & avis',
      'openLink': 'Ouvrir',
      'noMovieSelected': 'Aucun film sélectionné.',
      'back': 'Précédent',
      'forward': 'Suivant',
      'noImage': 'Pas d\'affiche disponible',
      'reviewSitesTitle': 'Rechercher les critiques sur :',
      'openError': 'Impossible d\'ouvrir ce lien.',
    },
    'en': {
      'title': 'Results',
      'poster': 'Poster',
      'reviewLinks': 'Reviews & Critics',
      'openLink': 'Open',
      'noMovieSelected': 'No movie selected.',
      'back': 'Back',
      'forward': 'Forward',
      'noImage': 'No poster available',
      'reviewSitesTitle': 'Search reviews on:',
      'openError': 'Cannot open this link.',
    },
  };

  String _label(String key, BuildContext context) {
    final locale =
        context.read<SettingsProvider>().locale.languageCode;
    return _labels[locale]?[key] ?? _labels['fr']![key]!;
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_label('openError', context)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SearchProvider>();
    final searchTerm =
        query.movieTitle ?? query.keyword ?? query.genreName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(_label('title', context)),
        actions: [
          // Navigation arrière
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            tooltip: _label('back', context),
            onPressed: sp.canGoBack
                ? () {
                    final q = sp.goBack();
                    if (q != null && context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ResultsScreen(query: q)),
                      );
                    }
                  }
                : null,
          ),
          // Navigation avant
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            tooltip: _label('forward', context),
            onPressed: sp.canGoForward
                ? () {
                    final q = sp.goForward();
                    if (q != null && context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ResultsScreen(query: q)),
                      );
                    }
                  }
                : null,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Poster + infos film ──────────────────────────────────────────
          if (query.movieTitle != null || query.posterPath != null)
            _MovieCard(query: query),

          const SizedBox(height: 20),

          // ── Sites de critiques ───────────────────────────────────────────
          Text(
            _label('reviewSitesTitle', context),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ...kDefaultReviewSites.map(
            (site) => _ReviewLinkTile(
              site: site,
              searchTerm: searchTerm,
              openLabel: _label('openLink', context),
              onOpen: (url) => _openUrl(context, url),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget carte film (poster + infos)
// ---------------------------------------------------------------------------

class _MovieCard extends StatelessWidget {
  final SearchQuery query;

  const _MovieCard({required this.query});

  @override
  Widget build(BuildContext context) {
    final posterUrl = query.posterPath != null
        ? 'https://image.tmdb.org/t/p/w500${query.posterPath}'
        : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          SizedBox(
            width: 100,
            height: 150,
            child: posterUrl != null
                ? Image.network(
                    posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primary.withAlpha(30),
                      child: const Icon(Icons.movie, size: 48),
                    ),
                  )
                : Container(
                    color: AppColors.primary.withAlpha(30),
                    child: const Icon(Icons.movie, size: 48),
                  ),
          ),

          // Infos
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (query.movieTitle != null)
                    Text(
                      query.movieTitle!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  if (query.genreName != null) ...[
                    const SizedBox(height: 6),
                    Chip(
                      label: Text(query.genreName!),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                  if (query.keyword != null && query.keyword!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      query.keyword!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tuile lien critique
// ---------------------------------------------------------------------------

class _ReviewLinkTile extends StatelessWidget {
  final ReviewSite site;
  final String searchTerm;
  final ValueChanged<String> onOpen;
  final String openLabel;

  const _ReviewLinkTile({
    required this.site,
    required this.searchTerm,
    required this.onOpen,
    this.openLabel = 'Ouvrir',
  });

  @override
  Widget build(BuildContext context) {
    final url = site.searchUrl(searchTerm);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withAlpha(20),
          child: Text(
            site.flagEmoji ?? '🌍',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        title: Text(
          site.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          site.domain,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.searchBorder,
              ),
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => onOpen(url),
          icon: const Icon(Icons.open_in_browser_rounded, size: 16),
          label: Text(openLabel),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
