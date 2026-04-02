import 'tmdb_movie.dart';

/// Représente une requête de recherche (stockée dans l'historique).
class SearchQuery {
  final String id;
  final String? keyword;
  final String? genreName;
  final int? genreId;
  final String? movieTitle;
  final int? movieId;
  final String? posterPath;
  final DateTime createdAt;

  const SearchQuery({
    required this.id,
    this.keyword,
    this.genreName,
    this.genreId,
    this.movieTitle,
    this.movieId,
    this.posterPath,
    required this.createdAt,
  });

  factory SearchQuery.fromMovie({
    required TmdbMovie movie,
    String? keyword,
    String? genreName,
    int? genreId,
  }) {
    return SearchQuery(
      id: '${movie.id}_${DateTime.now().millisecondsSinceEpoch}',
      keyword: keyword,
      genreName: genreName,
      genreId: genreId,
      movieTitle: movie.title,
      movieId: movie.id,
      posterPath: movie.posterPath,
      createdAt: DateTime.now(),
    );
  }

  factory SearchQuery.fromKeyword({
    required String keyword,
    String? genreName,
    int? genreId,
  }) {
    return SearchQuery(
      id: 'kw_${DateTime.now().millisecondsSinceEpoch}',
      keyword: keyword,
      genreName: genreName,
      genreId: genreId,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'keyword': keyword,
        'genreName': genreName,
        'genreId': genreId,
        'movieTitle': movieTitle,
        'movieId': movieId,
        'posterPath': posterPath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SearchQuery.fromJson(Map<String, dynamic> json) {
    return SearchQuery(
      id: json['id'] as String,
      keyword: json['keyword'] as String?,
      genreName: json['genreName'] as String?,
      genreId: json['genreId'] as int?,
      movieTitle: json['movieTitle'] as String?,
      movieId: json['movieId'] as int?,
      posterPath: json['posterPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Résumé lisible de la recherche.
  String get summary {
    final parts = <String>[];
    if (movieTitle != null) parts.add(movieTitle!);
    if (genreName != null) parts.add(genreName!);
    if (keyword != null) parts.add(keyword!);
    return parts.join(' • ');
  }
}

/// Site de critique/avis de films.
class ReviewSite {
  final String name;
  final String domain;
  final String? flagEmoji;

  const ReviewSite({
    required this.name,
    required this.domain,
    this.flagEmoji,
  });

  /// Génère l'URL de recherche pour ce site.
  String searchUrl(String query) {
    final encoded = Uri.encodeComponent(query);
    return 'https://www.google.com/search?q=${encoded}+site:$domain';
  }

  /// URL directe sur DuckDuckGo pour plus de confidentialité.
  String duckDuckGoUrl(String query) {
    final encoded = Uri.encodeComponent('$query site:$domain');
    return 'https://duckduckgo.com/?q=$encoded';
  }
}

/// Liste des sites de critiques/avis par défaut.
const List<ReviewSite> kDefaultReviewSites = [
  ReviewSite(name: 'Allociné', domain: 'allocine.fr', flagEmoji: '🇫🇷'),
  ReviewSite(name: 'SensCritique', domain: 'senscritique.com', flagEmoji: '🇫🇷'),
  ReviewSite(name: 'Première', domain: 'premiere.fr', flagEmoji: '🇫🇷'),
  ReviewSite(name: 'Le Monde', domain: 'lemonde.fr', flagEmoji: '🇫🇷'),
  ReviewSite(name: 'Télérama', domain: 'telerama.fr', flagEmoji: '🇫🇷'),
  ReviewSite(name: 'Rotten Tomatoes', domain: 'rottentomatoes.com', flagEmoji: '🇺🇸'),
  ReviewSite(name: 'IMDb', domain: 'imdb.com', flagEmoji: '🇺🇸'),
  ReviewSite(name: 'Metacritic', domain: 'metacritic.com', flagEmoji: '🇺🇸'),
  ReviewSite(name: 'Letterboxd', domain: 'letterboxd.com', flagEmoji: '🌍'),
  ReviewSite(name: 'The Guardian', domain: 'theguardian.com', flagEmoji: '🇬🇧'),
  ReviewSite(name: 'Variety', domain: 'variety.com', flagEmoji: '🇺🇸'),
  ReviewSite(name: 'Roger Ebert', domain: 'rogerebert.com', flagEmoji: '🇺🇸'),
];
