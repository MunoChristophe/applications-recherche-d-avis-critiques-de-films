#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CineAvis - Application de Recherche d'Avis et Critiques de Films
=================================================================
Auteur : CineAvis
Utilise l'API TMDB (gratuite) : https://www.themoviedb.org/settings/api

Dependances :
    pip install requests Pillow

Utilisation :
    python cineavis.py
"""

import tkinter as tk
from tkinter import ttk, messagebox
import requests
from PIL import Image, ImageTk
from io import BytesIO
import threading
import webbrowser
import json
import os

# ============================================================
# CONFIGURATION
# ============================================================
CONFIG_FILE = os.path.join(os.path.expanduser("~"), ".cineavis_config.json")
BASE_URL = "https://api.themoviedb.org/3"
IMG_SMALL = "https://image.tmdb.org/t/p/w185"
IMG_LARGE = "https://image.tmdb.org/t/p/w500"
TMDB_MOVIE_URL = "https://www.themoviedb.org/movie/"

# Couleurs (theme cinema sombre)
BG = "#1a1a2e"
PANEL = "#16213e"
CARD = "#0f3460"
CARD_HOVER = "#1a4a80"
ACCENT = "#e94560"
TXT = "#ffffff"
SUBTXT = "#a8a8b3"
GREEN = "#27ae60"
ORANGE = "#f39c12"
RED = "#e74c3c"

POSTER_W, POSTER_H = 130, 195
POSTER_LARGE_W, POSTER_LARGE_H = 220, 330
CARD_COLS = 4


# ============================================================
# PERSISTANCE CONFIG
# ============================================================
def load_config():
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return {}


def save_config(data):
    try:
        with open(CONFIG_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    except Exception:
        pass


# ============================================================
# FONCTIONS API TMDB
# ============================================================
def _get(api_key, endpoint, params=None, timeout=12):
    """Appel GET generique vers l'API TMDB."""
    p = {"api_key": api_key}
    if params:
        p.update(params)
    r = requests.get(f"{BASE_URL}{endpoint}", params=p, timeout=timeout)
    r.raise_for_status()
    return r.json()


def api_genres(api_key, lang="fr-FR"):
    data = _get(api_key, "/genre/movie/list", {"language": lang})
    return data.get("genres", [])


def api_search_title(api_key, query, lang="fr-FR", page=1):
    return _get(api_key, "/search/movie", {
        "query": query, "language": lang, "page": page,
        "include_adult": "false"
    })


def api_discover_genre(api_key, genre_id, lang="fr-FR", page=1, sort_by="popularity.desc"):
    return _get(api_key, "/discover/movie", {
        "with_genres": genre_id, "language": lang, "page": page,
        "sort_by": sort_by, "include_adult": "false"
    })


def api_discover_year(api_key, year, lang="fr-FR", page=1, sort_by="popularity.desc"):
    return _get(api_key, "/discover/movie", {
        "primary_release_year": year, "language": lang,
        "page": page, "sort_by": sort_by, "include_adult": "false"
    })


def api_movie_details(api_key, movie_id, lang="fr-FR"):
    return _get(api_key, f"/movie/{movie_id}", {
        "language": lang,
        "append_to_response": "credits,videos"
    })


def api_movie_reviews(api_key, movie_id, lang="en-US", page=1):
    return _get(api_key, f"/movie/{movie_id}/reviews", {"language": lang, "page": page})


def load_image(url, size):
    """Charge et redimensionne une image depuis une URL."""
    try:
        r = requests.get(url, timeout=10)
        r.raise_for_status()
        img = Image.open(BytesIO(r.content)).convert("RGB")
        img = img.resize(size, Image.LANCZOS)
        return ImageTk.PhotoImage(img)
    except Exception:
        return None


# ============================================================
# APPLICATION PRINCIPALE
# ============================================================
class CineAvis:
    def __init__(self, root):
        self.root = root
        self.root.title("CineAvis — Recherche d'Avis et Critiques de Films")
        self.root.geometry("1280x820")
        self.root.minsize(960, 640)
        self.root.configure(bg=BG)

        # Etat
        cfg = load_config()
        self.api_key = cfg.get("api_key", "")
        self.lang_var = tk.StringVar(value=cfg.get("lang", "fr-FR"))
        self.search_type = tk.StringVar(value="titre")
        self.genre_var = tk.StringVar()
        self.sort_display = tk.StringVar(value="Popularite \u2193")
        self.genres = []
        self.current_page = 1
        self.total_pages = 1
        self._last_search_args = None
        self._image_cache = {}
        self._active_threads = []

        # Placeholder poster
        ph = Image.new("RGB", (POSTER_W, POSTER_H), "#0f3460")
        self._placeholder = ImageTk.PhotoImage(ph)

        self._style_ttk()
        self._build_ui()

        if not self.api_key:
            self.root.after(200, self._dialog_api_key)
        else:
            threading.Thread(target=self._fetch_genres, daemon=True).start()

    # ----------------------------------------------------------
    # STYLE
    # ----------------------------------------------------------
    def _style_ttk(self):
        s = ttk.Style()
        s.theme_use("clam")
        s.configure("Dark.TCombobox", fieldbackground=CARD, background=CARD,
                    foreground=TXT, selectbackground=CARD, selectforeground=TXT,
                    arrowcolor=TXT)
        s.map("Dark.TCombobox", fieldbackground=[("readonly", CARD)],
              selectbackground=[("readonly", CARD)], foreground=[("readonly", TXT)])
        s.configure("Vertical.TScrollbar", background=PANEL, troughcolor=BG,
                    arrowcolor=SUBTXT, bordercolor=BG, lightcolor=PANEL, darkcolor=PANEL)

    # ----------------------------------------------------------
    # CONSTRUCTION UI
    # ----------------------------------------------------------
    def _build_ui(self):
        # Header
        hdr = tk.Frame(self.root, bg=PANEL, height=56)
        hdr.pack(fill=tk.X)
        hdr.pack_propagate(False)
        tk.Label(hdr, text="CineAvis", font=("Helvetica", 20, "bold"),
                 bg=PANEL, fg=ACCENT).pack(side=tk.LEFT, padx=20, pady=8)
        tk.Label(hdr, text="Recherche d'Avis et Critiques de Films",
                 font=("Helvetica", 11), bg=PANEL, fg=SUBTXT).pack(side=tk.LEFT, pady=8)
        tk.Button(hdr, text="\u2699 Parametres", command=self._dialog_settings,
                  bg=PANEL, fg=SUBTXT, relief=tk.FLAT, font=("Helvetica", 9),
                  cursor="hand2", bd=0, activebackground=PANEL,
                  activeforeground=TXT).pack(side=tk.RIGHT, padx=20)

        # Body
        body = tk.Frame(self.root, bg=BG)
        body.pack(fill=tk.BOTH, expand=True, padx=8, pady=6)

        self._build_left(body)
        self._build_right(body)

    def _build_left(self, parent):
        left = tk.Frame(parent, bg=PANEL, width=258)
        left.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 8), pady=0)
        left.pack_propagate(False)

        def lbl_section(text):
            tk.Label(left, text=text, font=("Helvetica", 8, "bold"),
                     bg=PANEL, fg=SUBTXT).pack(anchor=tk.W, padx=16, pady=(14, 4))

        lbl_section("TYPE DE RECHERCHE")

        self._rb_buttons = []
        for txt, val in [
            ("\U0001f524 Par Titre", "titre"),
            ("\U0001f511 Par Mots-clés", "motscles"),
            ("\U0001f3ad Par Catégorie", "categorie"),
            ("\U0001f4c5 Par Année", "annee"),
        ]:
            rb = tk.Radiobutton(left, text=txt, variable=self.search_type, value=val,
                                command=self._on_type_change, bg=PANEL, fg=TXT,
                                selectcolor=CARD, activebackground=PANEL,
                                activeforeground=ACCENT, font=("Helvetica", 10),
                                cursor="hand2", anchor=tk.W)
            rb.pack(fill=tk.X, padx=16, pady=2)

        self._sep(left)
        lbl_section("PARAMETRE DE RECHERCHE")

        # Zone dynamique de saisie
        self._input_zone = tk.Frame(left, bg=PANEL)
        self._input_zone.pack(fill=tk.X, padx=16)

        self._input_lbl = tk.Label(self._input_zone, text="Titre du film :",
                                   bg=PANEL, fg=TXT, font=("Helvetica", 9))
        self._input_entry = tk.Entry(self._input_zone, bg=CARD, fg=TXT,
                                     insertbackground=TXT, font=("Helvetica", 10),
                                     relief=tk.FLAT)
        self._input_entry.bind("<Return>", lambda e: self._do_search())

        self._genre_lbl = tk.Label(self._input_zone, text="Catégorie :",
                                   bg=PANEL, fg=TXT, font=("Helvetica", 9))
        self._genre_combo = ttk.Combobox(self._input_zone, textvariable=self.genre_var,
                                         state="readonly", style="Dark.TCombobox",
                                         font=("Helvetica", 10))
        self._genre_combo.bind("<Return>", lambda e: self._do_search())

        self._year_lbl = tk.Label(self._input_zone, text="Année (ex: 2023) :",
                                  bg=PANEL, fg=TXT, font=("Helvetica", 9))
        self._year_entry = tk.Entry(self._input_zone, bg=CARD, fg=TXT,
                                    insertbackground=TXT, font=("Helvetica", 10),
                                    relief=tk.FLAT, width=12)
        self._year_entry.bind("<Return>", lambda e: self._do_search())

        self._on_type_change()

        self._sep(left)
        lbl_section("TRIER PAR")

        sort_opts = [
            ("Popularite \u2193", "popularity.desc"),
            ("Popularite \u2191", "popularity.asc"),
            ("Note \u2193", "vote_average.desc"),
            ("Note \u2191", "vote_average.asc"),
            ("Date \u2193", "release_date.desc"),
            ("Date \u2191", "release_date.asc"),
        ]
        self._sort_map = {k: v for k, v in sort_opts}
        sort_combo = ttk.Combobox(left, textvariable=self.sort_display,
                                  values=[k for k, _ in sort_opts], state="readonly",
                                  style="Dark.TCombobox", font=("Helvetica", 9))
        sort_combo.pack(fill=tk.X, padx=16, pady=(0, 4))

        self._sep(left)
        lbl_section("LANGUE DES RESULTATS")
        for txt, val in [("\U0001f1eb\U0001f1f7 Francais", "fr-FR"),
                         ("\U0001f1ec\U0001f1e7 English", "en-US")]:
            tk.Radiobutton(left, text=txt, variable=self.lang_var, value=val,
                           bg=PANEL, fg=TXT, selectcolor=CARD,
                           activebackground=PANEL, font=("Helvetica", 9),
                           cursor="hand2").pack(anchor=tk.W, padx=16, pady=1)

        self._sep(left)
        self._search_btn = tk.Button(left, text="\U0001f50d  RECHERCHER",
                                     command=self._do_search,
                                     bg=ACCENT, fg=TXT, font=("Helvetica", 11, "bold"),
                                     relief=tk.FLAT, cursor="hand2", pady=9,
                                     activebackground="#c73652", activeforeground=TXT)
        self._search_btn.pack(fill=tk.X, padx=16, pady=6)

        self._status_lbl = tk.Label(left, text="", bg=PANEL, fg=SUBTXT,
                                    font=("Helvetica", 8), wraplength=224, justify=tk.LEFT)
        self._status_lbl.pack(padx=16, pady=4)

    def _sep(self, parent):
        ttk.Separator(parent, orient=tk.HORIZONTAL).pack(fill=tk.X, padx=16, pady=6)

    def _build_right(self, parent):
        right = tk.Frame(parent, bg=BG)
        right.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        # Barre resultats + pagination
        top_bar = tk.Frame(right, bg=BG)
        top_bar.pack(fill=tk.X, pady=(0, 6))

        self._results_lbl = tk.Label(top_bar, text="Bienvenue dans CineAvis !",
                                     font=("Helvetica", 12, "bold"), bg=BG, fg=TXT)
        self._results_lbl.pack(side=tk.LEFT)

        nav = tk.Frame(top_bar, bg=BG)
        nav.pack(side=tk.RIGHT)

        self._page_lbl = tk.Label(nav, text="", font=("Helvetica", 9),
                                  bg=BG, fg=SUBTXT)
        self._page_lbl.pack(side=tk.LEFT, padx=8)

        self._prev_btn = tk.Button(nav, text="\u25c0 Precedent", command=self._prev_page,
                                   bg=CARD, fg=TXT, relief=tk.FLAT, font=("Helvetica", 9),
                                   cursor="hand2", state=tk.DISABLED, bd=0,
                                   activebackground=CARD_HOVER, activeforeground=TXT,
                                   padx=8, pady=4)
        self._prev_btn.pack(side=tk.LEFT, padx=2)

        self._next_btn = tk.Button(nav, text="Suivant \u25b6", command=self._next_page,
                                   bg=CARD, fg=TXT, relief=tk.FLAT, font=("Helvetica", 9),
                                   cursor="hand2", state=tk.DISABLED, bd=0,
                                   activebackground=CARD_HOVER, activeforeground=TXT,
                                   padx=8, pady=4)
        self._next_btn.pack(side=tk.LEFT, padx=2)

        # Zone de resultats scrollable
        frame = tk.Frame(right, bg=BG)
        frame.pack(fill=tk.BOTH, expand=True)

        self._canvas = tk.Canvas(frame, bg=BG, highlightthickness=0)
        vbar = ttk.Scrollbar(frame, orient=tk.VERTICAL, command=self._canvas.yview)
        self._grid_frame = tk.Frame(self._canvas, bg=BG)

        self._canvas.configure(yscrollcommand=vbar.set)
        vbar.pack(side=tk.RIGHT, fill=tk.Y)
        self._canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        self._cwin = self._canvas.create_window((0, 0), window=self._grid_frame, anchor=tk.NW)

        self._grid_frame.bind("<Configure>",
                              lambda e: self._canvas.configure(
                                  scrollregion=self._canvas.bbox("all")))
        self._canvas.bind("<Configure>",
                          lambda e: self._canvas.itemconfig(self._cwin, width=e.width))
        self._canvas.bind("<MouseWheel>", self._on_scroll)
        self._canvas.bind("<Button-4>", self._on_scroll)
        self._canvas.bind("<Button-5>", self._on_scroll)

        self._info_lbl = tk.Label(self._grid_frame,
                                  text="Lancez une recherche pour decouvrir des films !",
                                  font=("Helvetica", 13), bg=BG, fg=SUBTXT)
        self._info_lbl.grid(row=0, column=0, columnspan=CARD_COLS, pady=80)

    def _on_scroll(self, event):
        if event.num == 4:
            self._canvas.yview_scroll(-1, "units")
        elif event.num == 5:
            self._canvas.yview_scroll(1, "units")
        else:
            self._canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")

    # ----------------------------------------------------------
    # GESTION TYPE DE RECHERCHE
    # ----------------------------------------------------------
    def _on_type_change(self):
        t = self.search_type.get()
        for w in [self._input_lbl, self._input_entry,
                  self._genre_lbl, self._genre_combo,
                  self._year_lbl, self._year_entry]:
            w.pack_forget()

        if t in ("titre", "motscles"):
            self._input_lbl.config(text="Titre du film :" if t == "titre" else "Mots-clés :")
            self._input_lbl.pack(anchor=tk.W, pady=(0, 3))
            self._input_entry.pack(fill=tk.X, ipady=5, pady=(0, 6))
        elif t == "categorie":
            self._genre_lbl.pack(anchor=tk.W, pady=(0, 3))
            self._genre_combo.pack(fill=tk.X, pady=(0, 6))
        elif t == "annee":
            self._year_lbl.pack(anchor=tk.W, pady=(0, 3))
            self._year_entry.pack(fill=tk.X, ipady=5, pady=(0, 6))

    # ----------------------------------------------------------
    # CHARGEMENT GENRES
    # ----------------------------------------------------------
    def _fetch_genres(self):
        try:
            genres = api_genres(self.api_key, self.lang_var.get())
            self.genres = genres
            names = [g["name"] for g in genres]
            self.root.after(0, lambda: self._set_genres(names))
        except Exception as e:
            self.root.after(0, lambda: self._set_status(f"Impossible de charger les genres : {e}"))

    def _set_genres(self, names):
        self._genre_combo["values"] = names
        if names:
            self._genre_combo.set(names[0])

    # ----------------------------------------------------------
    # RECHERCHE
    # ----------------------------------------------------------
    def _do_search(self, page=1):
        if not self.api_key:
            self._dialog_api_key()
            return

        t = self.search_type.get()

        if t in ("titre", "motscles"):
            query = self._input_entry.get().strip()
            if not query:
                messagebox.showwarning("Saisie requise",
                                       "Veuillez entrer un titre ou des mots-clés.")
                return
        elif t == "categorie":
            query = self.genre_var.get()
            if not query:
                messagebox.showwarning("Saisie requise", "Veuillez sélectionner une catégorie.")
                return
        elif t == "annee":
            query = self._year_entry.get().strip()
            if not query or not query.isdigit() or len(query) != 4:
                messagebox.showwarning("Saisie requise",
                                       "Veuillez entrer une année valide (ex: 2023).")
                return
        else:
            return

        self.current_page = page
        self._last_search_args = (t, query)
        self._show_loading()
        self._search_btn.config(state=tk.DISABLED)

        sort_by = self._sort_map.get(self.sort_display.get(), "popularity.desc")
        lang = self.lang_var.get()

        def task():
            try:
                if t in ("titre", "motscles"):
                    data = api_search_title(self.api_key, query, lang, page)
                elif t == "categorie":
                    gid = next((g["id"] for g in self.genres if g["name"] == query), None)
                    if gid is None:
                        data = {"results": [], "total_pages": 0, "total_results": 0}
                    else:
                        data = api_discover_genre(self.api_key, gid, lang, page, sort_by)
                elif t == "annee":
                    data = api_discover_year(self.api_key, query, lang, page, sort_by)
                else:
                    data = {"results": [], "total_pages": 0, "total_results": 0}

                movies = data.get("results", [])
                self.total_pages = min(data.get("total_pages", 1), 500)
                total = data.get("total_results", 0)
                self.root.after(0, lambda: self._display(movies, total))
            except requests.exceptions.ConnectionError:
                self.root.after(0, lambda: self._show_error(
                    "Pas de connexion Internet. Vérifiez votre réseau."))
            except requests.exceptions.HTTPError as exc:
                if exc.response is not None and exc.response.status_code == 401:
                    self.root.after(0, lambda: self._show_error(
                        "Clé API invalide. Vérifiez vos paramètres (\u2699)."))
                else:
                    self.root.after(0, lambda: self._show_error(f"Erreur API : {exc}"))
            except Exception as exc:
                self.root.after(0, lambda: self._show_error(f"Erreur : {exc}"))

        threading.Thread(target=task, daemon=True).start()

    def _show_loading(self):
        self._clear_grid()
        self._info_lbl = tk.Label(self._grid_frame, text="\u23f3 Recherche en cours...",
                                  font=("Helvetica", 13), bg=BG, fg=SUBTXT)
        self._info_lbl.grid(row=0, column=0, columnspan=CARD_COLS, pady=80)

    def _show_error(self, msg):
        self._clear_grid()
        self._search_btn.config(state=tk.NORMAL)
        self._info_lbl = tk.Label(self._grid_frame, text=f"\u274c {msg}",
                                  font=("Helvetica", 12), bg=BG, fg=RED, wraplength=700)
        self._info_lbl.grid(row=0, column=0, columnspan=CARD_COLS, pady=80)

    def _clear_grid(self):
        for w in self._grid_frame.winfo_children():
            w.destroy()

    def _display(self, movies, total):
        self._clear_grid()
        self._search_btn.config(state=tk.NORMAL)
        self._results_lbl.config(text=f"{total:,} film(s) trouvé(s)")
        self._page_lbl.config(text=f"Page {self.current_page} / {self.total_pages}")
        self._prev_btn.config(state=tk.NORMAL if self.current_page > 1 else tk.DISABLED)
        self._next_btn.config(state=tk.NORMAL if self.current_page < self.total_pages else tk.DISABLED)

        if not movies:
            self._info_lbl = tk.Label(self._grid_frame,
                                      text="\U0001f615 Aucun film trouve pour cette recherche.",
                                      font=("Helvetica", 13), bg=BG, fg=SUBTXT)
            self._info_lbl.grid(row=0, column=0, columnspan=CARD_COLS, pady=80)
            return

        for idx, movie in enumerate(movies):
            row, col = divmod(idx, CARD_COLS)
            self._make_card(movie, row, col)
            self._grid_frame.grid_columnconfigure(col, weight=1, minsize=160)

        self._canvas.yview_moveto(0)

    # ----------------------------------------------------------
    # CARTE FILM
    # ----------------------------------------------------------
    def _make_card(self, movie, row, col):
        card = tk.Frame(self._grid_frame, bg=CARD, relief=tk.FLAT, cursor="hand2")
        card.grid(row=row, column=col, padx=7, pady=7, sticky=tk.NSEW)

        # Poster
        poster_lbl = tk.Label(card, bg=CARD, image=self._placeholder)
        poster_lbl.image = self._placeholder
        poster_lbl.pack(padx=6, pady=(6, 0))

        if movie.get("poster_path"):
            url = f"{IMG_SMALL}{movie['poster_path']}"
            threading.Thread(target=self._set_img, args=(url, poster_lbl,
                                                          (POSTER_W, POSTER_H)),
                             daemon=True).start()

        # Titre
        title = movie.get("title") or movie.get("name") or "Titre inconnu"
        tk.Label(card, text=title, bg=CARD, fg=TXT,
                 font=("Helvetica", 9, "bold"), wraplength=138,
                 justify=tk.CENTER).pack(padx=6, pady=(4, 2))

        # Annee + Note
        year = (movie.get("release_date") or "")[:4] or "N/A"
        rating = movie.get("vote_average", 0)
        rc = GREEN if rating >= 7 else ORANGE if rating >= 5 else RED

        info = tk.Frame(card, bg=CARD)
        info.pack(pady=(0, 7))
        tk.Label(info, text=f"\U0001f4c5 {year}", bg=CARD, fg=SUBTXT,
                 font=("Helvetica", 8)).pack(side=tk.LEFT, padx=4)
        tk.Label(info, text=f"\u2b50 {rating:.1f}", bg=CARD, fg=rc,
                 font=("Helvetica", 8, "bold")).pack(side=tk.LEFT, padx=4)

        # Interactivite
        def enter(e, c=card):
            self._colorize(c, CARD_HOVER)

        def leave(e, c=card):
            self._colorize(c, CARD)

        def click(e, m=movie):
            self._open_detail(m)

        for w in self._all_widgets(card):
            w.bind("<Enter>", enter)
            w.bind("<Leave>", leave)
            w.bind("<Button-1>", click)

    def _colorize(self, widget, color):
        try:
            widget.config(bg=color)
        except Exception:
            pass
        for child in widget.winfo_children():
            self._colorize(child, color)

    @staticmethod
    def _all_widgets(root_widget):
        yield root_widget
        for child in root_widget.winfo_children():
            yield from CineAvis._all_widgets(child)

    def _set_img(self, url, label, size):
        if url in self._image_cache:
            img = self._image_cache[url]
        else:
            img = load_image(url, size)
            if img:
                self._image_cache[url] = img
        if img:
            self.root.after(0, lambda: self._apply_img(label, img))

    def _apply_img(self, label, img):
        try:
            if label.winfo_exists():
                label.config(image=img)
                label.image = img
        except Exception:
            pass

    # ----------------------------------------------------------
    # DETAIL FILM
    # ----------------------------------------------------------
    def _open_detail(self, movie):
        win = tk.Toplevel(self.root)
        title = movie.get("title") or movie.get("name") or "Film"
        win.title(f"\U0001f3ac {title}")
        win.geometry("960x720")
        win.configure(bg=BG)
        win.transient(self.root)

        loading = tk.Label(win, text="\u23f3 Chargement des details...",
                           bg=BG, fg=TXT, font=("Helvetica", 13))
        loading.pack(pady=60)

        def task():
            try:
                lang = self.lang_var.get()
                details = api_movie_details(self.api_key, movie["id"], lang)
                rev_en = api_movie_reviews(self.api_key, movie["id"], "en-US")
                rev_fr = api_movie_reviews(self.api_key, movie["id"], "fr-FR")
                reviews = rev_fr.get("results", []) + rev_en.get("results", [])
                self.root.after(0, lambda: self._build_detail(win, loading, details, reviews))
            except Exception as exc:
                self.root.after(0, lambda: loading.config(
                    text=f"\u274c Impossible de charger les details : {exc}"))

        threading.Thread(target=task, daemon=True).start()

    def _build_detail(self, win, loading, details, reviews):
        loading.destroy()

        # Canvas scrollable
        canvas = tk.Canvas(win, bg=BG, highlightthickness=0)
        vbar = ttk.Scrollbar(win, orient=tk.VERTICAL, command=canvas.yview)
        frame = tk.Frame(canvas, bg=BG)
        canvas.configure(yscrollcommand=vbar.set)
        vbar.pack(side=tk.RIGHT, fill=tk.Y)
        canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        cwin = canvas.create_window((0, 0), window=frame, anchor=tk.NW)
        frame.bind("<Configure>",
                   lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        canvas.bind("<Configure>", lambda e: canvas.itemconfig(cwin, width=e.width))
        canvas.bind("<MouseWheel>", lambda e: canvas.yview_scroll(
            int(-1 * (e.delta / 120)), "units"))

        # --- En-tete film ---
        hdr = tk.Frame(frame, bg=PANEL)
        hdr.pack(fill=tk.X, padx=12, pady=12)

        # Affiche
        ph = Image.new("RGB", (POSTER_LARGE_W, POSTER_LARGE_H), "#0f3460")
        ph_tk = ImageTk.PhotoImage(ph)
        poster = tk.Label(hdr, bg=PANEL, image=ph_tk)
        poster.image = ph_tk
        poster.pack(side=tk.LEFT, padx=14, pady=14)

        if details.get("poster_path"):
            url = f"{IMG_LARGE}{details['poster_path']}"
            threading.Thread(target=self._set_img,
                             args=(url, poster, (POSTER_LARGE_W, POSTER_LARGE_H)),
                             daemon=True).start()

        # Info
        info = tk.Frame(hdr, bg=PANEL)
        info.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=14, pady=14)

        title = details.get("title", "?")
        orig = details.get("original_title", "")
        year = (details.get("release_date") or "")[:4]
        rating = details.get("vote_average", 0)
        votes = details.get("vote_count", 0)
        runtime = details.get("runtime") or 0
        overview = details.get("overview") or "Pas de synopsis disponible."
        genres = ", ".join(g["name"] for g in details.get("genres", []))
        tagline = details.get("tagline", "")
        homepage = details.get("homepage", "")
        movie_id = details.get("id")

        tk.Label(info, text=title, font=("Helvetica", 18, "bold"),
                 bg=PANEL, fg=TXT, wraplength=620, justify=tk.LEFT).pack(anchor=tk.W)
        if orig and orig != title:
            tk.Label(info, text=f"({orig})", font=("Helvetica", 10, "italic"),
                     bg=PANEL, fg=SUBTXT).pack(anchor=tk.W)

        rc = GREEN if rating >= 7 else ORANGE if rating >= 5 else RED
        rf = tk.Frame(info, bg=PANEL)
        rf.pack(anchor=tk.W, pady=8)
        tk.Label(rf, text=f"\u2b50 {rating:.1f}/10", font=("Helvetica", 16, "bold"),
                 bg=PANEL, fg=rc).pack(side=tk.LEFT)
        tk.Label(rf, text=f"  ({votes:,} votes)", bg=PANEL, fg=SUBTXT,
                 font=("Helvetica", 10)).pack(side=tk.LEFT)

        mf = tk.Frame(info, bg=PANEL)
        mf.pack(anchor=tk.W, pady=2)
        if year:
            tk.Label(mf, text=f"\U0001f4c5 {year}", bg=PANEL, fg=SUBTXT,
                     font=("Helvetica", 10)).pack(side=tk.LEFT, padx=(0, 14))
        if runtime:
            h, m = divmod(runtime, 60)
            dur = f"{h}h{m:02d}" if h else f"{m}min"
            tk.Label(mf, text=f"\u23f1 {dur}", bg=PANEL, fg=SUBTXT,
                     font=("Helvetica", 10)).pack(side=tk.LEFT, padx=(0, 14))
        if genres:
            tk.Label(info, text=f"Genres : {genres}", bg=PANEL, fg=SUBTXT,
                     font=("Helvetica", 10), wraplength=620, justify=tk.LEFT).pack(
                anchor=tk.W, pady=2)
        if tagline:
            tk.Label(info, text=f"\u201c{tagline}\u201d", font=("Helvetica", 10, "italic"),
                     bg=PANEL, fg=ACCENT, wraplength=620, justify=tk.LEFT).pack(
                anchor=tk.W, pady=6)

        tk.Label(info, text="Synopsis :", font=("Helvetica", 10, "bold"),
                 bg=PANEL, fg=TXT).pack(anchor=tk.W, pady=(10, 3))
        st = tk.Text(info, height=5, bg=PANEL, fg=TXT, font=("Helvetica", 10),
                     relief=tk.FLAT, wrap=tk.WORD, state=tk.NORMAL)
        st.insert(tk.END, overview)
        st.config(state=tk.DISABLED)
        st.pack(fill=tk.X)

        # Boutons action
        bf = tk.Frame(info, bg=PANEL)
        bf.pack(anchor=tk.W, pady=10)
        tk.Button(bf, text="\U0001f310 Voir sur TMDB",
                  command=lambda: webbrowser.open(f"{TMDB_MOVIE_URL}{movie_id}"),
                  bg=ACCENT, fg=TXT, relief=tk.FLAT, cursor="hand2",
                  padx=10, pady=5, font=("Helvetica", 9)).pack(side=tk.LEFT, padx=(0, 6))
        if homepage:
            tk.Button(bf, text="\U0001f3e0 Site officiel",
                      command=lambda: webbrowser.open(homepage),
                      bg=CARD, fg=TXT, relief=tk.FLAT, cursor="hand2",
                      padx=10, pady=5, font=("Helvetica", 9)).pack(side=tk.LEFT, padx=(0, 6))

        # Distribution
        cast = (details.get("credits") or {}).get("cast", [])[:10]
        if cast:
            self._section_title(frame, "\U0001f3ac Distribution")
            cf = tk.Frame(frame, bg=BG)
            cf.pack(fill=tk.X, padx=16, pady=(0, 8))
            for actor in cast:
                n = actor.get("name", "")
                c = actor.get("character", "")
                tk.Label(cf, text=f"\u2022 {n}" + (f" \u2014 {c}" if c else ""),
                         bg=BG, fg=SUBTXT, font=("Helvetica", 9)).pack(side=tk.LEFT, padx=4)

        # Critiques
        self._section_title(frame, f"\U0001f4dd Critiques et Avis ({len(reviews)})")
        if reviews:
            for rev in reviews[:6]:
                self._review_card(frame, rev)
            tk.Button(frame, text="\U0001f4d6 Toutes les critiques sur TMDB \u2192",
                      command=lambda: webbrowser.open(
                          f"{TMDB_MOVIE_URL}{movie_id}/reviews"),
                      bg=CARD, fg=TXT, relief=tk.FLAT, cursor="hand2",
                      font=("Helvetica", 9), padx=10, pady=5).pack(
                anchor=tk.W, padx=16, pady=10)
        else:
            tk.Label(frame, text="Aucune critique disponible pour ce film.",
                     bg=BG, fg=SUBTXT, font=("Helvetica", 10)).pack(
                anchor=tk.W, padx=16, pady=(0, 12))

    def _section_title(self, parent, text):
        tk.Label(parent, text=text, font=("Helvetica", 12, "bold"),
                 bg=BG, fg=TXT).pack(anchor=tk.W, padx=16, pady=(14, 5))

    def _review_card(self, parent, rev):
        card = tk.Frame(parent, bg=PANEL, relief=tk.FLAT)
        card.pack(fill=tk.X, padx=16, pady=4)

        author = rev.get("author") or "Anonyme"
        r = (rev.get("author_details") or {}).get("rating")
        date = (rev.get("created_at") or "")[:10]
        url = rev.get("url", "")

        top = tk.Frame(card, bg=PANEL)
        top.pack(fill=tk.X, padx=10, pady=(8, 3))
        tk.Label(top, text=f"\U0001f464 {author}", font=("Helvetica", 10, "bold"),
                 bg=PANEL, fg=TXT).pack(side=tk.LEFT)
        if r:
            tk.Label(top, text=f"  \u2b50 {r}/10", bg=PANEL, fg=ORANGE,
                     font=("Helvetica", 9)).pack(side=tk.LEFT)
        if date:
            tk.Label(top, text=f"  \U0001f4c5 {date}", bg=PANEL, fg=SUBTXT,
                     font=("Helvetica", 8)).pack(side=tk.LEFT)
        if url:
            tk.Button(top, text="Lire \u2192", command=lambda: webbrowser.open(url),
                      bg=PANEL, fg=ACCENT, relief=tk.FLAT, cursor="hand2",
                      font=("Helvetica", 8)).pack(side=tk.RIGHT)

        content = (rev.get("content") or "").strip()
        if len(content) > 600:
            content = content[:600] + "...\n[Suite sur TMDB]"
        rt = tk.Text(card, height=5, bg=PANEL, fg=SUBTXT, font=("Helvetica", 9),
                     relief=tk.FLAT, wrap=tk.WORD, state=tk.NORMAL)
        rt.insert(tk.END, content)
        rt.config(state=tk.DISABLED)
        rt.pack(fill=tk.X, padx=10, pady=(0, 8))

    # ----------------------------------------------------------
    # PAGINATION
    # ----------------------------------------------------------
    def _prev_page(self):
        if self.current_page > 1:
            self._do_search(self.current_page - 1)

    def _next_page(self):
        if self.current_page < self.total_pages:
            self._do_search(self.current_page + 1)

    # ----------------------------------------------------------
    # DIALOGS
    # ----------------------------------------------------------
    def _dialog_api_key(self):
        dlg = tk.Toplevel(self.root)
        dlg.title("Configuration — Clé API TMDB")
        dlg.geometry("540x340")
        dlg.configure(bg=BG)
        dlg.grab_set()
        dlg.transient(self.root)

        tk.Label(dlg, text="\U0001f3ac CineAvis — Configuration initiale",
                 font=("Helvetica", 14, "bold"), bg=BG, fg=ACCENT).pack(pady=(18, 6))

        msg = ("Pour utiliser CineAvis, vous avez besoin d'une clé API TMDB GRATUITE.\n\n"
               "1. Cliquez sur le bouton ci-dessous pour ouvrir TMDB dans votre navigateur.\n"
               "2. Créez un compte gratuit (ou connectez-vous).\n"
               "3. Allez dans : Paramètres → API → Demander une clé (Developer).\n"
               "4. Copiez votre clé API v3 et collez-la ci-dessous.")
        tk.Label(dlg, text=msg, justify=tk.LEFT, bg=BG, fg=TXT,
                 wraplength=500, font=("Helvetica", 9)).pack(padx=20, pady=4)

        kv = tk.StringVar(value=self.api_key)
        e = tk.Entry(dlg, textvariable=kv, bg=CARD, fg=TXT,
                     insertbackground=TXT, font=("Helvetica", 10), relief=tk.FLAT)
        e.pack(fill=tk.X, padx=20, ipady=6, pady=8)
        e.focus_set()

        def save():
            k = kv.get().strip()
            if not k:
                messagebox.showwarning("Attention", "Entrez votre clé API.", parent=dlg)
                return
            self.api_key = k
            cfg = load_config()
            cfg["api_key"] = k
            save_config(cfg)
            dlg.destroy()
            threading.Thread(target=self._fetch_genres, daemon=True).start()

        bf = tk.Frame(dlg, bg=BG)
        bf.pack(pady=8)
        tk.Button(bf, text="\U0001f310 Ouvrir TMDB (inscription gratuite)",
                  command=lambda: webbrowser.open(
                      "https://www.themoviedb.org/signup"),
                  bg=PANEL, fg=TXT, relief=tk.FLAT, padx=10, pady=5,
                  cursor="hand2").pack(side=tk.LEFT, padx=4)
        tk.Button(bf, text="\u2714 Enregistrer",
                  command=save, bg=ACCENT, fg=TXT, relief=tk.FLAT,
                  padx=10, pady=5, cursor="hand2").pack(side=tk.LEFT, padx=4)

        self.root.wait_window(dlg)

    def _dialog_settings(self):
        dlg = tk.Toplevel(self.root)
        dlg.title("Paramètres")
        dlg.geometry("480x260")
        dlg.configure(bg=BG)
        dlg.grab_set()
        dlg.transient(self.root)

        tk.Label(dlg, text="\u2699 Paramètres", font=("Helvetica", 14, "bold"),
                 bg=BG, fg=TXT).pack(pady=(16, 8))

        f = tk.Frame(dlg, bg=BG)
        f.pack(fill=tk.X, padx=24)
        tk.Label(f, text="Clé API TMDB :", bg=BG, fg=TXT,
                 font=("Helvetica", 10)).pack(anchor=tk.W)
        kv = tk.StringVar(value=self.api_key)
        ke = tk.Entry(f, textvariable=kv, bg=CARD, fg=TXT,
                      insertbackground=TXT, font=("Helvetica", 10),
                      relief=tk.FLAT, show="*")
        ke.pack(fill=tk.X, ipady=5, pady=3)

        sv = tk.BooleanVar()

        def toggle():
            ke.config(show="" if sv.get() else "*")

        tk.Checkbutton(f, text="Afficher la clé", variable=sv, command=toggle,
                       bg=BG, fg=SUBTXT, selectcolor=CARD,
                       activebackground=BG).pack(anchor=tk.W)

        def save():
            k = kv.get().strip()
            if not k:
                messagebox.showwarning("Attention", "La clé API ne peut pas être vide.", parent=dlg)
                return
            self.api_key = k
            cfg = load_config()
            cfg["api_key"] = k
            save_config(cfg)
            dlg.destroy()
            threading.Thread(target=self._fetch_genres, daemon=True).start()
            messagebox.showinfo("Succès", "Paramètres enregistrés !")

        bf = tk.Frame(dlg, bg=BG)
        bf.pack(pady=14)
        tk.Button(bf, text="\u2714 Enregistrer", command=save, bg=ACCENT, fg=TXT,
                  relief=tk.FLAT, padx=16, pady=5, cursor="hand2").pack(
            side=tk.LEFT, padx=5)
        tk.Button(bf, text="Annuler", command=dlg.destroy, bg=CARD, fg=TXT,
                  relief=tk.FLAT, padx=16, pady=5, cursor="hand2").pack(
            side=tk.LEFT, padx=5)

        tk.Button(dlg,
                  text="\U0001f310 Obtenir une clé API gratuite sur TMDB \u2192",
                  command=lambda: webbrowser.open(
                      "https://www.themoviedb.org/settings/api"),
                  bg=BG, fg=ACCENT, relief=tk.FLAT, cursor="hand2",
                  font=("Helvetica", 9)).pack(pady=2)

    # ----------------------------------------------------------
    # UTILITAIRES
    # ----------------------------------------------------------
    def _set_status(self, text):
        self._status_lbl.config(text=text)


# ============================================================
# POINT D'ENTREE
# ============================================================
if __name__ == "__main__":
    root = tk.Tk()
    app = CineAvis(root)
    root.mainloop()
