import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/code_badge.dart';
import '../../../../core/widgets/guide_button.dart';
import '../../../../core/widgets/info_hint.dart';
import '../../../classification/domain/entities/classification.dart';
import '../../../classification/presentation/widgets/classification_gate.dart';
import '../../domain/entities/lab.dart';
import '../../domain/services/lab_analyzer.dart';
import '../bloc/lab_cubit.dart';

class LabPage extends StatelessWidget {
  const LabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Labo'),
        actions: const [GuideButton('labo'), LearningModeButton()],
      ),
      body: ClassificationGate(
        builder:
            (context, data) => BlocProvider(
              create: (_) => LabCubit(data.lab),
              child: _LabView(data: data),
            ),
      ),
    );
  }
}

String formatNumber(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(1).replaceAll('.', ',');
}

String formatMeasure(LabParameter p, Object value) {
  if (p.kind == LabKind.choice) {
    return p.option(value as String)?.label ?? value;
  }
  final unit = p.unit.isEmpty ? '' : ' ${p.unit}';
  return '${formatNumber((value as num).toDouble())}$unit';
}

String formatExpectation(LabParameter p, LabExpectation e) {
  if (!e.isRange) {
    return e.values.map((v) => p.option(v)?.label ?? v).join(' ou ');
  }
  final unit = p.unit.isEmpty ? '' : ' ${p.unit}';
  return '${formatNumber(e.min!)} à ${formatNumber(e.max!)}$unit';
}

class _LabView extends StatefulWidget {
  final Classification data;
  const _LabView({required this.data});

  @override
  State<_LabView> createState() => _LabViewState();
}

class _LabViewState extends State<_LabView> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _toTop() {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickPreset(BuildContext context) async {
    final cubit = context.read<LabCubit>();
    final preset = await showModalBottomSheet<LabPreset>(
      context: context,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder:
          (context) => ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                title: Text(
                  'Échantillons d\'exemple',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              for (final p in widget.data.lab.presets)
                ListTile(
                  leading: const Icon(Icons.science_outlined),
                  title: Text(p.name),
                  subtitle: Text('${p.measures.length} paramètres'),
                  onTap: () => Navigator.pop(context, p),
                ),
            ],
          ),
    );
    if (preset != null) {
      cubit.loadPreset(preset);
      _toTop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lab = widget.data.lab;
    final state = context.watch<LabCubit>().state;
    final cubit = context.read<LabCubit>();
    final results = state.results;

    return Column(
      children: [
        Expanded(
          child: ContentWidth(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saisissez ce que vous observez ou mesurez, puis '
                          'lancez l\'analyse. Les paramètres « non renseignés » '
                          'ne comptent pas.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.inventory_2_outlined),
                          label: const Text(
                            'Charger un échantillon d\'exemple',
                          ),
                          onPressed: () => _pickPreset(context),
                        ),
                      ],
                    ),
                  ),
                ),
                if (results != null) ...[
                  const SizedBox(height: 8),
                  _Results(
                    data: widget.data,
                    results: results,
                    presetName: state.presetName,
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Paramètres (${state.measures.length}/${lab.parameters.length} renseignés)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                for (final p in lab.parameters)
                  _ParameterCard(
                    parameter: p,
                    value: state.measures[p.id],
                    onChanged: (v) => cubit.setMeasure(p.id, v),
                  ),
              ],
            ),
          ),
        ),
        Material(
          elevation: 4,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Effacer'),
                    onPressed: state.measures.isEmpty ? null : cubit.clear,
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    key: const Key('lab-analyze'),
                    icon: const Icon(Icons.biotech),
                    label: Text('Analyser (${state.measures.length})'),
                    onPressed:
                        state.measures.isEmpty
                            ? null
                            : () {
                              cubit.analyze();
                              _toTop();
                            },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ParameterCard extends StatelessWidget {
  final LabParameter parameter;
  final Object? value;
  final ValueChanged<Object?> onChanged;

  const _ParameterCard({
    required this.parameter,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = parameter;
    final header = Row(
      children: [
        Expanded(
          child: Text(
            p.label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        InfoHint(
          title: p.label,
          text: p.explanation,
          more: [
            if (p.kind == LabKind.choice)
              InfoSection(
                'Les valeurs possibles',
                p.options
                    .map((o) => '• ${o.label} : ${o.explanation}')
                    .join('\n'),
              ),
            InfoSection(
              'Importance dans l\'analyse',
              'Poids ${p.weight} sur 3'
                  '${p.kind == LabKind.range && p.tolerance > 0 ? ' · tolérance ± ${formatNumber(p.tolerance)}${p.unit.isEmpty ? '' : ' ${p.unit}'} (demi-point)' : ''}.',
            ),
          ],
        ),
      ],
    );

    Widget input;
    if (p.kind == LabKind.choice) {
      input = DropdownButtonFormField<String?>(
        key: Key('lab-${p.id}'),
        value: value as String?,
        isExpanded: true,
        decoration: const InputDecoration(isDense: true),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Non renseigné'),
          ),
          for (final o in p.options)
            DropdownMenuItem<String?>(
              value: o.id,
              child: Text(o.label, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: onChanged,
      );
    } else {
      final v = value == null ? null : (value as num).toDouble();
      final divisions = ((p.max - p.min) / p.step).round();
      input =
          v == null
              ? Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: Key('lab-${p.id}'),
                  icon: const Icon(Icons.add),
                  label: const Text('Renseigner une valeur'),
                  onPressed: () => onChanged(_snap(p, (p.min + p.max) / 2)),
                ),
              )
              : Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: v.clamp(p.min, p.max),
                      min: p.min,
                      max: p.max,
                      divisions: divisions,
                      label: formatMeasure(p, v),
                      onChanged: (x) => onChanged(_snap(p, x)),
                    ),
                  ),
                  SizedBox(
                    width: 72,
                    child: Text(
                      formatMeasure(p, v),
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Ne pas renseigner',
                    icon: const Icon(Icons.close),
                    onPressed: () => onChanged(null),
                  ),
                ],
              );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [header, const SizedBox(height: 4), input],
        ),
      ),
    );
  }

  /// Arrondit au pas du paramètre pour éviter les erreurs de virgule flottante.
  static double _snap(LabParameter p, double x) {
    final steps = ((x - p.min) / p.step).round();
    final snapped = p.min + steps * p.step;
    final decimals = p.step < 1 ? 1 : 0;
    return double.parse(snapped.clamp(p.min, p.max).toStringAsFixed(decimals));
  }
}

class _Results extends StatelessWidget {
  final Classification data;
  final List<LabResult> results;
  final String? presetName;

  const _Results({
    required this.data,
    required this.results,
    required this.presetName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (results.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.help_outline),
          title: Text('Aucun type de sol ne décrit ces paramètres.'),
        ),
      );
    }
    final best = results.first;
    final provided = best.providedWeight;
    final few = provided < 6;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          key: const Key('lab-best'),
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  presetName == null
                      ? 'Résultat de l\'analyse'
                      : 'Résultat · $presetName',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                _ResultHeader(data: data, result: best, large: true),
                const SizedBox(height: 8),
                _ScoreDetails(result: best),
                const SizedBox(height: 8),
                _Elements(result: best),
                if (few)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Peu de paramètres renseignés : le résultat est fragile. '
                      'Ajoutez des observations pour le confirmer.',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Voir la fiche'),
                    onPressed: () => context.push('/unit/${best.target}'),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (results.length > 1) ...[
          const SizedBox(height: 8),
          Text('Autres possibilités', style: theme.textTheme.titleSmall),
          for (final r in results.skip(1).take(4))
            Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                title: _ResultHeader(data: data, result: r),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ScoreDetails(result: r),
                  const SizedBox(height: 6),
                  _Elements(result: r),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/unit/${r.target}'),
                      child: const Text('Voir la fiche'),
                    ),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 4),
        Text(
          'Estimation pédagogique, pas un diagnostic : seule une description '
          'complète du profil et des analyses de laboratoire permettent de '
          'classer un sol avec certitude.',
          style: theme.textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final Classification data;
  final LabResult result;
  final bool large;

  const _ResultHeader({
    required this.data,
    required this.result,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final unit = data.unit(result.target);
    final parents = unit == null ? const [] : data.ancestorsOf(unit.id);
    final theme = Theme.of(context);
    return Row(
      children: [
        CodeBadge(result.target),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                unit?.name ?? result.target,
                style: (large
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.bodyLarge)
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (parents.isNotEmpty)
                Text(
                  parents.map((u) => u.name).join(' › '),
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
        Text(
          '${result.percent} %',
          style: (large
                  ? theme.textTheme.headlineSmall
                  : theme.textTheme.titleMedium)
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ScoreDetails extends StatelessWidget {
  final LabResult result;
  const _ScoreDetails({required this.result});

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: r.score, minHeight: 6),
        const SizedBox(height: 6),
        Text(
          'Concordance : ${formatNumber(r.earnedPoints)} / ${r.consideredWeight} '
          'points (${(r.agreement * 100).round()} %) · Couverture : '
          '${r.consideredWeight} / ${r.providedWeight} points de vos mesures '
          '(${(r.coverage * 100).round()} %)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Elements extends StatelessWidget {
  final LabResult result;
  const _Elements({required this.result});

  @override
  Widget build(BuildContext context) {
    final sorted = [...result.elements]
      ..sort((a, b) => a.verdict.index.compareTo(b.verdict.index));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in sorted)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  switch (e.verdict) {
                    LabVerdict.match => Icons.check_circle,
                    LabVerdict.near => Icons.adjust,
                    LabVerdict.contradiction => Icons.cancel,
                  },
                  size: 18,
                  color: switch (e.verdict) {
                    LabVerdict.match => AppTheme.secondaryColor,
                    LabVerdict.near => Colors.orange.shade700,
                    LabVerdict.contradiction => AppTheme.errorColor,
                  },
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${e.parameter.label} : ',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: formatMeasure(e.parameter, e.measured)),
                        if (e.verdict != LabVerdict.match)
                          TextSpan(
                            text:
                                ' (attendu : ${formatExpectation(e.parameter, e.expected)})',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
