import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/book.dart';
import '../models/reader.dart';
import '../repositories/book_repository.dart';
import '../repositories/entity_repository.dart';
import '../state/book_list_notifier.dart';
import '../widgets/state_views.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.id});

  final int id;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Future<Book?> _future;

  @override
  void initState() {
    super.initState();
    final notifier = context.read<BookListNotifier>();
    _future = notifier.findById(widget.id);
    if (notifier.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifier.load());
    }
  }

  void _retry() {
    setState(() {
      _future = context.read<BookListNotifier>().findById(widget.id);
    });
  }

  Future<void> _issue(Book book) async {
    final readers = await context.read<EntityRepository<Reader>>().findAll();
    if (!mounted) return;
    final readerId = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Кому выдать книгу'),
        children: [
          for (final r in readers)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, r.id),
              child: Text(r.fullName),
            ),
        ],
      ),
    );
    if (readerId == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<BookRepository>().issue(book.id, readerId);
      messenger.showSnackBar(const SnackBar(content: Text('Книга выдана')));
      if (mounted) _retry();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BookListNotifier>();

    return FutureBuilder<Book?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: 'Не удалось загрузить книгу: ${snapshot.error}',
            onRetry: _retry,
          );
        }
        final book = snapshot.data;
        if (book == null) {
          return const EmptyView(text: 'Книга не найдена');
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (book.isDeleted)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Chip(label: Text('Удалена')),
                          ),
                        _Field('Авторы', notifier.authorNames(book)),
                        _Field('ISBN', book.isbn),
                        _Field('Год издания', '${book.year}'),
                        _Field('Страниц', '${book.pages}'),
                        _Field(
                          'Издательство',
                          notifier.publisherName(book.publisherId),
                        ),
                        _Field('Жанры', notifier.genreNames(book)),
                        _Field(
                          'Экземпляров',
                          '${book.copiesAvailable} из ${book.copiesTotal} в наличии',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => context.go('/books'),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('К списку книг'),
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: () => _issue(book),
                              icon: const Icon(Icons.outbox_outlined),
                              label: const Text('Выдать'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.go('/books/${book.id}/edit'),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Изменить'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value.isEmpty ? '-' : value),
    );
  }
}
