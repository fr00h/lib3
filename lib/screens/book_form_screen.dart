import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../core/validators.dart';
import '../models/author.dart';
import '../models/book.dart';
import '../models/genre.dart';
import '../models/publisher.dart';
import '../repositories/book_repository.dart';
import '../repositories/entity_repository.dart';
import '../state/book_list_notifier.dart';
import '../widgets/entity_form.dart';
import '../widgets/multi_select_field.dart';
import '../widgets/state_views.dart';

class BookFormScreen extends StatefulWidget {
  const BookFormScreen({super.key, this.id});

  final int? id;

  bool get isEditing => id != null;

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _title = TextEditingController();
  final _isbn = TextEditingController();
  final _year = TextEditingController();
  final _pages = TextEditingController();
  final _copies = TextEditingController();
  int? _publisherId;
  List<int> _authorIds = [];
  List<int> _genreIds = [];
  List<Publisher> _publishers = [];
  List<Author> _authors = [];
  List<Genre> _genres = [];
  Book? _book;
  bool _loading = true;
  String? _isbnError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final books = context.read<BookRepository>();
    final publishers = context.read<EntityRepository<Publisher>>();
    final authors = context.read<EntityRepository<Author>>();
    final genres = context.read<EntityRepository<Genre>>();

    _publishers = await publishers.findAll();
    _authors = await authors.findAll();
    _genres = await genres.findAll();
    if (widget.isEditing) {
      _book = await books.findById(widget.id!);
    }
    final book = _book;
    if (book != null) {
      _title.text = book.title;
      _isbn.text = book.isbn;
      _year.text = '${book.year}';
      _pages.text = '${book.pages}';
      _copies.text = '${book.copiesTotal}';
      _publisherId = _publishers.any((p) => p.id == book.publisherId)
          ? book.publisherId
          : null;
      _authorIds = [...book.authorIds];
      _genreIds = [...book.genreIds];
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _title.dispose();
    _isbn.dispose();
    _year.dispose();
    _pages.dispose();
    _copies.dispose();
    super.dispose();
  }

  Future<bool> _save() async {
    final notifier = context.read<BookListNotifier>();
    final isbn = _isbn.text.trim();
    final total = int.parse(_copies.text.trim());
    final old = _book;
    final book = Book(
      id: old?.id ?? 0,
      title: _title.text.trim(),
      isbn: isbn,
      year: int.parse(_year.text.trim()),
      pages: int.parse(_pages.text.trim()),
      publisherId: _publisherId!,
      authorIds: _authorIds,
      genreIds: _genreIds,
      copiesTotal: total,
      copiesAvailable: old == null
          ? total
          : (old.copiesAvailable + total - old.copiesTotal).clamp(0, total),
      deletedAt: old?.deletedAt,
    );
    try {
      await notifier.save(book, isNew: old == null);
    } on ValidationException catch (e) {
      _isbnError = e.errors['isbn'];
      if (_isbnError == null) rethrow;
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    if (widget.isEditing && _book == null) {
      return const EmptyView(text: 'Книга не найдена');
    }

    return EntityForm(
      title: widget.isEditing ? 'Изменение книги' : 'Новая книга',
      isEditing: widget.isEditing,
      donePath: '/books',
      onSave: _save,
      fields: [
        TextFormField(
          controller: _title,
          decoration: const InputDecoration(
            labelText: 'Название',
            border: OutlineInputBorder(),
          ),
          validator: V.combine([V.required(), V.length(min: 1, max: 200)]),
        ),
        TextFormField(
          controller: _isbn,
          decoration: const InputDecoration(
            labelText: 'ISBN',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _isbnError = null,
          validator: (value) =>
              V.combine([V.required(), V.length(min: 10, max: 17)])(value) ??
              _isbnError,
        ),
        TextFormField(
          controller: _year,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Год издания',
            border: OutlineInputBorder(),
          ),
          validator: V.combine([
            V.required(),
            V.integer(min: 1450, max: DateTime.now().year),
          ]),
        ),
        TextFormField(
          controller: _pages,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Страниц',
            border: OutlineInputBorder(),
          ),
          validator: V.combine([V.required(), V.integer(min: 1, max: 10000)]),
        ),
        TextFormField(
          controller: _copies,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Экземпляров',
            border: OutlineInputBorder(),
          ),
          validator: V.combine([V.required(), V.integer(min: 1, max: 1000)]),
        ),
        DropdownButtonFormField<int>(
          initialValue: _publisherId,
          decoration: const InputDecoration(
            labelText: 'Издательство',
            border: OutlineInputBorder(),
          ),
          items: _publishers
              .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
              .toList(),
          onChanged: (value) => setState(() => _publisherId = value),
          validator: (value) => value == null ? 'Выберите издательство' : null,
        ),
        MultiSelectField(
          label: 'Авторы',
          options: {for (final a in _authors) a.id: a.fullName},
          initialValue: _authorIds,
          onChanged: (value) => setState(() => _authorIds = value),
        ),
        MultiSelectField(
          label: 'Жанры',
          options: {for (final g in _genres) g.id: g.name},
          initialValue: _genreIds,
          onChanged: (value) => setState(() => _genreIds = value),
          validator: (value) => (value == null || value.isEmpty)
              ? 'Выберите хотя бы один жанр'
              : null,
        ),
      ],
    );
  }
}
