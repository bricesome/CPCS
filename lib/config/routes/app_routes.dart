import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/classification/presentation/pages/classification_page.dart';
import '../../features/classification/presentation/pages/unit_detail_page.dart';
import '../../features/comparison/presentation/pages/compare_page.dart';
import '../../features/determination/presentation/pages/determination_page.dart';
import '../../features/explorer/presentation/pages/explorer_page.dart';
import '../../features/learning/presentation/pages/learning_page.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Page introuvable : ${state.uri.path}')),
        ),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const ClassificationPage(),
                routes: [
                  GoRoute(
                    path: 'unit/:id',
                    builder:
                        (context, state) => UnitDetailPage(
                          key: ValueKey(state.pathParameters['id']),
                          unitId: state.pathParameters['id']!,
                        ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explorer',
                builder: (context, state) => const ExplorerPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/compare',
                builder: (context, state) => const ComparePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/key',
                builder: (context, state) => const DeterminationPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                builder: (context, state) => const LearningPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Navigation adaptative : barre du bas sur mobile, rail latéral sur grand écran.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const AppShell({super.key, required this.shell});

  static const _destinations = [
    (Icons.account_tree_outlined, Icons.account_tree, 'Classification'),
    (Icons.hub_outlined, Icons.hub, 'Croisement'),
    (Icons.compare_arrows_outlined, Icons.compare_arrows, 'Comparer'),
    (Icons.quiz_outlined, Icons.quiz, 'Clé'),
    (Icons.school_outlined, Icons.school, 'Apprendre'),
  ];

  void _go(int index) =>
      shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 800) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: width >= 1200,
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _go,
              labelType:
                  width >= 1200
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Icon(Icons.terrain, size: 32),
              ),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.$1),
                    selectedIcon: Icon(d.$2),
                    label: Text(d.$3),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: shell),
          ],
        ),
      );
    }
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _go,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.$1),
              selectedIcon: Icon(d.$2),
              label: d.$3,
            ),
        ],
      ),
    );
  }
}
