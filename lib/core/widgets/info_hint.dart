import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/classification/presentation/bloc/classification_bloc.dart';
import '../theme/app_theme.dart';

/// Petit indicateur ⓘ : ouvre une fiche explicative sans encombrer l'écran.
/// Masqué quand le mode apprentissage est désactivé.
class InfoHint extends StatelessWidget {
  final String title;
  final String text;
  final List<InfoSection> more;
  final double size;

  const InfoHint({
    super.key,
    required this.title,
    required this.text,
    this.more = const [],
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = context.select<ClassificationBloc, bool>(
      (b) => b.state.learningMode,
    );
    if (!enabled) return const SizedBox.shrink();
    return Tooltip(
      message: 'Explication',
      child: InkResponse(
        radius: size,
        onTap:
            () => showInfoSheet(context, title: title, text: text, more: more),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.info_outline,
            size: size,
            color: AppTheme.infoColor,
          ),
        ),
      ),
    );
  }
}

class InfoSection {
  final String title;
  final String text;
  const InfoSection(this.title, this.text);
}

Future<void> showInfoSheet(
  BuildContext context, {
  required String title,
  required String text,
  List<InfoSection> more = const [],
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    constraints: const BoxConstraints(maxWidth: 640),
    builder:
        (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: more.isEmpty ? 0.35 : 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.9,
          builder:
              (context, controller) => ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book_outlined,
                        color: AppTheme.infoColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(text, style: const TextStyle(height: 1.4)),
                  if (more.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    for (final s in more)
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          s.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        childrenPadding: const EdgeInsets.only(bottom: 8),
                        expandedAlignment: Alignment.centerLeft,
                        children: [
                          Text(s.text, style: const TextStyle(height: 1.4)),
                        ],
                      ),
                  ],
                ],
              ),
        ),
  );
}
