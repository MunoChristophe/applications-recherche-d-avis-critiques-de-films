import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/search_query.dart';

/// Service de gestion de l'historique de recherches locales (Hive).
class HistoryService {
  static const String _boxName = 'search_history';

  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Ajoute une recherche à l'historique.
  Future<void> add(SearchQuery query) async {
    await _box.put(query.id, jsonEncode(query.toJson()));
  }

  /// Récupère toutes les recherches (ordre inverse de création).
  List<SearchQuery> getAll() {
    final entries = _box.values
        .map((v) {
          try {
            return SearchQuery.fromJson(
                jsonDecode(v) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<SearchQuery>()
        .toList();

    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  /// Supprime une entrée par son [id].
  Future<void> remove(String id) async {
    await _box.delete(id);
  }

  /// Vide tout l'historique.
  Future<void> clear() async {
    await _box.clear();
  }
}
