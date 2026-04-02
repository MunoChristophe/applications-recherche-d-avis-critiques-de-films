import 'package:hive/hive.dart';
part 'search_query.g.dart';

@HiveType(typeId: 0)
class SearchQuery extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? genre;

  @HiveField(2)
  String? title;

  @HiveField(3)
  String? keywords;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  List<String> siteKeys;

  SearchQuery({
    required this.id,
    this.genre,
    this.title,
    this.keywords,
    required this.createdAt,
    required this.siteKeys,
  });
}
