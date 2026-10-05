import 'package:equatable/equatable.dart';

import '../../domain/entities/classification.dart';

enum ClassificationStatus { initial, loading, loaded, error }

class ClassificationState extends Equatable {
  final ClassificationStatus status;
  final Classification? data;
  final List<String> favorites;
  final List<String> recents;
  final bool learningMode;
  final String? error;

  const ClassificationState({
    this.status = ClassificationStatus.initial,
    this.data,
    this.favorites = const [],
    this.recents = const [],
    this.learningMode = true,
    this.error,
  });

  bool isFavorite(String id) => favorites.contains(id);

  ClassificationState copyWith({
    ClassificationStatus? status,
    Classification? data,
    List<String>? favorites,
    List<String>? recents,
    bool? learningMode,
    String? error,
  }) {
    return ClassificationState(
      status: status ?? this.status,
      data: data ?? this.data,
      favorites: favorites ?? this.favorites,
      recents: recents ?? this.recents,
      learningMode: learningMode ?? this.learningMode,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    data?.units.length,
    favorites,
    recents,
    learningMode,
    error,
  ];
}
