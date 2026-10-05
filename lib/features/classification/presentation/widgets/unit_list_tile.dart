import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/code_badge.dart';
import '../../domain/entities/classification.dart';
import '../../domain/entities/soil_unit.dart';
import '../bloc/classification_bloc.dart';

class UnitListTile extends StatelessWidget {
  final Classification data;
  final SoilUnit unit;
  final Widget? trailing;
  final bool showPath;
  final VoidCallback? onTap;

  const UnitListTile({
    super.key,
    required this.data,
    required this.unit,
    this.trailing,
    this.showPath = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final favorite = context.select<ClassificationBloc, bool>(
      (b) => b.state.isFavorite(unit.id),
    );
    final level = data.level(unit.level).label;
    final subtitle =
        showPath && unit.parentId != null
            ? '$level · ${data.ancestorsOf(unit.id).map((a) => a.name).join(' › ')}'
            : level;
    return ListTile(
      dense: true,
      leading: CodeBadge(unit.code),
      title: Text(showPath ? data.fullName(unit) : unit.name),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing:
          trailing ??
          (favorite ? const Icon(Icons.star, color: Colors.amber) : null),
      onTap: onTap ?? () => context.push('/unit/${unit.id}'),
    );
  }
}
