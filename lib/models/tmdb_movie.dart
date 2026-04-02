import 'tmdb_genre.dart';

/// Représente un film provenant de l'API TMDB.
class TmdbMovie {
  final int id;
  final String title;
  final String originalTitle;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double? voteAverage;
  final List<int> genreIds;

  const TmdbMovie({
    required this.id,
    required this.title,
    required this.originalTitle,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage,
    this.genreIds = const [],
  });

  factory TmdbMovie.fromJson(Map<String, dynamic> json) {
    return TmdbMovie(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? (json['original_title'] as String? ?? ''),
      originalTitle: (json['original_title'] as String?) ?? '',
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'original_title': originalTitle,
        'overview': overview,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'release_date': releaseDate,
        'vote_average': voteAverage,
        'genre_ids': genreIds,
      };

  /// Construit l'URL complète du poster à partir du [imageBaseUrl] configuré.
  String? posterUrl(String imageBaseUrl) {
    if (posterPath == null || posterPath!.isEmpty) return null;
    return '$imageBaseUrl$posterPath';
  }

  /// Année de sortie extraite de [releaseDate].
  String? get year {
    if (releaseDate == null || releaseDate!.length < 4) return null;
    return releaseDate!.substring(0, 4);
  }

  @override
  String toString() => '$title${year != null ? ' ($year)' : ''}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TmdbMovie && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Résultat d'une recherche TMDB `/search/movie`.
class TmdbSearchResult {
  final int page;
  final int totalResults;
  final int totalPages;
  final List<TmdbMovie> results;

  const TmdbSearchResult({
    required this.page,
    required this.totalResults,
    required this.totalPages,
    required this.results,
  });

  factory TmdbSearchResult.fromJson(Map<String, dynamic> json) {
    return TmdbSearchResult(
      page: json['page'] as int? ?? 1,
      totalResults: json['total_results'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => TmdbMovie.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Résultat d'une liste de genres TMDB `/genre/movie/list`.
class TmdbGenreListResult {
  final List<TmdbGenre> genres;

  const TmdbGenreListResult({required this.genres});

  factory TmdbGenreListResult.fromJson(Map<String, dynamic> json) {
    return TmdbGenreListResult(
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => TmdbGenre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          kFallbackGenres,
    );
  }
}
