import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CodeBadge extends StatelessWidget {
  final String code;
  const CodeBadge(this.code, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.colorForCode(code);
    final dark = color.computeLuminance() < 0.4;
    return Container(
      constraints: const BoxConstraints(minWidth: 44),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        code,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: dark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
