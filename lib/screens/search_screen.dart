import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tmdb_genre.dart';
import '../models/tmdb_movie.dart';
import '../models/search_query.dart';
import '../providers/search_provider.dart';
import '../providers/settings_provider.dart';
import '../theme.dart';
import 'results_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

/// Écran principal de recherche.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _titleController = TextEditingController();
  final _keywordController = TextEditingController();
  final _titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().loadGenres();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _keywordController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _onTitleChanged(String value) {
    context.read<SearchProvider>()
      ..clearMovieSelection()
      ..fetchSuggestions(value);
  }

  void _selectMovie(TmdbMovie movie) {
    context.read<SearchProvider>().selectMovie(movie);
    _titleController.text = movie.title;
    _titleFocusNode.unfocus();
  }

  Future<void> _search() async {
    final sp = context.read<SearchProvider>();
    if (sp.selectedMovie == null && _keywordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_label('searchEmpty')),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    sp.setKeyword(_keywordController.text.trim());
    final query = await sp.search();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultsScreen(query: query)),
    );
  }

  String _label(String key) {
    final locale = context.read<SettingsProvider>().locale.languageCode;
    return _labels[locale]?[key] ?? _labels['fr']![key]!;
  }

  static const _labels = {
    'fr': {
      'appTitle': 'CineAvis',
      'genre': 'Catégorie / Genre',
      'allGenres': 'Tous les genres',
      'title': 'Titre du film',
      'titleHint': 'Tapez un titre pour des suggestions…',
      'keywords': 'Mots-clés',
      'keywordsHint': 'Ex: espace, robot, amour…',
      'search': 'Rechercher',
      'searchEmpty': 'Entrez un titre ou des mots-clés.',
      'history': 'Historique',
      'settings': 'Paramètres',
    },
    'en': {
      'appTitle': 'CineAvis',
      'genre': 'Category / Genre',
      'allGenres': 'All genres',
      'title': 'Movie title',
      'titleHint': 'Type a title for suggestions…',
      'keywords': 'Keywords',
      'keywordsHint': 'E.g. space, robot, love…',
      'search': 'Search',
      'searchEmpty': 'Enter a title or keywords.',
      'history': 'History',
      'settings': 'Settings',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.movie_filter_rounded, size: 28),
            const SizedBox(width: 8),
            Text(
              _label('appTitle'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          // Navigation arrière
          Consumer<SearchProvider>(
            builder: (_, sp, __) => IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              tooltip: 'Précédent',
              onPressed: sp.canGoBack
                  ? () {
                      final q = sp.goBack();
                      if (q != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ResultsScreen(query: q)),
                        );
                      }
                    }
                  : null,
            ),
          ),
          // Navigation avant
          Consumer<SearchProvider>(
            builder: (_, sp, __) => IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              tooltip: 'Suivant',
              onPressed: sp.canGoForward
                  ? () {
                      final q = sp.goForward();
                      if (q != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ResultsScreen(query: q)),
                        );
                      }
                    }
                  : null,
            ),
          ),
          // Historique
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: _label('history'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          // Paramètres
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: _label('settings'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _GenreDropdown(labelText: _label('genre'), allGenresLabel: _label('allGenres')),
              const SizedBox(height: 16),
              _TitleSearchField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                labelText: _label('title'),
                hintText: _label('titleHint'),
                onChanged: _onTitleChanged,
                onMovieSelected: _selectMovie,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _keywordController,
                decoration: InputDecoration(
                  labelText: _label('keywords'),
                  hintText: _label('keywordsHint'),
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.search_rounded, size: 22),
                label: Text(
                  _label('search'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dropdown genre
// ---------------------------------------------------------------------------

class _GenreDropdown extends StatelessWidget {
  final String labelText;
  final String allGenresLabel;

  const _GenreDropdown({
    required this.labelText,
    required this.allGenresLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, sp, _) {
        if (sp.genresLoading) {
          return const LinearProgressIndicator();
        }
        return DropdownButtonFormField<TmdbGenre?>(
          value: sp.selectedGenre,
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: const Icon(Icons.category_rounded),
          ),
          items: [
            DropdownMenuItem<TmdbGenre?>(
              value: null,
              child: Text(allGenresLabel),
            ),
            ...sp.genres.map((g) => DropdownMenuItem<TmdbGenre?>(
                  value: g,
                  child: Text(g.name),
                )),
          ],
          onChanged: (g) => sp.selectGenre(g),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Champ titre avec suggestions (autocomplete TMDB)
// ---------------------------------------------------------------------------

class _TitleSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<TmdbMovie> onMovieSelected;

  const _TitleSearchField({
    required this.controller,
    required this.focusNode,
    required this.labelText,
    required this.hintText,
    required this.onChanged,
    required this.onMovieSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, sp, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Champ de saisie
            TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
                prefixIcon: const Icon(Icons.movie_rounded),
                suffixIcon: sp.suggestionsLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : (controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              controller.clear();
                              sp.clearMovieSelection();
                              sp.fetchSuggestions('');
                            },
                          )
                        : null),
              ),
              onChanged: onChanged,
            ),

            // Liste de suggestions
            if (sp.suggestions.isNotEmpty && sp.selectedMovie == null)
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sp.suggestions.length > 8 ? 8 : sp.suggestions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final movie = sp.suggestions[i];
                    return ListTile(
                      dense: true,
                      leading: movie.posterPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                                width: 36,
                                height: 54,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.movie),
                              ),
                            )
                          : const Icon(Icons.movie),
                      title: Text(movie.title),
                      subtitle: movie.year != null ? Text(movie.year!) : null,
                      onTap: () => onMovieSelected(movie),
                    );
                  },
                ),
              ),

            // Film sélectionné
            if (sp.selectedMovie != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Chip(
                  avatar: const Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 18),
                  label: Text(
                    '${sp.selectedMovie!.title}${sp.selectedMovie!.year != null ? ' (${sp.selectedMovie!.year})' : ''}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  onDeleted: () {
                    controller.clear();
                    sp.clearMovieSelection();
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
