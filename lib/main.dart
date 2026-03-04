import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lib/app/app_shell.dart';

void main() {
  runApp(const ProviderScope(child: CalmBoardApp()));
}

class CalmBoardApp extends StatelessWidget {
  const CalmBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell();
  }
}
