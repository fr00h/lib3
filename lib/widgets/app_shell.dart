import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _sections = {
  '/books': 'Книги',
  '/authors': 'Авторы',
  '/genres': 'Жанры',
  '/publishers': 'Издательства',
  '/readers': 'Читатели',
};

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final narrow = MediaQuery.sizeOf(context).width < 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Библиотека'),
        actions: [
          if (narrow)
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu),
              onSelected: (value) => context.go(value),
              itemBuilder: (context) => [
                for (final e in _sections.entries)
                  PopupMenuItem(value: e.key, child: Text(e.value)),
              ],
            )
          else
            for (final e in _sections.entries)
              _NavButton(
                label: e.value,
                active: path.startsWith(e.key),
                onPressed: () => context.go(e.key),
              ),
          const SizedBox(width: 8),
        ],
      ),
      body: child,
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.active,
    required this.onPressed,
  });

  final String label;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
