import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/features/portfolio/presentation/portfolio_messages.dart';

void main() {
  test('keeps two decimals, a sign, and never prints a signed zero', () {
    expect(formatPortfolioAmount(10), '10.00');
    expect(formatPortfolioAmount(-10.5), '-10.50');
    expect(formatPortfolioSigned(12.5), '+12.50');
    expect(formatPortfolioSigned(-3), '-3.00');
    expect(formatPortfolioSigned(0), '0.00');
    expect(formatPortfolioAmount(-0.004), '0.00');
    expect(formatPortfolioSigned(0.004), '0.00');
    expect(formatPortfolioSigned(-0.004), '0.00');
    expect(formatPortfolioPercent(-20), '-20.00 %');
    expect(formatPortfolioPercent(0.001), '0.00 %');
  });

  test('does not render NaN or Infinity', () {
    expect(formatPortfolioAmount(double.nan), '—');
    expect(formatPortfolioAmount(double.infinity), '—');
    expect(formatPortfolioAmount(double.negativeInfinity), '—');
    expect(formatPortfolioSigned(double.nan), '—');
    expect(formatPortfolioSigned(double.nan), isNot(contains('NaN')));
    expect(formatPortfolioAmount(double.infinity), isNot(contains('Infinity')));
  });
}
