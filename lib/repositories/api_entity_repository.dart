import '../core/api_exceptions.dart';
import '../models/list_query.dart';
import '../models/page_result.dart';
import 'api_repository.dart';
import 'entity_repository.dart';

class ApiEntityRepository<T> extends ApiRepository<T>
    implements EntityRepository<T> {
  ApiEntityRepository(
    super.dio,
    super.path,
    super.fromJson,
    super.toJson,
    super.idOf,
  );

  @override
  Future<PageResult<T>> find(ListQuery q) => guard(() async {
        final response = await dio.get(path, queryParameters: {
          if (q.search.trim().isNotEmpty) 'search': q.search.trim(),
          'sort': '${q.sortField},${q.sortAscending ? 'asc' : 'desc'}',
          'page': q.page,
          'size': q.size,
          if (q.includeDeleted) 'includeDeleted': true,
        });
        return parsePage(response.data, q.size);
      });
}
