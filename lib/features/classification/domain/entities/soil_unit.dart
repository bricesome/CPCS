import 'package:equatable/equatable.dart';

enum SoilLevelId { classe, sousClasse, groupe, sousGroupe }

SoilLevelId soilLevelFromJson(String raw) {
  switch (raw) {
    case 'classe':
      return SoilLevelId.classe;
    case 'sous_classe':
      return SoilLevelId.sousClasse;
    case 'groupe':
      return SoilLevelId.groupe;
    case 'sous_groupe':
      return SoilLevelId.sousGroupe;
  }
  throw FormatException('Niveau inconnu : $raw');
}

class SoilLevel extends Equatable {
  final SoilLevelId id;
  final String label;
  final String explanation;

  const SoilLevel({
    required this.id,
    required this.label,
    required this.explanation,
  });

  @override
  List<Object?> get props => [id];
}

/// Unité de la hiérarchie CPCS : classe, sous-classe, groupe ou sous-groupe.
class SoilUnit extends Equatable {
  final String id;
  final String code;
  final SoilLevelId level;
  final String name;
  final String description;
  final String? parentId;
  final int order;
  final String? explanation;
  final String? profile;
  final String? examples;

  /// Critères déclarés sur l'unité elle-même.
  final Map<String, List<String>> ownCriteria;

  /// Critères hérités des parents, surchargés par l'unité.
  final Map<String, Set<String>> criteria;

  const SoilUnit({
    required this.id,
    required this.code,
    required this.level,
    required this.name,
    required this.description,
    required this.parentId,
    required this.order,
    required this.ownCriteria,
    required this.criteria,
    this.explanation,
    this.profile,
    this.examples,
  });

  @override
  List<Object?> get props => [id];
}
