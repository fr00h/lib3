import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_exceptions.dart';
import 'config.dart';

Dio buildDio({String? Function()? tokenProvider}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = tokenProvider?.call();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        for (final key in ['__fail', '__delay']) {
          final value = Uri.base.queryParameters[key];
          if (value != null) options.queryParameters[key] = value;
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final status = response.statusCode ?? 0;
        if (kDebugMode) {
          debugPrint(
            '[API] ${response.requestOptions.method} '
            '${response.requestOptions.uri} -> $status',
          );
        }
        if (status >= 400) {
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: mapHttpError(status, response.data),
            ),
            true,
          );
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode && error.error is! ApiException) {
          debugPrint(
            '[API] ${error.requestOptions.method} '
            '${error.requestOptions.uri} -> '
            '${error.response?.statusCode ?? error.type}',
          );
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
}

Future<String?> loginAsAdmin(Dio dio) async {
  try {
    final response = await dio.post(
      '/auth/login',
      data: {'username': 'admin', 'password': 'admin123'},
    );
    return (response.data as Map<String, dynamic>)['accessToken'] as String?;
  } on DioException {
    return null;
  }
}
