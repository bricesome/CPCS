import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/classification/domain/entities/classification.dart';
import '../../features/classification/presentation/bloc/classification_bloc.dart';
import 'info_hint.dart';

/// Bouton « ? » : ouvre la rubrique du guide correspondant à l'écran.
class GuideButton extends StatelessWidget {
  final String sectionId;
  const GuideButton(this.sectionId, {super.key});

  @override
  Widget build(BuildContext context) {
    final section = context.select<ClassificationBloc, GuideSection?>(
      (b) => b.state.data?.guideSection(sectionId),
    );
    if (section == null) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'Guide : ${section.title}',
      icon: const Icon(Icons.help_outline),
      onPressed: () => showGuideSheet(context, section),
    );
  }
}

String guideSteps(GuideSection section) => [
  for (var i = 0; i < section.steps.length; i++)
    '${i + 1}. ${section.steps[i]}',
].join('\n');

Future<void> showGuideSheet(BuildContext context, GuideSection section) {
  return showInfoSheet(
    context,
    title: 'Guide · ${section.title}',
    text: '${section.what}\n\n${guideSteps(section)}',
    more: [InfoSection('Exemple', section.example)],
  );
}
