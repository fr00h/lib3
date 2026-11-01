import 'package:flutter/foundation.dart';

import '../core/api_exceptions.dart';
import '../models/author.dart';
import '../models/book.dart';
import '../models/book_query.dart';
import '../models/genre.dart';
import '../models/page_result.dart';
import '../models/publisher.dart';
import '../repositories/book_repository.dart';
import '../repositories/entity_repository.dart';

enum LoadStatus { idle, loading, success, error }

class BookListNotifier extends ChangeNotifier {
  final BookRepository _repository;
  final EntityRepository<Author> _authorRepository;
  final EntityRepository<Genre> _genreRepository;
  final EntityRepository<Publisher> _publisherRepository;

  BookListNotifier(
    this._repository,
    this._authorRepository,
    this._genreRepository,
    this._publisherRepository,
  );

  BookQuery _query = const BookQuery();
  PageResult<Book> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};
  List<Book> _allBooks = [];
  List<Author> _authors = [];
  List<Genre> _genres = [];
  List<Publisher> _publishers = [];

  BookQuery get query => _query;
  PageResult<Book> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;
  List<Publisher> get publishers => _publishers;

  List<Genre> genresFor(int? publisherId) {
    if (publisherId == null) return _genres;
    final ids = _allBooks
        .where((b) => b.publisherId == publisherId)
        .expand((b) => b.genreIds)
        .toSet();
    return _genres.where((g) => ids.contains(g.id)).toList();
  }

  String publisherName(int id) =>
      _publishers.where((p) => p.id == id).firstOrNull?.name ?? '';

  String genreNames(Book book) => _genres
      .where((g) => book.genreIds.contains(g.id))
      .map((g) => g.name)
      .join(', ');

  String authorNames(Book book) => _authors
      .where((a) => book.authorIds.contains(a.id))
      .map((a) => a.fullName)
      .join(', ');

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _allBooks = await _repository.findAll();
      _authors = await _authorRepository.findAll();
      _genres = await _genreRepository.findAll();
      _publishers = await _publisherRepository.findAll();
      _result = await _repository.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить список: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(BookQuery next) async {
    _query = next;
    _selected.clear();
    await load();
  }

  Future<Book?> findById(int id) => _repository.findById(id);

  Future<void> save(Book book, {required bool isNew}) async {
    isNew ? await _repository.create(book) : await _repository.update(book);
    await load();
  }

  void toggleSelection(int id) {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    final ids = _selected.toList();
    _selected.clear();
    await _run(() => _repository.deleteMany(ids));
  }

  Future<void> softDelete(int id) => _run(() => _repository.softDelete(id));

  Future<void> hardDelete(int id) => _run(() => _repository.hardDelete(id));

  Future<void> restore(int id) => _run(() => _repository.restore(id));

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
      await load();
    } on ApiException catch (e) {
      _error = e.message;
      _status = LoadStatus.error;
      notifyListeners();
    }
  }
}
