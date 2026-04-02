# CineAvis — Moteur de recherche d'avis et critiques de films

Application Flutter (Android + Windows) pour rechercher des avis et critiques de films à partir de sites connus.  
Les données de films (affiches, genres, suggestions de titres) sont fournies par l'[API TMDB](https://www.themoviedb.org/).

---

## ✨ Fonctionnalités

- 🎭 **Dropdown genre** alimenté dynamiquement depuis TMDB (avec fallback statique)
- 🔍 **Recherche par titre** avec auto-complétion TMDB (suggestions en temps réel)
- 🗝️ **Mots-clés** libres
- 🎬 **Affiche + titre** du film affiché dans l'écran résultats
- 🔗 **Liens vérifiables** vers : Allociné, SensCritique, Rotten Tomatoes, IMDb, Metacritic, Letterboxd, The Guardian, Variety, Roger Ebert…
- 📜 **Historique local** (Hive) consultable et rejouable
- ← → **Navigation avant/arrière** entre les résultats
- 🌗 **Thème clair/sombre** (Material 3, couleurs chaudes)
- 🇫🇷 🇬🇧 **Langues FR/EN** commutables
- 📱💻 Compilable pour **Android** et **Windows**

---

## 🔑 Obtenir une clé API TMDB (gratuit)

1. Crée un compte sur [https://www.themoviedb.org/](https://www.themoviedb.org/).
2. Connecte-toi puis va dans :  
   **Paramètres du compte → API → Demander une clé API**.
3. Choisis **Developer** (usage personnel).
4. Remplis le formulaire :
   - Nom : `CineAvis`
   - URL : `http://localhost` (ou ton GitHub)
   - Description : `Application de recherche d'avis de films`
5. TMDB te fournit une **API Key (v3 auth)** — copie-la.

---

## ⚙️ Configuration (fichier `.env`)

1. Copie le fichier exemple :
   ```bash
   cp .env.example .env
   ```
2. Ouvre `.env` et remplace la valeur :
   ```env
   TMDB_API_KEY=ta_cle_api_ici
   TMDB_BASE_URL=https://api.themoviedb.org/3
   TMDB_IMAGE_BASE_URL=https://image.tmdb.org/t/p/w500
   ```
3. ⚠️ **Ne jamais committer `.env`** — il est déjà dans `.gitignore`.

> Sans clé, l'app fonctionne avec une liste de genres statique et sans suggestions de titres.

---

## 🚀 Installation & Build

### Prérequis

- [Flutter SDK ≥ 3.0](https://flutter.dev/docs/get-started/install)
- Pour Android : Android SDK + émulateur ou téléphone
- Pour Windows : Visual Studio 2022 + desktop workload

### Commandes

```bash
# Installer les dépendances
flutter pub get

# Lancer en mode développement (Android / Windows)
flutter run

# Build APK Android
flutter build apk --release

# Build Windows
flutter config --enable-windows-desktop
flutter build windows --release
```

---

## 🧪 Tests

```bash
flutter test
```

Les tests unitaires couvrent :
- Mapping JSON des genres TMDB (`TmdbGenre.fromJson`)
- Construction d'URL poster (`TmdbMovie.posterUrl`)
- Parsing des résultats de recherche (`TmdbSearchResult.fromJson`)

---

## 📁 Structure du projet

```
lib/
├── main.dart                  # Point d'entrée
├── theme.dart                 # Thèmes clair/sombre
├── models/
│   ├── tmdb_genre.dart        # Modèle genre TMDB + fallback
│   ├── tmdb_movie.dart        # Modèle film TMDB + SearchResult
│   └── search_query.dart      # Recherche + sites de critiques
├── services/
│   ├── tmdb_client.dart       # Client API TMDB (http)
│   └── history_service.dart   # Historique local (Hive)
├── providers/
│   ├── settings_provider.dart # Thème + langue
│   └── search_provider.dart   # État de la recherche
└── screens/
    ├── search_screen.dart     # Écran de recherche
    ├── results_screen.dart    # Écran résultats (poster + liens)
    ├── history_screen.dart    # Historique
    └── settings_screen.dart   # Paramètres
test/
└── tmdb_model_test.dart       # Tests unitaires
```

---

## 📝 Licence

This product uses the TMDB API but is not endorsed or certified by TMDB.  
Ce projet est à usage personnel / éducatif.
 
