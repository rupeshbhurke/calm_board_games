import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';

class SlidingPuzzleScreen extends StatelessWidget {
  const SlidingPuzzleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Stub: real board logic arrives in Milestone 2.
    return Scaffold(
      appBar: AppBar(title: const Text('Sliding Puzzle')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.s21),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Module wiring is working ✅\n\nNext: implement board logic + UI grid.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: Spacing.s21),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
