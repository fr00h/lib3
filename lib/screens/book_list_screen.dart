import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../models/book_query.dart';
import '../state/book_list_notifier.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/debounced_field.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/state_views.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key, required this.query});

  final BookQuery query;

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant BookListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = context.read<BookListNotifier>();
      if (notifier.status == LoadStatus.idle ||
          notifier.query.location != widget.query.location) {
        notifier.applyQuery(widget.query);
      }
    });
  }

  void _go(BookQuery query) => context.go(query.location);

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BookListNotifier>();
    final q = widget.query;
    final genres = notifier.genresFor(q.publisherId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DebouncedField(
                label: 'Название или ISBN',
                value: q.search,
                width: 260,
                onChanged: (v) => _go(q.copyWith(search: v)),
              ),
              DropdownButton<int?>(
                value: notifier.publishers.any((p) => p.id == q.publisherId)
                    ? q.publisherId
                    : null,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Все издательства'),
                  ),
                  for (final p in notifier.publishers)
                    DropdownMenuItem(value: p.id, child: Text(p.name)),
                ],
                onChanged: (v) => _go(q.copyWith(publisherId: v, genreId: null)),
              ),
              DropdownButton<int?>(
                value: genres.any((g) => g.id == q.genreId) ? q.genreId : null,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Все жанры')),
                  for (final g in genres)
                    DropdownMenuItem(value: g.id, child: Text(g.name)),
                ],
                onChanged: (v) => _go(q.copyWith(genreId: v)),
              ),
              DebouncedField(
                label: 'Год с',
                value: q.yearFrom?.toString() ?? '',
                width: 100,
                numeric: true,
                onChanged: (v) => _go(q.copyWith(yearFrom: int.tryParse(v))),
              ),
              DebouncedField(
                label: 'Год по',
                value: q.yearTo?.toString() ?? '',
                width: 100,
                numeric: true,
                onChanged: (v) => _go(q.copyWith(yearTo: int.tryParse(v))),
              ),
              FilterChip(
                label: const Text('Удалённые'),
                selected: q.includeDeleted,
                onSelected: (v) => _go(q.copyWith(includeDeleted: v)),
              ),
              TextButton(
                onPressed: () => context.go('/books'),
                child: const Text('Сбросить'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Добавить книгу'),
                onPressed: () => context.go('/books/new'),
              ),
              Text('Выбрано: ${notifier.selected.length}'),
              FilledButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Удалить выбранные'),
                onPressed: !notifier.hasSelection
                    ? null
                    : () async {
                        final count = notifier.selected.length;
                        if (await confirm(context, 'Удалить выбранные книги ($count)?')) {
                          notifier.deleteSelected();
                        }
                      },
              ),
            ],
          ),
        ),
        Expanded(child: _buildContent(context, notifier)),
        if (notifier.status == LoadStatus.success && notifier.result.total > 0)
          PaginationBar(
            page: notifier.result.page,
            totalPages: notifier.result.totalPages,
            total: notifier.result.total,
            size: q.size,
            onPage: (p) => _go(q.copyWith(page: p)),
            onSize: (s) => _go(q.copyWith(size: s)),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, BookListNotifier notifier) {
    final q = widget.query;

    return switch (notifier.status) {
      LoadStatus.idle || LoadStatus.loading => const LoadingView(),
      LoadStatus.error => ErrorView(
          message: notifier.error ?? 'Ошибка',
          onRetry: notifier.load,
        ),
      LoadStatus.success when notifier.result.items.isEmpty =>
        const EmptyView(text: 'Книги не найдены'),
      LoadStatus.success => EntityTable<Book>(
          items: notifier.result.items,
          idOf: (b) => b.id,
          selected: notifier.selected,
          onToggleSelect: notifier.toggleSelection,
          sortField: q.sortField,
          sortAscending: q.sortAscending,
          onSort: (field) => _go(
            q.copyWith(
              sortField: field,
              sortAscending: field == q.sortField ? !q.sortAscending : true,
            ),
          ),
          columns: [
            TableColumnSpec(
              label: 'Название',
              sortField: 'title',
              build: (b) => Text(b.title),
            ),
            TableColumnSpec(
              label: 'Авторы',
              build: (b) => Text(notifier.authorNames(b)),
            ),
            TableColumnSpec(
              label: 'Год',
              sortField: 'year',
              numeric: true,
              build: (b) => Text('${b.year}'),
            ),
            TableColumnSpec(
              label: 'Страниц',
              sortField: 'pages',
              numeric: true,
              build: (b) => Text('${b.pages}'),
            ),
            TableColumnSpec(
              label: 'Издательство',
              build: (b) => Text(notifier.publisherName(b.publisherId)),
            ),
          ],
          actions: (b) => _actions(context, notifier, b),
        ),
    };
  }

  List<Widget> _actions(
    BuildContext context,
    BookListNotifier notifier,
    Book b,
  ) {
    return [
      IconButton(
        tooltip: 'Открыть',
        icon: const Icon(Icons.info_outline),
        onPressed: () => context.go('/books/${b.id}'),
      ),
      IconButton(
        tooltip: 'Изменить',
        icon: const Icon(Icons.edit_outlined),
        onPressed: () => context.go('/books/${b.id}/edit'),
      ),
      if (b.isDeleted)
        IconButton(
          tooltip: 'Восстановить',
          icon: const Icon(Icons.restore),
          onPressed: () => notifier.restore(b.id),
        )
      else
        IconButton(
          tooltip: 'Удалить',
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            if (await confirm(context, 'Удалить книгу «${b.title}»?')) {
              notifier.softDelete(b.id);
            }
          },
        ),
      IconButton(
        tooltip: 'Удалить навсегда',
        icon: const Icon(Icons.delete_forever),
        onPressed: () async {
          if (await confirm(
            context,
            'Удалить книгу «${b.title}» навсегда? Восстановить её будет нельзя.',
          )) {
            notifier.hardDelete(b.id);
          }
        },
      ),
    ];
  }
}
