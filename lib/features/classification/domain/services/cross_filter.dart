import '../../../../core/utils/text_normalize.dart';
import '../entities/classification.dart';
import '../entities/soil_unit.dart';

/// Valeurs « joker » : l'unité est compatible avec toute valeur de la facette.
const Map<String, String> wildcardValues = {
  'topographie': 'toutes',
  'climat': 'azonal',
  'materiau': 'divers',
  'complexe': 'variable',
  'vegetation': 'variee',
};

class CrossMatch {
  final SoilUnit unit;

  /// Facettes où une valeur choisie est caractéristique de l'unité.
  final int exact;

  /// Facettes satisfaites seulement grâce à une valeur joker.
  final int compatible;

  const CrossMatch(this.unit, this.exact, this.compatible);

  bool get isExact => compatible == 0;
}

class CrossFilter {
  const CrossFilter._();

  /// Croise les sélections : ET entre facettes, OU entre valeurs d'une facette.
  static List<CrossMatch> apply(
    Classification data, {
    required Map<String, Set<String>> selection,
    Set<SoilLevelId> levels = const {},
    String query = '',
  }) {
    final active = {
      for (final e in selection.entries)
        if (e.value.isNotEmpty) e.key: e.value,
    };
    final q = normalizeText(query.trim());
    final results = <CrossMatch>[];

    for (final unit in data.units) {
      if (levels.isNotEmpty && !levels.contains(unit.level)) continue;
      if (q.isNotEmpty && !matchesQuery(data, unit, q)) continue;

      var exact = 0;
      var compatible = 0;
      var ok = true;
      for (final entry in active.entries) {
        final values = unit.criteria[entry.key] ?? const <String>{};
        if (values.any(entry.value.contains)) {
          exact++;
        } else if (values.contains(wildcardValues[entry.key])) {
          compatible++;
        } else {
          ok = false;
          break;
        }
      }
      if (ok) results.add(CrossMatch(unit, exact, compatible));
    }

    results.sort((a, b) {
      final byCompat = a.compatible.compareTo(b.compatible);
      if (byCompat != 0) return byCompat;
      return a.unit.order.compareTo(b.unit.order);
    });
    return results;
  }

  static bool matchesQuery(Classification data, SoilUnit unit, String q) {
    final hay = normalizeText(
      '${unit.code} ${data.fullName(unit)} ${unit.description} '
      '${unit.explanation ?? ''} ${unit.examples ?? ''}',
    );
    return q.split(RegExp(r'\s+')).every(hay.contains);
  }

  /// Matrice de croisement de deux facettes : nombre d'unités par couple.
  static Map<String, Map<String, int>> matrix(
    Classification data, {
    required String rowCriterion,
    required String columnCriterion,
    required SoilLevelId level,
  }) {
    final result = <String, Map<String, int>>{};
    for (final unit in data.units) {
      if (unit.level != level) continue;
      final rows = unit.criteria[rowCriterion] ?? const <String>{};
      final cols = unit.criteria[columnCriterion] ?? const <String>{};
      for (final r in rows) {
        for (final c in cols) {
          final line = result.putIfAbsent(r, () => {});
          line[c] = (line[c] ?? 0) + 1;
        }
      }
    }
    return result;
  }
}
