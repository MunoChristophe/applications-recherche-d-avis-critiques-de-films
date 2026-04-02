import 'package:flutter/material.dart';
import '../models/search_query.dart';
import '../models/search_site.dart';

class SearchStateProvider extends ChangeNotifier {
  SearchQuery? _lastQuery;
  List<SearchSite> _selectedSites = [];

  SearchQuery? get lastQuery => _lastQuery;

  List<SearchSite> get selectedSites => _selectedSites;

  void setSearch(SearchQuery q, List<SearchSite> sites) {
    _lastQuery = q;
    _selectedSites = List.from(sites);
    notifyListeners();
  }
}
