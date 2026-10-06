import 'package:dio/dio.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';

AppException mapDioException(DioException exception) {
  final cause = exception.error;
  if (cause is AppException) {
    return cause;
  }

  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const RequestTimeoutException();
    case DioExceptionType.connectionError:
      return const NetworkUnavailableException();
    case DioExceptionType.badResponse:
      return _mapStatusCode(exception.response?.statusCode);
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      return const UnknownRemoteException();
  }
}

AppException _mapStatusCode(int? statusCode) {
  switch (statusCode) {
    case 401:
    case 403:
      return const UnauthorizedException();
    case 404:
      return const MarketDataNotFoundException();
    case 429:
      return const RateLimitException();
    default:
      return const UnknownRemoteException();
  }
}
