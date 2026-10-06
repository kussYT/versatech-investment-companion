import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  const AppConfig({
    required this.apiKey,
    this.baseUrl = fmpBaseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 20),
  });

  static const fmpBaseUrl = 'https://financialmodelingprep.com/stable/';

  final String apiKey;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  Duration get sendTimeout => connectTimeout;

  bool get hasApiKey => apiKey.trim().isNotEmpty;

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      apiKey: String.fromEnvironment('FMP_API_KEY'),
    );
  }

  @override
  String toString() {
    return 'AppConfig(hasApiKey: $hasApiKey, baseUrl: $baseUrl)';
  }
}

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});
