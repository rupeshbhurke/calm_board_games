import 'package:flutter/material.dart';

import '../games/registry/game_registry.dart';
import '../games/registry/game_module.dart';
import '../theme/spacing.dart';
import '../ui/cards/game_card.dart';

typedef _GameSection = ({String title, List<GameModule> modules});

enum _GameViewMode { list, icons }

class HomeScreen extends StatefulWidget {
  final GameRegistry registry;

  const HomeScreen({super.key, required this.registry});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _GameViewMode _viewMode = _GameViewMode.list;

  void _setViewMode(_GameViewMode mode) {
    if (_viewMode == mode) return;
    setState(() => _viewMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final sections = [
      (title: 'Puzzle', modules: widget.registry.byCategory(GameCategory.puzzle)),
      (title: 'Logic', modules: widget.registry.byCategory(GameCategory.logic)),
      (title: 'Strategy', modules: widget.registry.byCategory(GameCategory.strategy)),
      (title: 'Casual', modules: widget.registry.byCategory(GameCategory.casual)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calm Board Suite'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Spacing.s13),
            child: _ViewToggle(
              mode: _viewMode,
              onChanged: _setViewMode,
            ),
          ),
          Expanded(
            child: _viewMode == _GameViewMode.list
                ? _ListSections(sections: sections)
                : _IconSections(sections: sections),
          ),
        ],
      ),
    );
  }
}

class _ListSections extends StatelessWidget {
  final List<_GameSection> sections;

  const _ListSections({required this.sections});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Spacing.s13, 0, Spacing.s13, Spacing.s34),
      children: [
        ...sections.map((section) => _Section(title: section.title, modules: section.modules)),
      ],
    );
  }
}

class _IconSections extends StatelessWidget {
  final List<_GameSection> sections;

  const _IconSections({required this.sections});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Spacing.s13, 0, Spacing.s13, Spacing.s34),
      children: [
        ...sections.map((section) => _IconSection(title: section.title, modules: section.modules)),
      ],
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final _GameViewMode mode;
  final ValueChanged<_GameViewMode> onChanged;

  const _ViewToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isList = mode == _GameViewMode.list;
    final isIcons = mode == _GameViewMode.icons;

    return Row(
      children: [
        Text('View', style: theme.textTheme.titleMedium),
        const Spacer(),
        ToggleButtons(
          borderRadius: BorderRadius.circular(Spacing.r12),
          isSelected: [isList, isIcons],
          constraints: const BoxConstraints(minHeight: 36, minWidth: 64),
          onPressed: (index) {
            onChanged(index == 0 ? _GameViewMode.list : _GameViewMode.icons);
          },
          children: const [
            _ViewToggleChip(icon: Icons.view_agenda, label: 'List'),
            _ViewToggleChip(icon: Icons.apps, label: 'Icons'),
          ],
        ),
      ],
    );
  }
}

class _ViewToggleChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ViewToggleChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<GameModule> modules;

  const _Section({required this.title, required this.modules});

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.s13),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ...modules.map((m) => GameCard(module: m)),
      ],
    );
  }
}

class _IconSection extends StatelessWidget {
  final String title;
  final List<GameModule> modules;

  const _IconSection({required this.title, required this.modules});

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.s13),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        Wrap(
          spacing: Spacing.s13,
          runSpacing: Spacing.s13,
          children: modules.map((m) => _GameIconTile(module: m)).toList(),
        ),
      ],
    );
  }
}

class _GameIconTile extends StatelessWidget {
  final GameModule module;

  const _GameIconTile({required this.module});

  @override
  Widget build(BuildContext context) {
    final meta = module.metadata;
    final borderRadius = BorderRadius.circular(Spacing.r16);

    return SizedBox(
      width: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: borderRadius,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => module.buildGameScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(Spacing.s13),
                child: Column(
                  children: [
                    Icon(
                      meta.icon,
                      size: 36,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: Spacing.s8),
                    Text(
                      meta.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
