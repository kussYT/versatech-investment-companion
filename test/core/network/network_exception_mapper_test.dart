import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/core/network/network_exception_mapper.dart';

void main() {
  final requestOptions = RequestOptions(path: 'quote');

  test('maps a connection error', () {
    final exception = DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.connectionError,
    );

    expect(
      mapDioException(exception),
      isA<NetworkUnavailableException>(),
    );
  });

  test('maps a timeout', () {
    final exception = DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.receiveTimeout,
    );

    expect(mapDioException(exception), isA<RequestTimeoutException>());
  });

  test('maps HTTP 401 and 403 to an authorization failure', () {
    for (final statusCode in [401, 403]) {
      final exception = DioException.badResponse(
        statusCode: statusCode,
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: statusCode,
        ),
      );

      expect(mapDioException(exception), isA<UnauthorizedException>());
    }
  });

  test('maps HTTP 429 to a rate limit', () {
    final exception = DioException.badResponse(
      statusCode: 429,
      requestOptions: requestOptions,
      response: Response(
        requestOptions: requestOptions,
        statusCode: 429,
      ),
    );

    expect(mapDioException(exception), isA<RateLimitException>());
  });
}
