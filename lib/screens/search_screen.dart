import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/search_query.dart';
import '../models/search_site.dart';
import '../providers/history_provider.dart';
import '../providers/search_state_provider.dart';
import '../services/query_generator.dart';
import '../widgets/search_field_widget.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/nav_bar_widget.dart';

class SearchScreen extends StatefulWidget {
  final SearchQuery? prefillQuery;

  const SearchScreen({super.key, this.prefillQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _titleController = TextEditingController();
  final _keywordsController = TextEditingController();
  String? _selectedGenre;
  late List<bool> _siteSelected;
  final List<SearchSite> _sites = QueryGeneratorService.defaultSites;

  @override
  void initState() {
    super.initState();
    _siteSelected = List.filled(_sites.length, true);
    if (widget.prefillQuery != null) {
      final q = widget.prefillQuery!;
      _titleController.text = q.title ?? '';
      _keywordsController.text = q.keywords ?? '';
      _selectedGenre = q.genre;
      _siteSelected = _sites
          .map((s) => q.siteKeys.contains(s.key))
          .toList();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  void _performSearch(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedSites = <SearchSite>[];
    for (int i = 0; i < _sites.length; i++) {
      if (_siteSelected[i]) selectedSites.add(_sites[i]);
    }

    if (selectedSites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectSites)),
      );
      return;
    }

    final query = SearchQuery(
      id: const Uuid().v4(),
      genre: _selectedGenre?.isEmpty == true ? null : _selectedGenre,
      title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      keywords: _keywordsController.text.trim().isEmpty ? null : _keywordsController.text.trim(),
      createdAt: DateTime.now(),
      siteKeys: selectedSites.map((s) => s.key).toList(),
    );

    context.read<HistoryProvider>().addQuery(query);
    context.read<SearchStateProvider>().setSearch(query, selectedSites);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: const [NavBarWidget()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.searchTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 16),
            CategoryDropdownWidget(
              value: _selectedGenre,
              onChanged: (v) => setState(() => _selectedGenre = v),
            ),
            const SizedBox(height: 12),
            SearchFieldWidget(
              controller: _titleController,
              label: l10n.titleLabel,
              hint: 'Ex: Inception',
              prefixIcon: Icons.movie,
            ),
            const SizedBox(height: 12),
            SearchFieldWidget(
              controller: _keywordsController,
              label: l10n.keywordsLabel,
              hint: 'Ex: Christopher Nolan',
              prefixIcon: Icons.label,
            ),
            const SizedBox(height: 16),
            Text(l10n.selectSites,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(_sites.length, (i) {
                return FilterChip(
                  label: Text(_sites[i].name),
                  selected: _siteSelected[i],
                  onSelected: (v) => setState(() => _siteSelected[i] = v),
                  selectedColor: theme.colorScheme.primaryContainer,
                );
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _performSearch(context),
              icon: const Icon(Icons.search),
              label: Text(l10n.searchButton,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 4,
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
