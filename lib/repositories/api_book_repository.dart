import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/book.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import 'api_repository.dart';
import 'book_repository.dart';

class ApiBookRepository extends ApiRepository<Book> implements BookRepository {
  ApiBookRepository(Dio dio)
      : super(dio, '/books', Book.fromJson, (b) => b.toJson(), (b) => b.id);

  @override
  Future<PageResult<Book>> find(BookQuery q) => guard(() async {
        final response = await dio.get('/books', queryParameters: {
          if (q.search.trim().isNotEmpty) 'search': q.search.trim(),
          if (q.genreId != null) 'genreId': q.genreId,
          if (q.publisherId != null) 'publisherId': q.publisherId,
          if (q.yearFrom != null) 'yearFrom': q.yearFrom,
          if (q.yearTo != null) 'yearTo': q.yearTo,
          'sort': '${q.sortField},${q.sortAscending ? 'asc' : 'desc'}',
          'page': q.page,
          'size': q.size,
          if (q.includeDeleted) 'includeDeleted': true,
        });
        return parsePage(response.data, q.size);
      });

  @override
  Future<int> countByPublisher(int publisherId) => guard(() async {
        final response = await dio.get('/books', queryParameters: {
          'publisherId': publisherId,
          'size': 1,
          'includeDeleted': true,
        });
        return (response.data as Map<String, dynamic>)['total'] as int? ?? 0;
      });

  @override
  Future<void> issue(int bookId, int readerId) => guard(
        () => dio.post('/loans', data: {'bookId': bookId, 'readerId': readerId}),
      );
}
