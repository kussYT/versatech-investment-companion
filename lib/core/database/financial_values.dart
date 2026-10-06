import 'package:versatech_investment_companion/core/errors/app_exception.dart';

/// SQLite stores these amounts as REAL, an IEEE-754 double.
///
/// That is the same representation as the domain `double`. Every table reads
/// and writes prices, variations and percentages through this helper so the
/// conversion stays identical. This teaching cache does not use a decimal
/// type: values are not rounded on purpose, and later arithmetic can show
/// binary floating-point error. A stored price is therefore not an exact
/// number of cents. Volumes stay in a separate INTEGER column.
abstract final class FinancialValues {
  static double toSql(double value) {
    if (value.isNaN || value.isInfinite) {
      throw InvalidMarketDataException('A financial value is not finite.');
    }
    return value;
  }

  static double fromSql(double value) => value;

  static double? fromSqlNullable(double? value) {
    if (value == null) {
      return null;
    }
    return fromSql(value);
  }
}
