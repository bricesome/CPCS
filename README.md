# CPCS — Commission de Pédologie et de Cartographie des Sols

- Auteur : **Professeur EDMOND HIEN**
- Contributeur : **NANAWENDIN YAMEOGO**
- Concepteur : **NIBENAON SOME**

Application Flutter multiplateforme (Android, iOS, Web, Windows, Linux, macOS) pour consulter et apprendre la **classification française des sols CPCS 1967** (Aubert et al.).

## Télécharger l'application Android

Lien direct : https://github.com/bricesome/CPCS/raw/main/releases/CPCS.apk

L'APK est dans [`releases/CPCS.apk`](releases/CPCS.apk) : ouvrez le fichier sur GitHub, cliquez sur **Download** (ou « View raw »), puis ouvrez-le sur le téléphone et autorisez l'installation depuis une source inconnue. Android 5 ou plus récent.

## Fonctionnalités

- **Classification** : arbre classe › sous-classe › groupe › sous-groupe (12 classes, 396 unités), recherche sans accents, favoris et récents.
- **Fiche d'un sol** : fil d'Ariane, profil type, exemples, critères hérités ou propres au niveau, sous-unités.
- **Croisement** : filtres multicritères (ET entre critères, OU entre valeurs) sur 8 critères : processus, climat, matériau, topographie, drainage, complexe absorbant, végétation, aptitude. Une **matrice** croise deux critères.
- **Comparer** : jusqu'à 3 sols côte à côte, avec les points communs mis en évidence.
- **Clé de détermination** : questions successives pour trouver la classe d'un sol.
- **Labo** : on saisit des observations et mesures de terrain (13 paramètres : horizons, couleur, texture, structure, effervescence, excès d'eau, pente, climat, végétation, profondeur, pH, matière organique, salinité). L'application calcule les sous-classes les plus probables, avec un pourcentage, les éléments concordants (✓), proches (≈) et contradictoires (✗). Des échantillons d'exemple sont fournis.
- **Guide** : onglet Apprendre › Guide, et bouton « ? » en haut de chaque écran : explication simple de chaque fonction, avec un exemple.
- **Apprendre** : guide, niveaux, critères expliqués, glossaire.
- **Mode apprentissage** : les icônes ⓘ ouvrent une explication courte dans un volet. Le bouton chapeau les masque pour passer en mode lecture.

## Architecture

Elle reprend celle du projet `billing` : Clean Architecture découpée par fonctionnalité (`data` / `domain` / `presentation`).

| Rôle | Outil |
| --- | --- |
| État | `flutter_bloc` / `bloc` |
| Injection de dépendances | `get_it` (`lib/core/service_locator.dart`) |
| Navigation | `go_router` (`lib/config/routes/app_routes.dart`) |
| Stockage local (favoris, préférences) | `hive` / `hive_flutter` |
| Résultats des cas d'utilisation | `fpdart` (`Either<Failure, T>`) |

```
lib/
├── config/routes/
├── core/            (data, error, theme, usecase, utils, widgets)
└── features/
    ├── classification/  (data, domain, presentation)
    ├── explorer/        (croisement + matrice)
    ├── comparison/
    ├── determination/   (clé)
    └── learning/
```

## Données

Les données de classification ne sont pas dans le code Dart : elles sont dans `assets/data/cpcs_1967.json`. Ce fichier contient les niveaux, les critères et leurs explications, les unités, la clé et le glossaire.

Il est généré à partir des scripts Python de `tool/dataset/` :

```bash
python3 tool/dataset/build.py
```

Le script vérifie que chaque valeur de critère existe et que chaque identifiant est unique. Pour corriger ou compléter la classification, modifiez `tree.py` (hiérarchie), `modifiers.py` (qualificatifs de sous-groupes), `facets.py` (critères) ou `key_gloss.py` (clé et glossaire), puis relancez le script.

> Le jeu de données a été reconstitué pour l'apprentissage. Il reste à le vérifier et à le compléter avec le document source.

## Calcul du Labo

Chaque sous-classe a un **profil attendu** (`tool/dataset/lab.py`) : valeurs ou plages typiques des paramètres. Le profil d'une classe est hérité par ses sous-classes, qui peuvent le préciser. Chaque paramètre a un **poids** (3 = déterminant, 1 = indice secondaire).

Pour chaque sous-classe, seuls les paramètres renseignés **et** décrits par son profil comptent :

- valeur dans la plage ou parmi les choix attendus : tout le poids ;
- valeur numérique hors plage mais dans la tolérance (ex. pH ± 0,3) : la moitié du poids ;
- sinon : 0 (contradiction).

```
concordance = points obtenus / points possibles
couverture  = poids des paramètres décrits par ce sol / poids de tous les paramètres renseignés
score       = concordance × (0,6 + 0,4 × couverture)
```

À score égal, passe devant le sol dont le profil est le mieux couvert par les mesures, puis l'ordre de la classification. Le calcul est vérifié par des tests (`test/features/lab_analyzer_test.dart`) : calculs à la main, bornes et tolérances, chaque échantillon d'exemple et chaque profil type reconnus à 100 %. `build.py` refait les mêmes contrôles en Python et refuse un profil incohérent.

> Le Labo donne une **estimation pédagogique**, pas un diagnostic : les profils sont des simplifications. Seule une description complète du profil et des analyses de laboratoire permettent de classer un sol avec certitude.

## Modifier le contenu des informations

Tout le contenu affiché (classes, groupes, explications, critères, clé, glossaire) se modifie **sans toucher au code Dart**, dans les fichiers Python de `tool/dataset/`. Le script `build.py` les assemble ensuite dans `assets/data/cpcs_1967.json`, que l'application lit.

| Ce que vous voulez changer | Fichier |
| --- | --- |
| Classes, sous-classes, groupes, sous-groupes, descriptions, explications, profils, exemples | `tree.py` |
| Qualificatifs de sous-groupes (modal, hydromorphe, induré…) et leur explication | `modifiers.py` |
| Critères de croisement (processus, climat, matériau…) et leurs valeurs | `facets.py` |
| Questions de la clé de détermination, glossaire | `key_gloss.py` |
| Paramètres du Labo, profils attendus, échantillons d'exemple | `lab.py` |
| Textes du Guide d'utilisation | `guide.py` |
| Titre, édition, crédits, note de source (onglet « À propos ») | `build.py` (bloc `meta`) |

### 1. Modifier une unité (`tree.py`)

Chaque unité est écrite avec `N(...)` :

```python
N("Nom de l'unité",
  "Description courte (affichée sur la fiche).",
  "Explication pédagogique (affichée derrière l'icône ⓘ).",
  f=dict(climat=["tropical_humide"], drainage=["bon"]),  # critères de croisement
  profil="A B C",                                          # profil type
  ex="Exemple de localisation.",                           # exemples
  sg=["modal", "hydromorphe"],                             # sous-groupes (ids de modifiers.py)
  kids=[ ... ])                                            # unités du niveau inférieur
```

- Le niveau dépend de la profondeur : une entrée de `TREE` est une **classe**, ses `kids` sont des **sous-classes**, puis des **groupes**. Les **sous-groupes** sont générés à partir de `sg`.
- Les codes (`X.1.2`…) sont calculés automatiquement selon l'ordre des éléments : pour renuméroter, il suffit de déplacer les blocs.
- Les critères `f=` sont hérités par les unités enfants ; un enfant peut les remplacer en redéfinissant le même critère.
- Les valeurs de `f=` doivent exister dans `facets.py`, et les valeurs de `sg=` dans `modifiers.py`.

### 2. Ajouter un qualificatif de sous-groupe (`modifiers.py`)

```python
"induré": ("Induré", "Un horizon est durci (cuirasse, carapace).", {"drainage": ["temporaire"]}),
#  id          libellé     explication                              critères imposés (facultatif)
```

### 3. Ajouter une valeur de critère (`facets.py`)

Dans le critère voulu, ajoutez `"id_valeur": ("Libellé", "Explication")`.

### 4. Clé et glossaire (`key_gloss.py`)

- Une question : `dict(id="q9", q="Question ?", aide="Indice", opts=[("Réponse", "q10"), ("Autre réponse", "r:XI")])`. Une option pointe vers une autre question (`q10`) ou vers une classe résultat (`r:` + numéro romain de la classe, par exemple `r:XI`).
- Un terme du glossaire : `("Terme", "Définition")`.

### 5. Labo (`lab.py`) et Guide (`guide.py`)

- Un paramètre : `dict(id="ph", label="pH (eau)", kind="range", weight=2, min=3.0, max=10.5, step=0.1, unit="", tol=0.3, expl="...")`, ou `kind="choice"` avec `options=[("id", "Libellé", "Explication"), ...]`.
- Un profil (dans `PROFILES`) : `"III.1": dict(pente=["depression", "plat"], ph=(6.5, 8.5))` : liste de choix acceptés, ou plage `(min, max)`. Une sous-classe hérite du profil de sa classe.
- Un échantillon d'exemple (dans `PRESETS`) : `("Nom", dict(ph=7.8, couleur="noir"), "III.1")` ; `build.py` vérifie qu'il donne bien la sous-classe annoncée.
- Une rubrique du guide : `dict(id=..., title=..., what=..., steps=[...], example=...)`.

### 6. Régénérer et vérifier

```bash
python3 tool/dataset/build.py   # écrit assets/data/cpcs_1967.json et signale les erreurs
flutter test                    # vérifie que les données restent cohérentes
flutter run -d chrome           # pour voir le résultat
```

Si une valeur n'existe pas ou si un identifiant est en double, `build.py` s'arrête en indiquant l'élément fautif.

### 7. Regénérer l'APK

```bash
flutter build apk --release
# puis copier build/app/outputs/flutter-apk/app-release.apk vers releases/CPCS.apk
```

## Lancer

```bash
flutter pub get
flutter run -d chrome      # ou windows, android, ...
flutter test
flutter analyze
```

## Crédits

- Auteur : **Professeur EDMOND HIEN**
- Contributeur : **NANAWENDIN YAMEOGO**
- Concepteur : **NIBENAON SOME**
