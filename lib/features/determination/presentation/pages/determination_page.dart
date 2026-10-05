import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/code_badge.dart';
import '../../../../core/widgets/info_hint.dart';
import '../../../classification/domain/entities/classification.dart';
import '../../../classification/presentation/widgets/classification_gate.dart';
import '../bloc/determination_cubit.dart';

class DeterminationPage extends StatelessWidget {
  const DeterminationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clé de détermination'),
        actions: const [
          InfoHint(
            title: 'Comment utiliser la clé ?',
            text:
                'Répondez aux questions en observant votre profil de sol '
                '(fosse ou tarière). Chaque réponse oriente vers la question '
                'suivante, jusqu\'à la classe la plus probable. Ouvrez ensuite '
                'la fiche pour préciser sous-classe, groupe et sous-groupe.',
          ),
          LearningModeButton(),
        ],
      ),
      body: ClassificationGate(
        builder:
            (context, data) => BlocProvider(
              create:
                  (_) => DeterminationCubit(
                    firstQuestionId: data.keyQuestions.first.id,
                  ),
              child: _KeyView(data: data),
            ),
      ),
    );
  }
}

class _KeyView extends StatelessWidget {
  final Classification data;
  const _KeyView({required this.data});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DeterminationCubit>().state;
    final cubit = context.read<DeterminationCubit>();
    final question =
        state.currentQuestionId == null
            ? null
            : data.keyQuestion(state.currentQuestionId!);
    final result = state.resultId == null ? null : data.unit(state.resultId!);
    final theme = Theme.of(context);

    return ContentWidth(
      maxWidth: 720,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          if (state.history.isNotEmpty)
            Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                leading: const Icon(Icons.route_outlined),
                title: Text('Parcours (${state.history.length} réponse(s))'),
                children: [
                  for (final step in state.history)
                    ListTile(
                      dense: true,
                      title: Text(
                        data.keyQuestion(step.questionId)?.question ?? '',
                      ),
                      subtitle: Text('→ ${step.answer}'),
                    ),
                ],
              ),
            ),
          if (question != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Question ${state.history.length + 1}',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            question.question,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        InfoHint(
                          title: 'Aide à l\'observation',
                          text: question.help,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    for (final o in question.options)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.all(14),
                          ),
                          onPressed: () => cubit.answer(question, o),
                          child: Text(o.label),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (result != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Classe la plus probable',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CodeBadge(result.code),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result.name,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(result.description),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          icon: const Icon(Icons.description_outlined),
                          label: const Text('Voir la fiche'),
                          onPressed: () => context.push('/unit/${result.id}'),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Recommencer'),
                          onPressed: cubit.restart,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (state.history.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Question précédente'),
                  onPressed: cubit.back,
                ),
              const Spacer(),
              if (state.history.isNotEmpty && result == null)
                TextButton(
                  onPressed: cubit.restart,
                  child: const Text('Recommencer'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Clé simplifiée à but pédagogique : la détermination définitive '
            'repose sur la description complète du profil et les analyses '
            'de laboratoire.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
