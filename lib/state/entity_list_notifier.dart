import 'package:flutter/foundation.dart';

import '../core/api_exceptions.dart';
import '../models/list_query.dart';
import '../models/page_result.dart';
import '../repositories/entity_repository.dart';
import 'book_list_notifier.dart';

class EntityListNotifier<T> extends ChangeNotifier {
  final EntityRepository<T> _repository;

  EntityListNotifier(this._repository);

  ListQuery? _query;
  PageResult<T> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};

  ListQuery? get query => _query;
  PageResult<T> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;

  Future<void> load() async {
    if (_query == null) return;
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _result = await _repository.find(_query!);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить список: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(ListQuery next) async {
    _query = next;
    _selected.clear();
    await load();
  }

  Future<T?> findById(int id) => _repository.findById(id);

  Future<void> save(T item, {required bool isNew}) async {
    isNew ? await _repository.create(item) : await _repository.update(item);
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
