# CPCS

Application Flutter multiplateforme (Android, iOS, Web, Windows, Linux, macOS) pour consulter et apprendre la **classification française des sols CPCS 1967** (Aubert et al.).

## Fonctionnalités

- **Classification** : arbre classe › sous-classe › groupe › sous-groupe (12 classes, 391 unités), recherche sans accents, favoris et récents.
- **Fiche d'un sol** : fil d'Ariane, profil type, exemples, critères hérités ou propres au niveau, sous-unités.
- **Croisement** : filtres multicritères (ET entre critères, OU entre valeurs) sur 8 critères : processus, climat, matériau, topographie, drainage, complexe absorbant, végétation, aptitude. Une **matrice** croise deux critères.
- **Comparer** : jusqu'à 3 sols côte à côte, avec les points communs mis en évidence.
- **Clé de détermination** : questions successives pour trouver la classe d'un sol.
- **Apprendre** : niveaux, critères expliqués, glossaire.
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

## Lancer

```bash
flutter pub get
flutter run -d chrome      # ou windows, android, ...
flutter test
flutter analyze
```
