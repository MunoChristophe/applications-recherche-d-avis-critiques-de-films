# CineAvis 🎬

A Flutter application for searching movie reviews across multiple film criticism websites. CineAvis generates optimized search queries and opens them in your browser — no scraping, no paid APIs.

## Features

- 🔍 **3 search fields**: Genre/Category, Movie Title, Keywords
- 🌐 **9 review sites**: Allociné, SensCritique, Rotten Tomatoes, IMDb, Metacritic, Letterboxd, The Guardian, Variety, RogerEbert
- 🔗 **Smart query generation**: Builds DuckDuckGo search URLs with `site:` filters
- 💾 **Local history**: Save searches and bookmarked results (Hive)
- 🌍 **FR/EN bilingual**: Full i18n with ARB files
- 🌙 **Light/Dark theme toggle**
- 📱 **Android + Windows** support

## Prerequisites

- Flutter SDK ≥ 3.19
- Dart SDK ≥ 3.3
- Android Studio / VS Code with Flutter extension
- For Android: Android SDK (API 21+)
- For Windows: Visual Studio with C++ build tools

## Setup

```bash
# Clone the repository
git clone <repository-url>
cd applications-recherche-d-avis-critiques-de-films

# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# (Optional) Regenerate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs
```

## Build

```bash
# Run on connected device/emulator
flutter run

# Build Android APK
flutter build apk --release

# Build Windows
flutter build windows --release

# Run tests
flutter test
```

## Project Structure

```
lib/
├── main.dart                    # Entry point, Hive initialization
├── app.dart                     # CineAvisApp widget, providers setup
├── models/
│   ├── search_query.dart        # Hive model: search parameters
│   ├── search_query.g.dart      # Hive adapter (hand-written)
│   ├── saved_result.dart        # Hive model: saved bookmarks
│   ├── saved_result.g.dart      # Hive adapter (hand-written)
│   └── search_site.dart         # Plain model: site definition
├── providers/
│   ├── theme_provider.dart      # Light/dark theme toggle
│   ├── locale_provider.dart     # FR/EN language toggle
│   ├── navigation_provider.dart # Back/forward navigation stack
│   ├── history_provider.dart    # Hive-backed search/save history
│   └── search_state_provider.dart # Current search state
├── screens/
│   ├── main_shell.dart          # Bottom navigation shell
│   ├── search_screen.dart       # Search form
│   ├── results_screen.dart      # Search results list
│   ├── history_screen.dart      # History & saved links
│   └── settings_screen.dart     # Theme, language, about
├── services/
│   └── query_generator.dart     # URL generation logic
├── widgets/
│   ├── search_field_widget.dart # Styled text field
│   ├── category_dropdown.dart   # Genre dropdown
│   └── nav_bar_widget.dart      # Back/forward buttons
└── l10n/
    ├── app_fr.arb               # French strings
    └── app_en.arb               # English strings

test/
└── query_generator_test.dart    # Unit tests for query generation
```

## How It Works

CineAvis generates search URLs using DuckDuckGo with a `site:` filter:

```
https://duckduckgo.com/?q="Movie Title" Genre Keywords (critique OR review) site:imdb.com
```

This searches a specific review site without using any paid API or scraping.

## Modifying the Sites List

Edit `lib/services/query_generator.dart` and modify the `defaultSites` list:

```dart
static const List<SearchSite> defaultSites = [
  SearchSite(key: 'mysite', name: 'My Site', domain: 'mysite.com'),
  // ...
];
```

## License

MIT License — see [LICENSE](LICENSE) for details.
