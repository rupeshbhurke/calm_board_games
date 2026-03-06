import 'package:flutter/material.dart';

import '../../games/registry/game_module.dart';
import '../../theme/spacing.dart';

class GameCard extends StatelessWidget {
  final GameModule module;

  const GameCard({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    final meta = module.metadata;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.s21),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Spacing.r16),
              ),
              child: Icon(
                meta.icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: Spacing.s13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meta.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: Spacing.s8),
                  Text(meta.tagline, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => module.buildGameScreen()),
                );
              },
              child: const Text('Play'),
            ),
          ],
        ),
      ),
    );
  }
}
