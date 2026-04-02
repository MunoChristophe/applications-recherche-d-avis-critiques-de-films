import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/tmdb_genre.dart';
import '../models/tmdb_movie.dart';

/// Client pour l'API The Movie Database (TMDB).
///
/// Lit les variables d'environnement depuis le fichier `.env` :
///   - `TMDB_API_KEY` : clé API TMDB (obligatoire)
///   - `TMDB_BASE_URL` : URL de base (défaut : https://api.themoviedb.org/3)
///   - `TMDB_IMAGE_BASE_URL` : URL images (défaut : https://image.tmdb.org/t/p/w500)
class TmdbClient {
  final http.Client _httpClient;

  TmdbClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  String get _apiKey => dotenv.maybeGet('TMDB_API_KEY') ?? '';

  String get baseUrl =>
      dotenv.maybeGet('TMDB_BASE_URL') ?? 'https://api.themoviedb.org/3';

  String get imageBaseUrl =>
      dotenv.maybeGet('TMDB_IMAGE_BASE_URL') ??
      'https://image.tmdb.org/t/p/w500';

  bool get isConfigured => _apiKey.isNotEmpty && _apiKey != 'your_tmdb_api_key_here';

  /// Construit l'URL complète du poster pour un [posterPath] TMDB.
  String posterUrl(String posterPath) => '$imageBaseUrl$posterPath';

  // ---------------------------------------------------------------------------
  // GET /genre/movie/list
  // ---------------------------------------------------------------------------

  /// Récupère la liste des genres de films depuis TMDB.
  ///
  /// Retourne [kFallbackGenres] si l'API est indisponible ou non configurée.
  Future<List<TmdbGenre>> fetchGenres({String language = 'fr-FR'}) async {
    if (!isConfigured) return kFallbackGenres;

    final uri = Uri.parse('$baseUrl/genre/movie/list').replace(
      queryParameters: {
        'api_key': _apiKey,
        'language': language,
      },
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return TmdbGenreListResult.fromJson(json).genres;
      }
    } catch (_) {
      // Réseau indisponible → fallback
    }
    return kFallbackGenres;
  }

  // ---------------------------------------------------------------------------
  // GET /search/movie
  // ---------------------------------------------------------------------------

  /// Recherche des films par [query] (titre).
  ///
  /// Utilisé pour l'auto-complétion du champ titre.
  /// Retourne une liste vide si l'API est indisponible ou non configurée.
  Future<List<TmdbMovie>> searchMovies(
    String query, {
    String language = 'fr-FR',
    int page = 1,
    int? year,
    int? genreId,
  }) async {
    if (!isConfigured || query.trim().isEmpty) return [];

    final params = <String, String>{
      'api_key': _apiKey,
      'query': query.trim(),
      'language': language,
      'page': page.toString(),
      'include_adult': 'false',
    };
    if (year != null) params['year'] = year.toString();

    final uri =
        Uri.parse('$baseUrl/search/movie').replace(queryParameters: params);

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return TmdbSearchResult.fromJson(json).results;
      }
    } catch (_) {
      // Réseau indisponible
    }
    return [];
  }

  // ---------------------------------------------------------------------------
  // GET /movie/{movie_id}
  // ---------------------------------------------------------------------------

  /// Récupère les détails d'un film par son [movieId].
  Future<TmdbMovie?> fetchMovieDetails(
    int movieId, {
    String language = 'fr-FR',
  }) async {
    if (!isConfigured) return null;

    final uri = Uri.parse('$baseUrl/movie/$movieId').replace(
      queryParameters: {
        'api_key': _apiKey,
        'language': language,
      },
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return TmdbMovie.fromJson(json);
      }
    } catch (_) {
      // Réseau indisponible
    }
    return null;
  }

  void dispose() {
    _httpClient.close();
  }
}
