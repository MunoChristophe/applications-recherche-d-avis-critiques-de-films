import 'package:flutter_test/flutter_test.dart';
import 'package:cineavis/models/tmdb_genre.dart';
import 'package:cineavis/models/tmdb_movie.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // TmdbGenre
  // ─────────────────────────────────────────────────────────────────────────

  group('TmdbGenre', () {
    test('fromJson maps id and name correctly', () {
      final json = {'id': 28, 'name': 'Action'};
      final genre = TmdbGenre.fromJson(json);

      expect(genre.id, equals(28));
      expect(genre.name, equals('Action'));
    });

    test('TmdbGenreListResult.fromJson parses a list of genres', () {
      final json = {
        'genres': [
          {'id': 28, 'name': 'Action'},
          {'id': 12, 'name': 'Adventure'},
          {'id': 16, 'name': 'Animation'},
        ]
      };

      final result = TmdbGenreListResult.fromJson(json);

      expect(result.genres, hasLength(3));
      expect(result.genres[0].id, equals(28));
      expect(result.genres[1].name, equals('Adventure'));
    });

    test('TmdbGenreListResult.fromJson falls back to kFallbackGenres when genres key is missing', () {
      final result = TmdbGenreListResult.fromJson({});
      expect(result.genres, equals(kFallbackGenres));
      expect(result.genres, isNotEmpty);
    });

    test('TmdbGenre equality is based on id', () {
      const g1 = TmdbGenre(id: 28, name: 'Action');
      const g2 = TmdbGenre(id: 28, name: 'Action (duplicate name)');
      const g3 = TmdbGenre(id: 12, name: 'Adventure');

      expect(g1, equals(g2));
      expect(g1, isNot(equals(g3)));
    });

    test('kFallbackGenres contains at least 10 genres', () {
      expect(kFallbackGenres.length, greaterThanOrEqualTo(10));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TmdbMovie
  // ─────────────────────────────────────────────────────────────────────────

  group('TmdbMovie', () {
    test('fromJson maps all fields correctly', () {
      final json = {
        'id': 157336,
        'title': 'Interstellar',
        'original_title': 'Interstellar',
        'overview': 'A team of explorers travel through a wormhole.',
        'poster_path': '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
        'backdrop_path': '/some_backdrop.jpg',
        'release_date': '2014-11-07',
        'vote_average': 8.6,
        'genre_ids': [12, 18, 878],
      };

      final movie = TmdbMovie.fromJson(json);

      expect(movie.id, equals(157336));
      expect(movie.title, equals('Interstellar'));
      expect(movie.overview, contains('wormhole'));
      expect(movie.posterPath, equals('/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg'));
      expect(movie.releaseDate, equals('2014-11-07'));
      expect(movie.voteAverage, equals(8.6));
      expect(movie.genreIds, containsAll([12, 18, 878]));
    });

    test('posterUrl constructs the full URL correctly', () {
      const movie = TmdbMovie(
        id: 1,
        title: 'Test',
        originalTitle: 'Test',
        posterPath: '/abc123.jpg',
      );

      const imageBase = 'https://image.tmdb.org/t/p/w500';
      expect(movie.posterUrl(imageBase), equals('https://image.tmdb.org/t/p/w500/abc123.jpg'));
    });

    test('posterUrl returns null when posterPath is null', () {
      const movie = TmdbMovie(
        id: 1,
        title: 'No Poster',
        originalTitle: 'No Poster',
      );

      expect(movie.posterUrl('https://image.tmdb.org/t/p/w500'), isNull);
    });

    test('year extracts 4-digit year from releaseDate', () {
      const movie = TmdbMovie(
        id: 1,
        title: 'Test',
        originalTitle: 'Test',
        releaseDate: '2023-07-21',
      );
      expect(movie.year, equals('2023'));
    });

    test('year is null when releaseDate is null or too short', () {
      const movieNull = TmdbMovie(id: 1, title: 'T', originalTitle: 'T');
      const movieShort = TmdbMovie(
          id: 2, title: 'T', originalTitle: 'T', releaseDate: '202');
      expect(movieNull.year, isNull);
      expect(movieShort.year, isNull);
    });

    test('TmdbSearchResult.fromJson parses results list', () {
      final json = {
        'page': 1,
        'total_results': 2,
        'total_pages': 1,
        'results': [
          {
            'id': 1,
            'title': 'Movie A',
            'original_title': 'Movie A',
            'genre_ids': [],
          },
          {
            'id': 2,
            'title': 'Movie B',
            'original_title': 'Movie B',
            'genre_ids': [28],
          },
        ],
      };

      final result = TmdbSearchResult.fromJson(json);

      expect(result.page, equals(1));
      expect(result.totalResults, equals(2));
      expect(result.results, hasLength(2));
      expect(result.results[0].title, equals('Movie A'));
      expect(result.results[1].genreIds, contains(28));
    });

    test('movie equality is based on id', () {
      const m1 = TmdbMovie(id: 100, title: 'A', originalTitle: 'A');
      const m2 = TmdbMovie(id: 100, title: 'B', originalTitle: 'B');
      const m3 = TmdbMovie(id: 101, title: 'A', originalTitle: 'A');

      expect(m1, equals(m2));
      expect(m1, isNot(equals(m3)));
    });
  });
}
