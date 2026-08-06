import '../models/search_site.dart';

class QueryGeneratorService {
  static const List<SearchSite> defaultSites = [
    SearchSite(key: 'allocine', name: 'Allociné', domain: 'allocine.fr'),
    SearchSite(key: 'senscritique', name: 'SensCritique', domain: 'senscritique.com'),
    SearchSite(key: 'rottentomatoes', name: 'Rotten Tomatoes', domain: 'rottentomatoes.com'),
    SearchSite(key: 'imdb', name: 'IMDb', domain: 'imdb.com'),
    SearchSite(key: 'metacritic', name: 'Metacritic', domain: 'metacritic.com'),
    SearchSite(key: 'letterboxd', name: 'Letterboxd', domain: 'letterboxd.com'),
    SearchSite(key: 'theguardian', name: 'The Guardian', domain: 'theguardian.com'),
    SearchSite(key: 'variety', name: 'Variety', domain: 'variety.com'),
    SearchSite(key: 'rogerebert', name: 'RogerEbert', domain: 'rogerebert.com'),
  ];

  static String buildQueryString({
    String? genre,
    String? title,
    String? keywords,
    required String domain,
  }) {
    final parts = <String>[];

    if (title != null && title.trim().isNotEmpty) {
      parts.add('"${title.trim()}"');
    }
    if (genre != null && genre.trim().isNotEmpty) {
      parts.add(genre.trim());
    }
    if (keywords != null && keywords.trim().isNotEmpty) {
      parts.add(keywords.trim());
    }
    parts.add('(critique OR review)');
    parts.add('site:$domain');

    return parts.join(' ');
  }

  static String generateSearchUrl(
    SearchSite site, {
    String? genre,
    String? title,
    String? keywords,
  }) {
    final query = buildQueryString(
      genre: genre,
      title: title,
      keywords: keywords,
      domain: site.domain,
    );
    final encoded = Uri.encodeComponent(query);
    return 'https://duckduckgo.com/?q=$encoded';
  }

  static String generateGoogleUrl(
    SearchSite site, {
    String? genre,
    String? title,
    String? keywords,
  }) {
    final query = buildQueryString(
      genre: genre,
      title: title,
      keywords: keywords,
      domain: site.domain,
    );
    final encoded = Uri.encodeComponent(query);
    return 'https://www.google.com/search?q=$encoded';
  }

  static String generateBingUrl(
    SearchSite site, {
    String? genre,
    String? title,
    String? keywords,
  }) {
    final query = buildQueryString(
      genre: genre,
      title: title,
      keywords: keywords,
      domain: site.domain,
    );
    final encoded = Uri.encodeComponent(query);
    return 'https://www.bing.com/search?q=$encoded';
  }
}
