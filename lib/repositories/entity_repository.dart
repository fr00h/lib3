import '../models/list_query.dart';
import '../models/page_result.dart';

abstract interface class EntityRepository<T> {
  Future<PageResult<T>> find(ListQuery query);
  Future<List<T>> findAll();
  Future<T?> findById(int id);
  Future<T> create(T item);
  Future<T> update(T item);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}
