import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class CategoryDropdownWidget extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const CategoryDropdownWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static List<Map<String, String>> getGenres(bool isFrench) => [
    {'value': '', 'label': isFrench ? '-- Aucun --' : '-- None --'},
    {'value': isFrench ? 'Action' : 'Action', 'label': 'Action'},
    {'value': isFrench ? 'Comédie' : 'Comedy', 'label': isFrench ? 'Comédie' : 'Comedy'},
    {'value': isFrench ? 'Drame' : 'Drama', 'label': isFrench ? 'Drame' : 'Drama'},
    {'value': isFrench ? 'Horreur' : 'Horror', 'label': isFrench ? 'Horreur' : 'Horror'},
    {'value': 'Science-fiction', 'label': 'Science-fiction'},
    {'value': 'Thriller', 'label': 'Thriller'},
    {'value': 'Animation', 'label': 'Animation'},
    {'value': isFrench ? 'Documentaire' : 'Documentary', 'label': isFrench ? 'Documentaire' : 'Documentary'},
    {'value': 'Romance', 'label': 'Romance'},
    {'value': isFrench ? 'Aventure' : 'Adventure', 'label': isFrench ? 'Aventure' : 'Adventure'},
    {'value': isFrench ? 'Fantastique' : 'Fantasy', 'label': isFrench ? 'Fantastique' : 'Fantasy'},
    {'value': isFrench ? 'Historique' : 'Historical', 'label': isFrench ? 'Historique' : 'Historical'},
    {'value': isFrench ? 'Biographie' : 'Biography', 'label': isFrench ? 'Biographie' : 'Biography'},
    {'value': 'Musical', 'label': 'Musical'},
  ];

  @override
  Widget build(BuildContext context) {
    final isFrench = context.watch<LocaleProvider>().isFrench;
    final genres = getGenres(isFrench);

    String? currentValue = value;
    final values = genres.map((g) => g['value']!).toList();
    if (currentValue != null && !values.contains(currentValue)) {
      currentValue = null;
    }

    return DropdownButtonFormField<String>(
      value: currentValue?.isEmpty == true ? null : currentValue,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade800, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade800, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade900, width: 2.5),
        ),
      ),
      hint: Text(isFrench ? 'Catégorie / Genre' : 'Category / Genre'),
      isExpanded: true,
      items: genres
          .where((g) => g['value']!.isNotEmpty)
          .map((g) => DropdownMenuItem<String>(
                value: g['value'],
                child: Text(g['label']!),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
