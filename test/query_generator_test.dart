import 'package:flutter_test/flutter_test.dart';
import 'package:cine_avis/services/query_generator.dart';
import 'package:cine_avis/models/search_site.dart';

void main() {
  const testSite = SearchSite(
    key: 'imdb',
    name: 'IMDb',
    domain: 'imdb.com',
  );

  const allocineSite = SearchSite(
    key: 'allocine',
    name: 'Allociné',
    domain: 'allocine.fr',
  );

  group('QueryGeneratorService', () {
    test('generateSearchUrl uses DuckDuckGo base URL', () {
      final url = QueryGeneratorService.generateSearchUrl(
        testSite,
        title: 'Inception',
      );
      expect(url, startsWith('https://duckduckgo.com/?q='));
    });

    test('generateSearchUrl contains site domain', () {
      final url = QueryGeneratorService.generateSearchUrl(
        testSite,
        title: 'Inception',
      );
      expect(url, contains('imdb.com'));
    });

    test('generateSearchUrl encodes title with quotes', () {
      final url = QueryGeneratorService.generateSearchUrl(
        testSite,
        title: 'The Dark Knight',
      );
      expect(url, contains(Uri.encodeComponent('"The Dark Knight"')));
    });

    test('buildQueryString includes critique OR review', () {
      final query = QueryGeneratorService.buildQueryString(
        title: 'Inception',
        domain: 'imdb.com',
      );
      expect(query, contains('critique OR review'));
    });

    test('buildQueryString with empty fields has no double spaces', () {
      final query = QueryGeneratorService.buildQueryString(
        domain: 'allocine.fr',
      );
      expect(query.contains('  '), isFalse);
    });

    test('buildQueryString includes genre when provided', () {
      final query = QueryGeneratorService.buildQueryString(
        genre: 'Action',
        domain: 'imdb.com',
      );
      expect(query, contains('Action'));
    });

    test('buildQueryString includes keywords when provided', () {
      final query = QueryGeneratorService.buildQueryString(
        keywords: 'Nolan',
        domain: 'imdb.com',
      );
      expect(query, contains('Nolan'));
    });

    test('generateSearchUrl with all fields contains all parts', () {
      final url = QueryGeneratorService.generateSearchUrl(
        allocineSite,
        genre: 'Drame',
        title: 'Amélie',
        keywords: 'Jeunet',
      );
      expect(url, contains('allocine.fr'));
      expect(url, contains(Uri.encodeComponent('"Amélie"')));
      expect(url, contains(Uri.encodeComponent('Drame')));
      expect(url, contains(Uri.encodeComponent('Jeunet')));
    });

    test('generateGoogleUrl uses Google base URL', () {
      final url = QueryGeneratorService.generateGoogleUrl(
        testSite,
        title: 'Inception',
      );
      expect(url, startsWith('https://www.google.com/search?q='));
    });

    test('defaultSites contains 9 sites', () {
      expect(QueryGeneratorService.defaultSites.length, equals(9));
    });

    test('defaultSites contains allocine', () {
      final keys = QueryGeneratorService.defaultSites.map((s) => s.key).toList();
      expect(keys, contains('allocine'));
    });
  });
}
