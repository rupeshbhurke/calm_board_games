import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Shows a game completion dialog with customizable actions.
Future<void> showGameDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String primaryLabel,
  required VoidCallback onPrimary,
  String? secondaryLabel,
  VoidCallback? onSecondary,
}) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.r16),
      ),
      title: Text(title),
      content: Text(message),
      actions: [
        if (secondaryLabel != null && onSecondary != null)
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onSecondary();
            },
            child: Text(secondaryLabel),
          ),
        FilledButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            onPrimary();
          },
          child: Text(primaryLabel),
        ),
      ],
    ),
  );
}

/// Shows a simple info dialog.
Future<void> showInfoDialog({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.r16),
      ),
      title: Text(title),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
