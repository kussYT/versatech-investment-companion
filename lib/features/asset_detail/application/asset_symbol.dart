import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';

/// Route parameter to a canonical symbol.
///
/// go_router usually decodes the path once. A leftover percent-encoding is
/// decoded here, then the symbol is trimmed and uppercased. An empty value
/// is rejected instead of being sent to the repository.
String? assetSymbolFromRoute(String raw) {
  var value = raw.trim();
  if (value.contains('%')) {
    try {
      value = Uri.decodeComponent(value).trim();
    } on ArgumentError {
      return null;
    }
  }
  try {
    return requiredSymbol(value);
  } on InvalidMarketDataException {
    return null;
  }
}
