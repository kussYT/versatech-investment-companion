import 'package:versatech_investment_companion/core/errors/failure.dart';

sealed class AppException implements Exception {
  const AppException(this.failure);

  final Failure failure;

  @override
  String toString() {
    final detail = failure.detail;
    if (detail == null || detail.isEmpty) {
      return '$runtimeType(${failure.code.name})';
    }
    return '$runtimeType(${failure.code.name}: $detail)';
  }
}

final class MissingApiKeyException extends AppException {
  const MissingApiKeyException()
      : super(
          const Failure(
            FailureCode.missingApiKey,
            detail: 'FMP_API_KEY is not set.',
          ),
        );
}

final class NetworkUnavailableException extends AppException {
  const NetworkUnavailableException()
      : super(const Failure(FailureCode.networkUnavailable));
}

final class RequestTimeoutException extends AppException {
  const RequestTimeoutException() : super(const Failure(FailureCode.timeout));
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super(const Failure(FailureCode.unauthorized));
}

final class RateLimitException extends AppException {
  const RateLimitException() : super(const Failure(FailureCode.rateLimited));
}

final class MarketDataNotFoundException extends AppException {
  const MarketDataNotFoundException()
      : super(const Failure(FailureCode.notFound));
}

final class InvalidMarketDataException extends AppException {
  InvalidMarketDataException([String? detail])
      : super(Failure(FailureCode.invalidResponse, detail: detail));
}

final class UnsupportedAssetTypeException extends AppException {
  const UnsupportedAssetTypeException()
      : super(
          const Failure(
            FailureCode.invalidResponse,
            detail: 'Unsupported instrument type.',
          ),
        );
}

final class UnknownRemoteException extends AppException {
  const UnknownRemoteException()
      : super(const Failure(FailureCode.unknownRemote));
}
