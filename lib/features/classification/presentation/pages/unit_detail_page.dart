import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/code_badge.dart';
import '../../../../core/widgets/info_hint.dart';
import '../../../comparison/presentation/bloc/compare_cubit.dart';
import '../../../explorer/presentation/bloc/explorer_cubit.dart';
import '../../domain/entities/classification.dart';
import '../../domain/entities/soil_unit.dart';
import '../bloc/classification_bloc.dart';
import '../widgets/classification_gate.dart';
import '../widgets/unit_list_tile.dart';

class UnitDetailPage extends StatefulWidget {
  final String unitId;
  const UnitDetailPage({super.key, required this.unitId});

  @override
  State<UnitDetailPage> createState() => _UnitDetailPageState();
}

class _UnitDetailPageState extends State<UnitDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ClassificationBloc>().add(VisitUnit(widget.unitId));
  }

  @override
  Widget build(BuildContext context) {
    return ClassificationGate(
      builder: (context, data) {
        final unit = data.unit(widget.unitId);
        if (unit == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Unité introuvable')),
          );
        }
        return _UnitDetailView(data: data, unit: unit);
      },
    );
  }
}

class _UnitDetailView extends StatelessWidget {
  final Classification data;
  final SoilUnit unit;
  const _UnitDetailView({required this.data, required this.unit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favorite = context.select<ClassificationBloc, bool>(
      (b) => b.state.isFavorite(unit.id),
    );
    final ancestors = data.ancestorsOf(unit.id);
    final children = data.childrenOf(unit.id);
    final level = data.level(unit.level);

    return Scaffold(
      appBar: AppBar(
        title: Text(unit.code),
        actions: [
          IconButton(
            tooltip: favorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
            icon: Icon(
              favorite ? Icons.star : Icons.star_border,
              color: favorite ? Colors.amber : null,
            ),
            onPressed:
                () => context.read<ClassificationBloc>().add(
                  ToggleFavorite(unit.id),
                ),
          ),
          IconButton(
            tooltip: 'Comparer',
            icon: const Icon(Icons.compare_arrows),
            onPressed: () => _addToCompare(context),
          ),
          IconButton(
            tooltip: 'Trouver des sols aux critères proches',
            icon: const Icon(Icons.hub_outlined),
            onPressed: () => _findSimilar(context),
          ),
          const LearningModeButton(),
        ],
      ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            if (ancestors.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final a in ancestors) ...[
                    ActionChip(
                      label: Text(
                        '${a.code} · ${a.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () => context.push('/unit/${a.id}'),
                    ),
                    const Icon(Icons.chevron_right, size: 16),
                  ],
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                CodeBadge(unit.code),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.fullName(unit),
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Chip(label: Text(level.label)),
                InfoHint(title: level.label, text: level.explanation),
              ],
            ),
            Text(unit.description, style: const TextStyle(height: 1.4)),
            if (unit.explanation != null) ...[
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: const Text('Pour comprendre'),
                  expandedAlignment: Alignment.centerLeft,
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Text(
                      unit.explanation!,
                      style: const TextStyle(height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
            if (unit.profile != null || unit.examples != null)
              Card(
                child: Column(
                  children: [
                    if (unit.profile != null)
                      ListTile(
                        leading: const Icon(Icons.layers_outlined),
                        title: const Text('Profil type'),
                        subtitle: Text(unit.profile!),
                        trailing: InfoHint(
                          title: 'Lire un profil',
                          text:
                              'Les lettres désignent les horizons du sol, '
                              'de la surface vers la profondeur.',
                          more: [
                            for (final g in data.glossary)
                              if (g.term.startsWith('Horizon') ||
                                  g.term.startsWith('Roche') ||
                                  g.term == 'Gley' ||
                                  g.term == 'Pseudogley')
                                InfoSection(g.term, g.definition),
                          ],
                        ),
                      ),
                    if (unit.examples != null)
                      ListTile(
                        leading: const Icon(Icons.place_outlined),
                        title: const Text('Exemples'),
                        subtitle: Text(unit.examples!),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Critères de croisement',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const InfoHint(
                  title: 'Critères de croisement',
                  text:
                      'Ces critères décrivent les conditions de formation '
                      'et l\'usage du sol. Ils sont hérités des niveaux '
                      'supérieurs puis précisés. Les valeurs en gras sont '
                      'propres à ce niveau. Touchez une valeur pour lire son '
                      'explication.',
                ),
              ],
            ),
            for (final c in data.criteria)
              if ((unit.criteria[c.id] ?? const {}).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              c.label,
                              style: theme.textTheme.labelLarge,
                            ),
                          ),
                          InfoHint(
                            title: c.label,
                            text: c.explanation,
                            size: 16,
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final v in unit.criteria[c.id]!)
                            if (c.value(v) case final value?)
                              ActionChip(
                                label: Text(
                                  value.label,
                                  style: TextStyle(
                                    fontWeight:
                                        (unit.ownCriteria[c.id] ?? const [])
                                                .contains(v)
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                                onPressed:
                                    () => showInfoSheet(
                                      context,
                                      title: '${c.label} : ${value.label}',
                                      text: value.explanation,
                                    ),
                              ),
                        ],
                      ),
                    ],
                  ),
                ),
            if (children.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '${data.level(children.first.level).label}s (${children.length})',
                style: theme.textTheme.titleMedium,
              ),
              Card(
                child: Column(
                  children: [
                    for (final c in children) UnitListTile(data: data, unit: c),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addToCompare(BuildContext context) {
    final ok = context.read<CompareCubit>().add(unit.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? '${unit.code} ajouté à la comparaison'
                : 'Maximum ${CompareCubit.maxItems} sols à comparer',
          ),
          action: SnackBarAction(
            label: 'Voir',
            onPressed: () => context.go('/compare'),
          ),
        ),
      );
  }

  void _findSimilar(BuildContext context) {
    final processes = unit.criteria['processus'] ?? const <String>{};
    final climates = unit.criteria['climat'] ?? const <String>{};
    context.read<ExplorerCubit>().setSelection(
      {
        if (processes.isNotEmpty) 'processus': {...processes},
        if (climates.isNotEmpty) 'climat': {...climates},
      },
      levels: {unit.level},
    );
    context.go('/explorer');
  }
}
