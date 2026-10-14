import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/guide_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/code_badge.dart';
import '../../../../core/widgets/info_hint.dart';
import '../../../classification/domain/entities/classification.dart';
import '../../../classification/domain/entities/soil_unit.dart';
import '../../../classification/domain/services/cross_filter.dart';
import '../../../classification/presentation/widgets/classification_gate.dart';
import '../../../classification/presentation/widgets/unit_list_tile.dart';
import '../bloc/compare_cubit.dart';

class ComparePage extends StatelessWidget {
  const ComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ids = context.watch<CompareCubit>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparer'),
        actions: [
          const InfoHint(
            title: 'Comparer des sols',
            text:
                'Choisissez jusqu\'à 3 unités (de n\'importe quel niveau). '
                'Les valeurs partagées par tous les sols sont surlignées en '
                'vert : ce sont leurs points communs ; le reste montre ce qui '
                'les distingue.',
          ),
          if (ids.isNotEmpty)
            IconButton(
              tooltip: 'Vider',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => context.read<CompareCubit>().clear(),
            ),
          const GuideButton('comparer'),
          const LearningModeButton(),
        ],
      ),
      body: ClassificationGate(
        builder: (context, data) {
          final units = ids.map(data.unit).whereType<SoilUnit>().toList();
          return ContentWidth(
            maxWidth: 1100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final u in units)
                        InputChip(
                          avatar: CodeBadge(u.code),
                          label: Text(u.name),
                          onPressed: () => context.push('/unit/${u.id}'),
                          onDeleted:
                              () => context.read<CompareCubit>().remove(u.id),
                        ),
                      if (units.length < CompareCubit.maxItems)
                        ActionChip(
                          avatar: const Icon(Icons.add),
                          label: const Text('Ajouter un sol'),
                          onPressed: () => _pick(context, data),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child:
                      units.length < 2
                          ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Ajoutez au moins 2 sols pour les comparer.\n'
                                'Astuce : depuis une fiche, touchez ⇄.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                          : _CompareTable(data: data, units: units),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pick(BuildContext context, Classification data) async {
    final id = await showDialog<String>(
      context: context,
      builder: (_) => UnitPickerDialog(data: data),
    );
    if (id != null && context.mounted) {
      context.read<CompareCubit>().add(id);
    }
  }
}

class UnitPickerDialog extends StatefulWidget {
  final Classification data;
  const UnitPickerDialog({super.key, required this.data});

  @override
  State<UnitPickerDialog> createState() => _UnitPickerDialogState();
}

class _UnitPickerDialogState extends State<UnitPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = CrossFilter.apply(
      widget.data,
      selection: const {},
      levels:
          _query.isEmpty ? {SoilLevelId.classe, SoilLevelId.groupe} : const {},
      query: _query,
    );
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un sol',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder:
                    (context, i) => UnitListTile(
                      data: widget.data,
                      unit: results[i].unit,
                      showPath: true,
                      onTap:
                          () => Navigator.of(context).pop(results[i].unit.id),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareTable extends StatelessWidget {
  final Classification data;
  final List<SoilUnit> units;
  const _CompareTable({required this.data, required this.units});

  @override
  Widget build(BuildContext context) {
    final commonCount =
        data.criteria.where((c) {
          return _common(c.id).isNotEmpty;
        }).length;

    TableRow textRow(String label, String Function(SoilUnit) value) => TableRow(
      children: [_header(label), for (final u in units) _pad(Text(value(u)))],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$commonCount critère(s) sur ${data.criteria.length} '
            'partagent au moins une valeur commune.',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              defaultColumnWidth: const FixedColumnWidth(260),
              columnWidths: const {0: FixedColumnWidth(150)},
              border: TableBorder.all(color: Colors.black12),
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundColor,
                  ),
                  children: [
                    _header('Sol'),
                    for (final u in units)
                      _pad(
                        Row(
                          children: [
                            CodeBadge(u.code),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                data.fullName(u),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                textRow('Niveau', (u) => data.level(u.level).label),
                textRow('Classe', (u) {
                  final chain = data.ancestorsOf(u.id);
                  return chain.isEmpty ? u.name : chain.first.name;
                }),
                textRow('Profil type', (u) {
                  if (u.profile != null) return u.profile!;
                  for (final a in data.ancestorsOf(u.id).reversed) {
                    if (a.profile != null) return a.profile!;
                  }
                  return '—';
                }),
                for (final c in data.criteria)
                  TableRow(
                    children: [
                      _pad(
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                c.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            InfoHint(
                              title: c.label,
                              text: c.explanation,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                      for (final u in units)
                        _pad(
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              for (final v
                                  in u.criteria[c.id] ?? const <String>{})
                                _ValueTag(
                                  label: c.value(v)?.label ?? v,
                                  shared: _common(c.id).contains(v),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Set<String> _common(String criterion) {
    Set<String>? acc;
    for (final u in units) {
      final values = u.criteria[criterion] ?? const <String>{};
      acc = acc == null ? {...values} : acc.intersection(values);
    }
    return acc ?? const {};
  }

  Widget _header(String text) =>
      _pad(Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));

  Widget _pad(Widget child) =>
      Padding(padding: const EdgeInsets.all(8), child: child);
}

class _ValueTag extends StatelessWidget {
  final String label;
  final bool shared;
  const _ValueTag({required this.label, required this.shared});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:
            shared
                ? AppTheme.secondaryColor.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: shared ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
