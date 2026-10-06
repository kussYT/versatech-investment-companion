import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatech_investment_companion/core/config/app_config.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';

Dio createFmpDio(AppConfig config) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (!config.hasApiKey) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.unknown,
              error: const MissingApiKeyException(),
            ),
          );
          return;
        }

        options.queryParameters = {
          ...options.queryParameters,
          'apikey': config.apiKey,
        };
        handler.next(options);
      },
    ),
  );

  return dio;
}

final dioProvider = Provider<Dio>((ref) {
  final dio = createFmpDio(ref.watch(appConfigProvider));
  ref.onDispose(dio.close);
  return dio;
});
