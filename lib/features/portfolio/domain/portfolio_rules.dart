import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';

const symbolRequiredMessage = 'Indiquez un symbole.';
const quantityRequiredMessage = 'Indiquez une quantité.';
const quantityNumberMessage = 'La quantité doit être un nombre.';
const quantityPositiveMessage = 'La quantité doit être supérieure à 0.';
const priceRequiredMessage = 'Indiquez un prix d’achat.';
const priceNumberMessage = 'Le prix d’achat doit être un nombre.';
const pricePositiveMessage = 'Le prix d’achat doit être supérieur à 0.';
const dateRequiredMessage = 'Indiquez une date d’achat.';
const dateInvalidMessage = 'La date d’achat n’est pas valide.';
const dateFutureMessage = 'La date d’achat ne peut pas être dans le futur.';

/// A rejected position. [userMessage] is safe to show as-is.
final class InvalidPortfolioInput implements Exception {
  const InvalidPortfolioInput(this.userMessage);

  final String userMessage;

  @override
  String toString() => 'InvalidPortfolioInput';
}

/// Calendar day of [instant] in UTC. Purchase dates use this clock day.
DateTime calendarDay(DateTime instant) {
  final utc = instant.toUtc();
  return DateTime.utc(utc.year, utc.month, utc.day);
}

String? symbolError(String raw) {
  if (normalizeSymbol(raw).isEmpty) {
    return symbolRequiredMessage;
  }
  return null;
}

String? quantityError(String raw) {
  return _positiveError(
    raw,
    empty: quantityRequiredMessage,
    number: quantityNumberMessage,
    positive: quantityPositiveMessage,
  );
}

String? purchasePriceError(String raw) {
  return _positiveError(
    raw,
    empty: priceRequiredMessage,
    number: priceNumberMessage,
    positive: pricePositiveMessage,
  );
}

String? purchaseDateError(String raw, DateTime today) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return dateRequiredMessage;
  }
  final date = tryParsePurchaseDate(trimmed);
  if (date == null) {
    return dateInvalidMessage;
  }
  if (isAfterDay(date, today)) {
    return dateFutureMessage;
  }
  return null;
}

DateTime? tryParsePurchaseDate(String raw) {
  final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(raw.trim());
  if (match == null) {
    return null;
  }
  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  if (month < 1 || month > 12 || day < 1 || year < 1) {
    return null;
  }
  final date = DateTime.utc(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return date;
}

bool isAfterDay(DateTime date, DateTime today) {
  final left = DateTime.utc(date.year, date.month, date.day);
  final right = DateTime.utc(today.year, today.month, today.day);
  return left.isAfter(right);
}

String formatPurchaseDay(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

double readStrictlyPositive(String raw) {
  final normalized = raw.trim().replaceAll(' ', '').replaceAll(',', '.');
  return double.parse(normalized);
}

/// Fields already checked by [PortfolioPositionDraft.checked].
class PortfolioPositionDraft {
  const PortfolioPositionDraft({
    required this.symbol,
    required this.quantity,
    required this.purchasePrice,
    required this.purchaseDate,
  });

  final String symbol;
  final double quantity;
  final double purchasePrice;
  final DateTime purchaseDate;

  factory PortfolioPositionDraft.checked({
    required String symbol,
    required String quantity,
    required String purchasePrice,
    required String purchaseDate,
    required DateTime today,
  }) {
    final symbolIssue = symbolError(symbol);
    if (symbolIssue != null) {
      throw InvalidPortfolioInput(symbolIssue);
    }
    final quantityIssue = quantityError(quantity);
    if (quantityIssue != null) {
      throw InvalidPortfolioInput(quantityIssue);
    }
    final priceIssue = purchasePriceError(purchasePrice);
    if (priceIssue != null) {
      throw InvalidPortfolioInput(priceIssue);
    }
    final dateIssue = purchaseDateError(purchaseDate, today);
    if (dateIssue != null) {
      throw InvalidPortfolioInput(dateIssue);
    }
    return PortfolioPositionDraft(
      symbol: requiredSymbol(symbol),
      quantity: readStrictlyPositive(quantity),
      purchasePrice: readStrictlyPositive(purchasePrice),
      purchaseDate: tryParsePurchaseDate(purchaseDate)!,
    );
  }
}

String? _positiveError(
  String raw, {
  required String empty,
  required String number,
  required String positive,
}) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return empty;
  }
  final normalized = trimmed.replaceAll(' ', '').replaceAll(',', '.');
  final value = double.tryParse(normalized);
  if (value == null || value.isNaN || value.isInfinite) {
    return number;
  }
  if (value <= 0) {
    return positive;
  }
  return null;
}
