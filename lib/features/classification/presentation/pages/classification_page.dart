import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/code_badge.dart';
import '../../../../core/widgets/info_hint.dart';
import '../../domain/entities/classification.dart';
import '../../domain/entities/soil_unit.dart';
import '../../domain/services/cross_filter.dart';
import '../bloc/classification_bloc.dart';
import '../widgets/classification_gate.dart';
import '../widgets/unit_list_tile.dart';

class ClassificationPage extends StatefulWidget {
  const ClassificationPage({super.key});

  @override
  State<ClassificationPage> createState() => _ClassificationPageState();
}

class _ClassificationPageState extends State<ClassificationPage> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CPCS'),
        actions: const [LearningModeButton()],
      ),
      body: ClassificationGate(
        builder:
            (context, data) => ContentWidth(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un sol (ex. vertisol, gley, sahel)',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          _query.isEmpty
                              ? null
                              : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _search.clear();
                                  setState(() => _query = '');
                                },
                              ),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 12),
                  if (_query.trim().isNotEmpty)
                    ..._searchResults(data)
                  else ...[
                    _HierarchyLegend(data: data),
                    _Shortcuts(data: data),
                    const SizedBox(height: 8),
                    for (final root in data.roots)
                      _UnitNode(data: data, unit: root),
                  ],
                ],
              ),
            ),
      ),
    );
  }

  List<Widget> _searchResults(Classification data) {
    final results = CrossFilter.apply(data, selection: const {}, query: _query);
    if (results.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Aucun résultat')),
        ),
      ];
    }
    return [
      Text(
        '${results.length} résultat(s)',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      for (final m in results.take(150))
        UnitListTile(data: data, unit: m.unit, showPath: true),
    ];
  }
}

class _HierarchyLegend extends StatelessWidget {
  final Classification data;
  const _HierarchyLegend({required this.data});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Row(
      children: [
        Expanded(
          child: Text(
            data.levels.map((l) => l.label).join('  ›  '),
            style: style,
          ),
        ),
        InfoHint(
          title: 'Hiérarchie de la classification',
          text:
              '${data.title}. Chaque sol est rangé dans 4 niveaux '
              'emboîtés, du plus général au plus précis. Touchez un niveau '
              'pour le déplier, ou le bouton fiche pour lire le détail.',
          more: [
            for (final l in data.levels) InfoSection(l.label, l.explanation),
          ],
        ),
      ],
    );
  }
}

class _Shortcuts extends StatelessWidget {
  final Classification data;
  const _Shortcuts({required this.data});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ClassificationBloc>().state;
    Widget section(String title, IconData icon, List<String> ids) {
      final units = ids.map(data.unit).whereType<SoilUnit>().toList();
      if (units.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(icon, size: 18),
            Text(title, style: Theme.of(context).textTheme.labelMedium),
            for (final u in units)
              ActionChip(
                label: Text(
                  '${u.code} ${u.name}',
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () => context.push('/unit/${u.id}'),
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        section('Favoris', Icons.star, state.favorites),
        section('Récents', Icons.history, state.recents.take(5).toList()),
      ],
    );
  }
}

class _UnitNode extends StatelessWidget {
  final Classification data;
  final SoilUnit unit;
  const _UnitNode({required this.data, required this.unit});

  @override
  Widget build(BuildContext context) {
    final children = data.childrenOf(unit.id);
    if (children.isEmpty) return UnitListTile(data: data, unit: unit);

    final isRoot = unit.level == SoilLevelId.classe;
    final tile = ExpansionTile(
      key: PageStorageKey(unit.id),
      leading: CodeBadge(unit.code),
      title: Text(
        unit.name,
        style: TextStyle(
          fontWeight: isRoot ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${data.level(unit.level).label} · ${children.length} '
        '${data.level(children.first.level).label.toLowerCase()}(s)',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        tooltip: 'Ouvrir la fiche',
        icon: const Icon(Icons.description_outlined),
        onPressed: () => context.push('/unit/${unit.id}'),
      ),
      childrenPadding: const EdgeInsets.only(left: 12),
      children: [for (final c in children) _UnitNode(data: data, unit: c)],
    );
    return isRoot ? Card(clipBehavior: Clip.antiAlias, child: tile) : tile;
  }
}
