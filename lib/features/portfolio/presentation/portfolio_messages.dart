const portfolioEmptyTitle = 'Votre portefeuille est vide';

const portfolioEmptyExplanation =
    'Ajoutez une position fictive pour suivre un montant investi, une valeur et une répartition. Aucun ordre réel n’est passé.';

const portfolioStaleMessage =
    'Valorisation basée sur les dernières données enregistrées';

const portfolioValueUnavailable = 'Valeur actuelle indisponible';

const portfolioKnownValueLabel = 'Valeur actuelle connue';

const portfolioCurrentValueLabel = 'Valeur actuelle';

const portfolioInvestedLabel = 'Montant investi';

const portfolioPartialPerformance =
    'Performance globale indisponible : un cours manque.';

const portfolioPerformanceUnavailable = 'Performance indisponible';

const portfolioReadErrorMessage =
    'Le portefeuille n’a pas pu être lu. Réessayez.';

const portfolioWriteErrorMessage =
    'La position n’a pas pu être enregistrée. Réessayez.';

const portfolioDeleteErrorMessage =
    'La position n’a pas pu être supprimée. Réessayez.';

const portfolioAllocationUnavailable =
    'Répartition indisponible sans cours actuel.';

const portfolioDisclaimer =
    'Portefeuille fictif. Aucun ordre réel n’est transmis.';

const portfolioValuationLoading = 'Chargement des cotations';

String portfolioExcludedMessage(String symbol) {
  return '$symbol est exclu de la répartition : son cours actuel est indisponible.';
}

String formatPortfolioAmount(double value) {
  return _money(value);
}

String formatPortfolioSigned(double value) {
  final amount = formatPortfolioAmount(value);
  if (amount.startsWith('-') || amount == '0.00' || amount == '—') {
    return amount;
  }
  return '+$amount';
}

/// Two decimals. A value that rounds to zero stays `0.00`, never `-0.00`.
/// A non-finite number is not shown as `NaN` or `Infinity`.
String _money(double value) {
  if (!value.isFinite) {
    return '—';
  }
  final negative = value < 0;
  final digits = value.abs().toStringAsFixed(2);
  if (digits == '0.00') {
    return '0.00';
  }
  return negative ? '-$digits' : digits;
}

String formatPortfolioPercent(double value) {
  return '${formatPortfolioSigned(value)} %';
}

String formatPortfolioWeight(double value) {
  return '${formatPortfolioAmount(value)} %';
}

String formatPortfolioTimestamp(DateTime value) {
  final utc = value.toUtc();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(utc.day)}/${two(utc.month)}/${utc.year} '
      '${two(utc.hour)}:${two(utc.minute)} UTC';
}

String formatQuantity(double value) {
  if ((value - value.roundToDouble()).abs() < 1e-9) {
    return value.round().toString();
  }
  var text = value.toStringAsFixed(4);
  text = text.replaceFirst(RegExp(r'0+$'), '');
  if (text.endsWith('.')) {
    text = text.substring(0, text.length - 1);
  }
  return text;
}
