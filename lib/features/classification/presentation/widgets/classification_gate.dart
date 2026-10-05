import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/classification.dart';
import '../bloc/classification_bloc.dart';

/// Affiche le contenu une fois le référentiel chargé.
class ClassificationGate extends StatelessWidget {
  final Widget Function(BuildContext context, Classification data) builder;

  const ClassificationGate({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassificationBloc, ClassificationState>(
      buildWhen: (a, b) => a.status != b.status || a.data != b.data,
      builder: (context, state) {
        final data = state.data;
        if (state.status == ClassificationStatus.error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    state.error ?? 'Erreur inconnue',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed:
                        () => context.read<ClassificationBloc>().add(
                          LoadClassification(),
                        ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return builder(context, data);
      },
    );
  }
}

/// Limite la largeur du contenu sur grand écran (web / desktop).
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ContentWidth({super.key, required this.child, this.maxWidth = 920});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class LearningModeButton extends StatelessWidget {
  const LearningModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final on = context.select<ClassificationBloc, bool>(
      (b) => b.state.learningMode,
    );
    return IconButton(
      tooltip:
          on
              ? 'Masquer les indicateurs d\'explication'
              : 'Afficher les indicateurs d\'explication',
      icon: Icon(on ? Icons.school : Icons.school_outlined),
      onPressed: () {
        context.read<ClassificationBloc>().add(ToggleLearningMode());
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(
                on
                    ? 'Mode lecture : explications ⓘ masquées'
                    : 'Mode apprentissage : explications ⓘ affichées',
              ),
            ),
          );
      },
    );
  }
}
