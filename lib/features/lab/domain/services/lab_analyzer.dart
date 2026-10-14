import '../entities/lab.dart';

enum LabVerdict { match, near, contradiction }

/// Comparaison d'un paramètre mesuré avec la valeur attendue par un sol.
class LabElement {
  final LabParameter parameter;
  final Object measured;
  final LabExpectation expected;
  final LabVerdict verdict;

  const LabElement({
    required this.parameter,
    required this.measured,
    required this.expected,
    required this.verdict,
  });
}

class LabResult {
  final String target;

  /// Points obtenus, en demi-points (2 par unité de poids concordante).
  final int earnedHalfPoints;

  /// Poids des paramètres renseignés que ce sol décrit.
  final int consideredWeight;

  /// Poids de tous les paramètres renseignés.
  final int providedWeight;

  /// Poids de tous les paramètres décrits par le profil du sol.
  final int profileWeight;
  final int order;
  final List<LabElement> elements;

  const LabResult({
    required this.target,
    required this.earnedHalfPoints,
    required this.consideredWeight,
    required this.providedWeight,
    required this.profileWeight,
    required this.order,
    required this.elements,
  });

  double get earnedPoints => earnedHalfPoints / 2;
  double get agreement => earnedHalfPoints / (2 * consideredWeight);
  double get coverage => consideredWeight / providedWeight;
  double get completeness => consideredWeight / profileWeight;
  double get score => agreement * (0.6 + 0.4 * coverage);
  int get percent => (score * 100).round();
}

/// Moteur du Labo : compare les mesures aux profils attendus.
///
/// Pour chaque sol, un paramètre concordant vaut son poids, un paramètre
/// proche (dans la tolérance d'une plage) la moitié, une contradiction zéro.
/// Score = concordance × (0,6 + 0,4 × couverture).
class LabAnalyzer {
  static const _epsilon = 1e-9;

  static List<LabResult> analyze(LabData lab, Map<String, Object> measures) {
    final params = {for (final p in lab.parameters) p.id: p};
    final known = {
      for (final e in measures.entries)
        if (params.containsKey(e.key)) e.key: e.value,
    };
    final provided = known.keys.fold<int>(0, (s, k) => s + params[k]!.weight);
    if (provided == 0) return const [];

    final results = <LabResult>[];
    for (var i = 0; i < lab.profiles.length; i++) {
      final profile = lab.profiles[i];
      var profileWeight = 0;
      for (final k in profile.expect.keys) {
        profileWeight += params[k]?.weight ?? 0;
      }
      var considered = 0;
      var half = 0;
      final elements = <LabElement>[];
      for (final e in known.entries) {
        final expected = profile.expect[e.key];
        if (expected == null) continue;
        final p = params[e.key]!;
        considered += p.weight;
        final verdict = _verdict(p, expected, e.value);
        half += switch (verdict) {
          LabVerdict.match => 2 * p.weight,
          LabVerdict.near => p.weight,
          LabVerdict.contradiction => 0,
        };
        elements.add(
          LabElement(
            parameter: p,
            measured: e.value,
            expected: expected,
            verdict: verdict,
          ),
        );
      }
      if (considered == 0) continue;
      results.add(
        LabResult(
          target: profile.target,
          earnedHalfPoints: half,
          consideredWeight: considered,
          providedWeight: provided,
          profileWeight: profileWeight,
          order: i,
          elements: elements,
        ),
      );
    }
    results.sort((a, b) {
      if ((a.score - b.score).abs() > _epsilon) {
        return b.score.compareTo(a.score);
      }
      if ((a.completeness - b.completeness).abs() > _epsilon) {
        return b.completeness.compareTo(a.completeness);
      }
      return a.order.compareTo(b.order);
    });
    return results;
  }

  static LabVerdict _verdict(
    LabParameter p,
    LabExpectation expected,
    Object measured,
  ) {
    if (!expected.isRange) {
      return expected.values.contains(measured)
          ? LabVerdict.match
          : LabVerdict.contradiction;
    }
    final v = (measured as num).toDouble();
    final lo = expected.min!;
    final hi = expected.max!;
    final distance = v < lo ? lo - v : (v > hi ? v - hi : 0.0);
    if (distance == 0) return LabVerdict.match;
    if (distance <= p.tolerance + _epsilon) return LabVerdict.near;
    return LabVerdict.contradiction;
  }
}
