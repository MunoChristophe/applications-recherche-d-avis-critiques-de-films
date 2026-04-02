import 'package:hive/hive.dart';
part 'saved_result.g.dart';

@HiveType(typeId: 1)
class SavedResult extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String siteKey;

  @HiveField(2)
  String siteName;

  @HiveField(3)
  String url;

  @HiveField(4)
  String query;

  @HiveField(5)
  DateTime savedAt;

  SavedResult({
    required this.id,
    required this.siteKey,
    required this.siteName,
    required this.url,
    required this.query,
    required this.savedAt,
  });
}
