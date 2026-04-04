# 🎬 CineAvis — Recherche d'Avis et Critiques de Films

Application de bureau Windows pour rechercher des films, consulter leurs affiches, notes, synopsis et critiques, grâce à l'API gratuite TMDB (The Movie Database).

---

## 📋 Fonctionnalités

| Recherche | Description |
|-----------|-------------|
| 🔤 **Par Titre** | Trouvez un film en tapant son titre (ou une partie) |
| 🔑 **Par Mots-clés** | Recherche libre par mots-clés |
| 🎭 **Par Catégorie** | Parcourez par genre : Action, Comédie, Horreur, Drame… |
| 📅 **Par Année** | Tous les films sortis une année donnée (ex : 2023) |

- 🖼️ **Affiches des films** affichées automatiquement
- ⭐ **Notes et votes** TMDB
- 📝 **Synopsis** complet
- 💬 **Critiques et avis** des spectateurs (en français et en anglais)
- 🌐 **Liens directs** vers les pages TMDB et sites officiels
- 🎬 **Distribution** (acteurs principaux)
- 🔃 **Tri** par popularité, note ou date
- 📄 **Pagination** pour naviguer dans les résultats
- 🇫🇷 / 🇬🇧 Résultats en **français ou en anglais**

---

## 🚀 Installation et lancement (Windows)

### Étape 1 — Installer Python (si pas déjà fait)

1. Allez sur : **https://www.python.org/downloads/**
2. Téléchargez la dernière version de Python 3
3. **Important :** Lors de l'installation, cochez **"Add Python to PATH"**

### Étape 2 — Télécharger les fichiers

Téléchargez ou clonez ce dépôt sur votre PC.  
Vous devez avoir ces fichiers dans le même dossier :
```
cineavis.py
lancer.bat
installer_dependances.bat
requirements.txt
```

### Étape 3 — Installer les dépendances (une seule fois)

Double-cliquez sur **`installer_dependances.bat`**  
*(Cela installe automatiquement les bibliothèques `requests` et `Pillow`)*

### Étape 4 — Obtenir une clé API TMDB (gratuite)

1. Allez sur : **https://www.themoviedb.org/signup** (inscription gratuite)
2. Connectez-vous, puis allez dans : **Paramètres → API**
3. Cliquez sur **"Créer" / "Request an API Key"**
4. Choisissez le type **"Developer"**, remplissez le formulaire
5. Copiez votre **clé API v3** (une longue chaîne de caractères)

### Étape 5 — Lancer l'application

Double-cliquez sur **`lancer.bat`**

Au premier lancement, une fenêtre vous demandera votre clé API.  
Collez-la et cliquez sur **Enregistrer**. La clé est mémorisée pour les prochains lancements.

---

## 🖥️ Créer un raccourci sur le Bureau

1. Faites un clic droit sur **`lancer.bat`**
2. Choisissez **"Envoyer vers" → "Bureau (créer un raccourci)"**
3. Vous pouvez renommer le raccourci en **"CineAvis"**
4. Pour changer l'icône : clic droit → Propriétés → Changer d'icône

---

## ▶️ Utilisation

1. **Choisissez un type de recherche** dans le panneau gauche
2. **Entrez votre recherche** (titre, mots-clés, catégorie ou année)
3. Cliquez sur **🔍 RECHERCHER** (ou appuyez sur `Entrée`)
4. **Cliquez sur une affiche** pour voir les détails, le synopsis et les critiques
5. Dans les détails, cliquez sur **"Voir sur TMDB"** pour accéder à la page complète

---

## 🛠️ Dépendances

| Bibliothèque | Usage |
|---|---|
| `tkinter` | Interface graphique (inclus avec Python) |
| `requests` | Appels API TMDB |
| `Pillow` | Affichage des affiches (images) |

---

## 📁 Structure du projet

```
cineavis.py                  ← Application principale
lancer.bat                   ← Lanceur Windows (double-clic)
installer_dependances.bat    ← Installeur des bibliothèques
requirements.txt             ← Liste des dépendances
README.md                    ← Ce fichier
```

---

## ❓ Dépannage

| Problème | Solution |
|---|---|
| `python` n'est pas reconnu | Réinstallez Python en cochant "Add Python to PATH" |
| Clé API invalide | Vérifiez que vous avez copié la clé **v3** (pas v4) dans les paramètres ⚙ |
| Pas d'images / pas de résultats | Vérifiez votre connexion Internet |
| Fenêtre qui se ferme immédiatement | Lancez `cineavis.py` directement depuis un terminal pour voir l'erreur |

---

*Données fournies par [The Movie Database (TMDB)](https://www.themoviedb.org/). Ce produit utilise l'API TMDB mais n'est pas approuvé ou certifié par TMDB.*

