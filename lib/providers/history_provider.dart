import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/search_query.dart';
import '../models/saved_result.dart';

class HistoryProvider extends ChangeNotifier {
  final Box<SearchQuery> _queryBox;
  final Box<SavedResult> _resultBox;

  HistoryProvider({required Box<SearchQuery> queryBox, required Box<SavedResult> resultBox})
      : _queryBox = queryBox,
        _resultBox = resultBox;

  List<SearchQuery> get queries => _queryBox.values.toList().reversed.toList();

  List<SavedResult> get results => _resultBox.values.toList().reversed.toList();

  void addQuery(SearchQuery q) {
    _queryBox.put(q.id, q);
    notifyListeners();
  }

  void deleteQuery(String id) {
    _queryBox.delete(id);
    notifyListeners();
  }

  void addResult(SavedResult r) {
    _resultBox.put(r.id, r);
    notifyListeners();
  }

  void deleteResult(String id) {
    _resultBox.delete(id);
    notifyListeners();
  }
}
