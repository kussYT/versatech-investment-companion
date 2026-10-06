enum FailureCode {
  missingApiKey,
  networkUnavailable,
  timeout,
  unauthorized,
  rateLimited,
  notFound,
  invalidResponse,
  unknownRemote,
}

class Failure {
  const Failure(this.code, {this.detail});

  final FailureCode code;
  final String? detail;

  @override
  bool operator ==(Object other) {
    return other is Failure && other.code == code && other.detail == detail;
  }

  @override
  int get hashCode => Object.hash(code, detail);
}
