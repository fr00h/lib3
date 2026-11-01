import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/page_result.dart';

class ApiRepository<T> {
  final Dio dio;
  final String path;
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic> Function(T item) toJson;
  final int Function(T item) idOf;

  ApiRepository(this.dio, this.path, this.fromJson, this.toJson, this.idOf);

  PageResult<T> parsePage(dynamic body, int size) {
    final data = body as Map<String, dynamic>;
    return PageResult(
      items: (data['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(),
      page: data['page'] as int? ?? 1,
      size: data['size'] as int? ?? size,
      total: data['total'] as int? ?? 0,
    );
  }

  Future<List<T>> findAll() => guard(() async {
        final response = await dio.get(path, queryParameters: {'size': 100});
        return parsePage(response.data, 100).items;
      });

  Future<T?> findById(int id) async {
    try {
      return await guard(() async {
        final response = await dio.get(
          '$path/$id',
          queryParameters: {'includeDeleted': true},
        );
        return fromJson(response.data as Map<String, dynamic>);
      });
    } on NotFoundException {
      return null;
    }
  }

  Future<T> create(T item) => guard(() async {
        final response = await dio.post(path, data: toJson(item));
        return fromJson(response.data as Map<String, dynamic>);
      });

  Future<T> update(T item) => guard(() async {
        final response =
            await dio.put('$path/${idOf(item)}', data: toJson(item));
        return fromJson(response.data as Map<String, dynamic>);
      });

  Future<void> softDelete(int id) => guard(() => dio.delete('$path/$id'));

  Future<void> hardDelete(int id) =>
      guard(() => dio.delete('$path/$id', queryParameters: {'hard': true}));

  Future<void> restore(int id) => guard(() => dio.post('$path/$id/restore'));

  Future<int> deleteMany(List<int> ids) => guard(() async {
        final response = await dio.post('$path/bulk-delete', data: {'ids': ids});
        return (response.data as Map<String, dynamic>)['deleted'] as int? ?? 0;
      });
}
