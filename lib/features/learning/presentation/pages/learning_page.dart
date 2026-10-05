import 'package:flutter/material.dart';

import '../../../../core/utils/text_normalize.dart';
import '../../../classification/domain/entities/classification.dart';
import '../../../classification/presentation/widgets/classification_gate.dart';

class LearningPage extends StatelessWidget {
  const LearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Apprendre'),
          actions: const [LearningModeButton()],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Niveaux'),
              Tab(text: 'Critères'),
              Tab(text: 'Glossaire'),
              Tab(text: 'À propos'),
            ],
          ),
        ),
        body: ClassificationGate(
          builder:
              (context, data) => TabBarView(
                children: [
                  _LevelsTab(data: data),
                  _CriteriaTab(data: data),
                  _GlossaryTab(data: data),
                  _AboutTab(data: data),
                ],
              ),
        ),
      ),
    );
  }
}

class _LevelsTab extends StatelessWidget {
  final Classification data;
  const _LevelsTab({required this.data});

  @override
  Widget build(BuildContext context) {
    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < data.levels.length; i++)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(data.levels[i].label),
                subtitle: Text(data.levels[i].explanation),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Les 12 classes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final c in data.roots)
            ExpansionTile(
              title: Text('${c.code} · ${c.name}'),
              expandedAlignment: Alignment.centerLeft,
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              children: [
                Text(c.description),
                if (c.explanation != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    c.explanation!,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _CriteriaTab extends StatelessWidget {
  final Classification data;
  const _CriteriaTab({required this.data});

  @override
  Widget build(BuildContext context) {
    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final c in data.criteria)
            Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                title: Text(c.label),
                subtitle: Text(
                  c.explanation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                children: [
                  for (final v in c.values)
                    ListTile(
                      dense: true,
                      title: Text(
                        v.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(v.explanation),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GlossaryTab extends StatefulWidget {
  final Classification data;
  const _GlossaryTab({required this.data});

  @override
  State<_GlossaryTab> createState() => _GlossaryTabState();
}

class _GlossaryTabState extends State<_GlossaryTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = normalizeText(_query);
    final entries =
        widget.data.glossary
            .where(
              (g) =>
                  q.isEmpty ||
                  normalizeText('${g.term} ${g.definition}').contains(q),
            )
            .toList()
          ..sort(
            (a, b) => normalizeText(a.term).compareTo(normalizeText(b.term)),
          );
    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Chercher un terme',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 8),
          for (final g in entries)
            ListTile(
              title: Text(
                g.term,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(g.definition),
            ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  final Classification data;
  const _AboutTab({required this.data});

  @override
  Widget build(BuildContext context) {
    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(data.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(data.source),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Note'),
              subtitle: Text(data.note),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.school_outlined),
              title: Text('Mode apprentissage'),
              subtitle: Text(
                'Les petites icônes ⓘ ouvrent une explication. Utilisez le '
                'bouton chapeau en haut à droite pour les masquer et passer '
                'en mode lecture.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.dataset_outlined),
              title: const Text('Contenu'),
              subtitle: Text(
                '${data.units.length} unités · ${data.criteria.length} '
                'critères · ${data.keyQuestions.length} questions de clé · '
                '${data.glossary.length} termes',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
