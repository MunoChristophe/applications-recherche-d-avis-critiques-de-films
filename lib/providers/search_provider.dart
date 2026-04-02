import 'package:flutter/material.dart';

import '../models/tmdb_genre.dart';
import '../models/tmdb_movie.dart';
import '../models/search_query.dart';
import '../services/tmdb_client.dart';
import '../services/history_service.dart';

/// État de la recherche en cours.
class SearchProvider extends ChangeNotifier {
  final TmdbClient _tmdb;
  final HistoryService _history;

  // Genres
  List<TmdbGenre> _genres = kFallbackGenres;
  bool _genresLoading = false;

  // Sélections en cours
  TmdbGenre? _selectedGenre;
  TmdbMovie? _selectedMovie;
  String _keyword = '';

  // Suggestions titre
  List<TmdbMovie> _suggestions = [];
  bool _suggestionsLoading = false;

  // Résultats / navigation
  SearchQuery? _lastQuery;
  final List<SearchQuery> _navStack = [];
  int _navIndex = -1;

  SearchProvider({required TmdbClient tmdb, required HistoryService history})
      : _tmdb = tmdb,
        _history = history;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------
  List<TmdbGenre> get genres => _genres;
  bool get genresLoading => _genresLoading;
  TmdbGenre? get selectedGenre => _selectedGenre;
  TmdbMovie? get selectedMovie => _selectedMovie;
  String get keyword => _keyword;
  List<TmdbMovie> get suggestions => _suggestions;
  bool get suggestionsLoading => _suggestionsLoading;
  SearchQuery? get lastQuery => _lastQuery;
  bool get canGoBack => _navIndex > 0;
  bool get canGoForward => _navIndex < _navStack.length - 1;

  /// Langue TMDB courante (défaut fr-FR).
  String _tmdbLanguage = 'fr-FR';
  set tmdbLanguage(String lang) => _tmdbLanguage = lang;

  // ---------------------------------------------------------------------------
  // Genres
  // ---------------------------------------------------------------------------

  Future<void> loadGenres() async {
    _genresLoading = true;
    notifyListeners();
    _genres = await _tmdb.fetchGenres(language: _tmdbLanguage);
    _genresLoading = false;
    notifyListeners();
  }

  void selectGenre(TmdbGenre? genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Titre / suggestions
  // ---------------------------------------------------------------------------

  Future<void> fetchSuggestions(String query) async {
    if (query.trim().length < 2) {
      _suggestions = [];
      notifyListeners();
      return;
    }
    _suggestionsLoading = true;
    notifyListeners();
    _suggestions = await _tmdb.searchMovies(
      query,
      language: _tmdbLanguage,
      genreId: _selectedGenre?.id,
    );
    _suggestionsLoading = false;
    notifyListeners();
  }

  void selectMovie(TmdbMovie movie) {
    _selectedMovie = movie;
    _suggestions = [];
    notifyListeners();
  }

  void setKeyword(String value) {
    _keyword = value;
    notifyListeners();
  }

  void clearMovieSelection() {
    _selectedMovie = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Recherche
  // ---------------------------------------------------------------------------

  /// Lance la recherche et enregistre dans l'historique.
  Future<SearchQuery> search() async {
    final query = _selectedMovie != null
        ? SearchQuery.fromMovie(
            movie: _selectedMovie!,
            keyword: _keyword.isEmpty ? null : _keyword,
            genreName: _selectedGenre?.name,
            genreId: _selectedGenre?.id,
          )
        : SearchQuery.fromKeyword(
            keyword: _keyword,
            genreName: _selectedGenre?.name,
            genreId: _selectedGenre?.id,
          );

    _lastQuery = query;

    // Navigation stack
    if (_navIndex < _navStack.length - 1) {
      _navStack.removeRange(_navIndex + 1, _navStack.length);
    }
    _navStack.add(query);
    _navIndex = _navStack.length - 1;

    await _history.add(query);
    notifyListeners();
    return query;
  }

  // ---------------------------------------------------------------------------
  // Navigation avant / arrière
  // ---------------------------------------------------------------------------

  SearchQuery? goBack() {
    if (!canGoBack) return null;
    _navIndex--;
    _lastQuery = _navStack[_navIndex];
    notifyListeners();
    return _lastQuery;
  }

  SearchQuery? goForward() {
    if (!canGoForward) return null;
    _navIndex++;
    _lastQuery = _navStack[_navIndex];
    notifyListeners();
    return _lastQuery;
  }

  // ---------------------------------------------------------------------------
  // Historique
  // ---------------------------------------------------------------------------

  List<SearchQuery> get history => _history.getAll();

  Future<void> removeFromHistory(String id) async {
    await _history.remove(id);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _history.clear();
    notifyListeners();
  }
}
