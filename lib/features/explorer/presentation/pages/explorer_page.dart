import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/guide_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/info_hint.dart';
import '../../../classification/domain/entities/classification.dart';
import '../../../classification/domain/entities/soil_unit.dart';
import '../../../classification/domain/services/cross_filter.dart';
import '../../../classification/presentation/widgets/classification_gate.dart';
import '../../../classification/presentation/widgets/unit_list_tile.dart';
import '../bloc/explorer_cubit.dart';

class ExplorerPage extends StatelessWidget {
  const ExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExplorerCubit>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Croisement'),
        actions: [
          const InfoHint(
            title: 'Croiser les critères',
            text:
                'Choisissez une ou plusieurs valeurs dans chaque critère. '
                'Les valeurs d\'un même critère s\'additionnent (OU) ; les '
                'critères différents se combinent (ET). La matrice montre '
                'combien de sols existent pour chaque couple de valeurs.',
            more: [
              InfoSection(
                'Résultats « compatibles »',
                'Un sol azonal, présent sur tous reliefs ou sur matériaux '
                    'divers reste compatible avec votre choix : il est listé '
                    'après les correspondances exactes, avec un indicateur ≈.',
              ),
            ],
          ),
          if (state.activeCount > 0)
            IconButton(
              tooltip: 'Effacer les filtres',
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () => context.read<ExplorerCubit>().clear(),
            ),
          const GuideButton('croisement'),
          const LearningModeButton(),
        ],
      ),
      body: ClassificationGate(
        builder:
            (context, data) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SegmentedButton<ExplorerMode>(
                    segments: const [
                      ButtonSegment(
                        value: ExplorerMode.filters,
                        icon: Icon(Icons.filter_list),
                        label: Text('Filtres'),
                      ),
                      ButtonSegment(
                        value: ExplorerMode.matrix,
                        icon: Icon(Icons.grid_on),
                        label: Text('Matrice'),
                      ),
                    ],
                    selected: {state.mode},
                    onSelectionChanged:
                        (s) => context.read<ExplorerCubit>().setMode(s.first),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child:
                      state.mode == ExplorerMode.filters
                          ? _FiltersView(data: data, state: state)
                          : _MatrixView(data: data, state: state),
                ),
              ],
            ),
      ),
    );
  }
}

class _FiltersView extends StatelessWidget {
  final Classification data;
  final ExplorerState state;
  const _FiltersView({required this.data, required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final results = _Results(data: data, state: state);
        if (constraints.maxWidth >= 840) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 360, child: FilterPanel(data: data)),
              const VerticalDivider(width: 1),
              Expanded(child: results),
            ],
          );
        }
        return Column(
          children: [
            _ActiveFiltersBar(data: data, state: state),
            Expanded(child: results),
          ],
        );
      },
    );
  }
}

class _ActiveFiltersBar extends StatelessWidget {
  final Classification data;
  final ExplorerState state;
  const _ActiveFiltersBar({required this.data, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExplorerCubit>();
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilledButton.tonalIcon(
            icon: const Icon(Icons.tune),
            label: Text('Filtres (${state.activeCount})'),
            onPressed:
                () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder:
                      (_) => DraggableScrollableSheet(
                        expand: false,
                        initialChildSize: 0.8,
                        maxChildSize: 0.95,
                        builder:
                            (_, controller) =>
                                FilterPanel(data: data, controller: controller),
                      ),
                ),
          ),
          const SizedBox(width: 8),
          for (final e in state.selection.entries)
            for (final v in e.value)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InputChip(
                  label: Text(data.criterion(e.key)?.value(v)?.label ?? v),
                  onDeleted: () => cubit.toggleValue(e.key, v),
                ),
              ),
        ],
      ),
    );
  }
}

/// Panneau de sélection : recherche, niveaux et critères.
class FilterPanel extends StatefulWidget {
  final Classification data;
  final ScrollController? controller;
  const FilterPanel({super.key, required this.data, this.controller});

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late final TextEditingController _query;

  @override
  void initState() {
    super.initState();
    _query = TextEditingController(
      text: context.read<ExplorerCubit>().state.query,
    );
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final state = context.watch<ExplorerCubit>().state;
    final cubit = context.read<ExplorerCubit>();
    return ListView(
      controller: widget.controller,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      children: [
        TextField(
          controller: _query,
          decoration: const InputDecoration(
            hintText: 'Mot-clé (optionnel)',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: cubit.setQuery,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('Niveaux', style: Theme.of(context).textTheme.labelLarge),
            InfoHint(
              title: 'Niveau hiérarchique',
              text:
                  'Limitez les résultats à un ou plusieurs niveaux. Sans '
                  'sélection, tous les niveaux sont affichés.',
              more: [
                for (final l in data.levels)
                  InfoSection(l.label, l.explanation),
              ],
              size: 16,
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          children: [
            for (final l in data.levels)
              FilterChip(
                label: Text(l.label),
                selected: state.levels.contains(l.id),
                onSelected: (_) => cubit.toggleLevel(l.id),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (final c in data.criteria)
          ExpansionTile(
            key: PageStorageKey('crit-${c.id}'),
            tilePadding: EdgeInsets.zero,
            initiallyExpanded: (state.selection[c.id] ?? const {}).isNotEmpty,
            title: Row(
              children: [
                Flexible(child: Text(c.label)),
                InfoHint(
                  title: c.label,
                  text: c.explanation,
                  more: [
                    for (final v in c.values)
                      InfoSection(v.label, v.explanation),
                  ],
                  size: 16,
                ),
                if ((state.selection[c.id] ?? const {}).isNotEmpty)
                  Badge(label: Text('${state.selection[c.id]!.length}')),
              ],
            ),
            expandedAlignment: Alignment.centerLeft,
            childrenPadding: const EdgeInsets.only(bottom: 8),
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final v in c.values)
                    FilterChip(
                      label: Text(v.label),
                      tooltip: v.explanation,
                      selected: state.isSelected(c.id, v.id),
                      onSelected: (_) => cubit.toggleValue(c.id, v.id),
                    ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  final Classification data;
  final ExplorerState state;
  const _Results({required this.data, required this.state});

  @override
  Widget build(BuildContext context) {
    final matches = CrossFilter.apply(
      data,
      selection: state.selection,
      levels: state.levels,
      query: state.query,
    );
    final exact = matches.where((m) => m.isExact).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(
            '${matches.length} sol(s) · $exact correspondance(s) exacte(s)',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Expanded(
          child:
              matches.isEmpty
                  ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Aucun sol ne réunit tous ces critères.\n'
                        'Essayez de retirer une valeur.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  : ListView.builder(
                    itemCount: matches.length,
                    itemBuilder: (context, i) {
                      final m = matches[i];
                      return UnitListTile(
                        data: data,
                        unit: m.unit,
                        showPath: true,
                        trailing:
                            m.isExact
                                ? null
                                : const Tooltip(
                                  message: 'Compatible (valeur générale)',
                                  child: Text(
                                    '≈',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

class _MatrixView extends StatelessWidget {
  final Classification data;
  final ExplorerState state;
  const _MatrixView({required this.data, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExplorerCubit>();
    final row = data.criterion(state.rowCriterion)!;
    final col = data.criterion(state.columnCriterion)!;
    final matrix = CrossFilter.matrix(
      data,
      rowCriterion: row.id,
      columnCriterion: col.id,
      level: state.matrixLevel,
    );
    final rows = row.values.where((v) => matrix.containsKey(v.id)).toList();
    final cols =
        col.values
            .where((v) => matrix.values.any((line) => line.containsKey(v.id)))
            .toList();
    var max = 1;
    for (final line in matrix.values) {
      for (final n in line.values) {
        if (n > max) max = n;
      }
    }

    DropdownButton<String> criterionPicker(
      String value,
      ValueChanged<String> onChanged,
    ) {
      return DropdownButton<String>(
        value: value,
        isDense: true,
        items: [
          for (final c in data.criteria)
            DropdownMenuItem(value: c.id, child: Text(c.label)),
        ],
        onChanged: (v) => v == null ? null : onChanged(v),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Lignes :'),
              criterionPicker(row.id, (v) => cubit.setMatrix(row: v)),
              const Text('Colonnes :'),
              criterionPicker(col.id, (v) => cubit.setMatrix(column: v)),
              const Text('Niveau :'),
              DropdownButton<SoilLevelId>(
                value: state.matrixLevel,
                isDense: true,
                items: [
                  for (final l in data.levels)
                    DropdownMenuItem(value: l.id, child: Text(l.label)),
                ],
                onChanged: (v) => v == null ? null : cubit.setMatrix(level: v),
              ),
              const InfoHint(
                title: 'Lire la matrice',
                text:
                    'Chaque case indique le nombre de sols qui associent '
                    'la valeur de la ligne et celle de la colonne. Plus la '
                    'case est foncée, plus le croisement est fréquent. '
                    'Touchez une case pour afficher ces sols.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(92),
                columnWidths: const {0: FixedColumnWidth(170)},
                border: TableBorder.all(color: Colors.black12),
                children: [
                  TableRow(
                    children: [
                      _cell(
                        Text(
                          '${row.label} \\ ${col.label}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      for (final c in cols)
                        _cell(
                          Text(
                            c.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  for (final r in rows)
                    TableRow(
                      children: [
                        _cell(
                          Text(
                            r.label,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        for (final c in cols)
                          _countCell(
                            context,
                            matrix[r.id]?[c.id] ?? 0,
                            max,
                            () {
                              cubit.setSelection(
                                row.id == col.id
                                    ? {
                                      row.id: {r.id, c.id},
                                    }
                                    : {
                                      row.id: {r.id},
                                      col.id: {c.id},
                                    },
                                levels: {state.matrixLevel},
                              );
                            },
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cell(Widget child) =>
      Padding(padding: const EdgeInsets.all(6), child: child);

  Widget _countCell(
    BuildContext context,
    int count,
    int max,
    VoidCallback onTap,
  ) {
    if (count == 0) return _cell(const Text('·', textAlign: TextAlign.center));
    final t = count / max;
    final color =
        Color.lerp(
          AppTheme.primaryColor.withValues(alpha: 0.12),
          AppTheme.primaryColor,
          t,
        )!;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: color,
        padding: const EdgeInsets.all(8),
        child: Text(
          '$count',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: t > 0.5 ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
