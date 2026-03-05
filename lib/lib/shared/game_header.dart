import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Reusable header widget for game screens.
/// Shows status info on left, action button on right.
class GameHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String buttonLabel;
  final VoidCallback onButtonPressed;
  final Widget? leading;

  const GameHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.buttonLabel,
    required this.onButtonPressed,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.s21),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: Spacing.s13),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: Spacing.s8),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ],
              ),
            ),
            FilledButton(
              onPressed: onButtonPressed,
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
