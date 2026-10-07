import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/features/asset_detail/presentation/asset_detail_messages.dart';

void main() {
  test('keeps two decimals and never prints a signed zero', () {
    expect(formatDetailAmount(189.2), '189.20');
    expect(formatDetailAmount(-1.5), '-1.50');
    expect(formatSignedAmount(2), '+2.00');
    expect(formatSignedAmount(-2), '-2.00');
    expect(formatDetailAmount(-0.001), '0.00');
    expect(formatSignedAmount(0.001), '0.00');
    expect(formatSignedAmount(-0.001), '0.00');
    expect(formatSignedPercent(-4.5), '-4.50 %');
  });

  test('does not render NaN or Infinity', () {
    expect(formatDetailAmount(double.nan), '—');
    expect(formatSignedAmount(double.infinity), '—');
    expect(formatDetailAmount(double.nan), isNot(contains('NaN')));
    expect(formatSignedAmount(double.infinity), isNot(contains('Infinity')));
  });
}
