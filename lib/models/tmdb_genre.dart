/// Représente un genre de film provenant de l'API TMDB.
class TmdbGenre {
  final int id;
  final String name;

  const TmdbGenre({required this.id, required this.name});

  factory TmdbGenre.fromJson(Map<String, dynamic> json) {
    return TmdbGenre(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TmdbGenre && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Liste statique de genres utilisée comme fallback si l'API est indisponible.
const List<TmdbGenre> kFallbackGenres = [
  TmdbGenre(id: 28, name: 'Action'),
  TmdbGenre(id: 12, name: 'Aventure'),
  TmdbGenre(id: 16, name: 'Animation'),
  TmdbGenre(id: 35, name: 'Comédie'),
  TmdbGenre(id: 80, name: 'Crime'),
  TmdbGenre(id: 99, name: 'Documentaire'),
  TmdbGenre(id: 18, name: 'Drame'),
  TmdbGenre(id: 10751, name: 'Famille'),
  TmdbGenre(id: 14, name: 'Fantastique'),
  TmdbGenre(id: 36, name: 'Histoire'),
  TmdbGenre(id: 27, name: 'Horreur'),
  TmdbGenre(id: 10402, name: 'Musique'),
  TmdbGenre(id: 9648, name: 'Mystère'),
  TmdbGenre(id: 10749, name: 'Romance'),
  TmdbGenre(id: 878, name: 'Science-fiction'),
  TmdbGenre(id: 10770, name: 'Téléfilm'),
  TmdbGenre(id: 53, name: 'Thriller'),
  TmdbGenre(id: 10752, name: 'Guerre'),
  TmdbGenre(id: 37, name: 'Western'),
];
