import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/search_query.dart';
import 'models/saved_result.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(SearchQueryAdapter());
  Hive.registerAdapter(SavedResultAdapter());
  await Hive.openBox<SearchQuery>('search_queries');
  await Hive.openBox<SavedResult>('saved_results');
  runApp(const CineAvisApp());
}
