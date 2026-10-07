import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/portfolio_rules.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_models.dart';

const dcaSymbolRequiredMessage = 'Indiquez un symbole.';

const dcaInitialAmountMessage =
    'Saisissez un montant positif ou laissez 0 si vous souhaitez uniquement des versements mensuels.';

const dcaMonthlyNegativeMessage = 'Le versement ne peut pas être négatif.';

const dcaMonthlyRequiredMessage = 'Indiquez un versement mensuel, ou 0.';

const dcaBothAmountsZeroMessage =
    'Indiquez un montant initial ou un versement mensuel.';

const dcaStartRequiredMessage = 'Indiquez une date de début.';

const dcaEndRequiredMessage = 'Indiquez une date de fin.';

const dcaDateInvalidMessage = 'La date n’est pas valide.';

const dcaDateOrderMessage = 'La date de début doit précéder la date de fin.';

const dcaFutureMessage = 'La simulation ne peut pas dépasser aujourd’hui.';

const dcaEmptyHistoryMessage =
    'Aucun historique n’est disponible pour cette période.';

const dcaUncoveredMessage =
    'La période demandée n’est pas entièrement couverte par l’historique.';

const dcaIncompleteCacheMessage =
    'L’historique enregistré ne couvre pas toute la période. Les cours manquants ne sont pas inventés.';

const dcaUnusablePricesMessage =
    'Les cours disponibles ne permettent pas de calculer la simulation.';

const dcaNoPurchaseMessage =
    'Aucun achat n’a pu être exécuté avant la date de fin.';

const dcaOfflineMessage =
    'L’historique nécessaire n’est pas disponible hors connexion.';

const dcaRemoteErrorMessage =
    'L’historique n’a pas pu être récupéré. Réessayez.';

String? dcaSymbolError(String raw) {
  if (normalizeSymbol(raw).isEmpty) {
    return dcaSymbolRequiredMessage;
  }
  return null;
}

String? dcaInitialAmountError(String raw) {
  final amount = tryReadDcaAmount(raw);
  if (amount == null || amount < 0) {
    return dcaInitialAmountMessage;
  }
  return null;
}

String? dcaMonthlyAmountError(String raw, String initialRaw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return dcaMonthlyRequiredMessage;
  }
  final amount = tryReadDcaAmount(trimmed);
  if (amount == null || amount < 0) {
    return dcaMonthlyNegativeMessage;
  }
  final initial = tryReadDcaAmount(initialRaw);
  if (initial != null && initial == 0 && amount == 0) {
    return dcaBothAmountsZeroMessage;
  }
  return null;
}

String? dcaStartDateError(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return dcaStartRequiredMessage;
  }
  if (tryParsePurchaseDate(trimmed) == null) {
    return dcaDateInvalidMessage;
  }
  return null;
}

String? dcaEndDateError(String raw, String startRaw, DateTime today) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return dcaEndRequiredMessage;
  }
  final end = tryParsePurchaseDate(trimmed);
  if (end == null) {
    return dcaDateInvalidMessage;
  }
  final start = tryParsePurchaseDate(startRaw.trim());
  if (start != null && !start.isBefore(end)) {
    return dcaDateOrderMessage;
  }
  if (isAfterDay(end, calendarDay(today))) {
    return dcaFutureMessage;
  }
  return null;
}

/// Null when [raw] is empty or not a finite number.
double? tryReadDcaAmount(String raw) {
  final normalized = raw.trim().replaceAll(' ', '').replaceAll(',', '.');
  if (normalized.isEmpty) {
    return null;
  }
  final value = double.tryParse(normalized);
  if (value == null || !value.isFinite) {
    return null;
  }
  return value;
}

/// Builds a normalized input, or throws [InvalidDcaInput].
DcaSimulationInput checkedDcaInput({
  required String symbol,
  required String initialAmount,
  required String monthlyAmount,
  required String startDate,
  required String endDate,
  required DateTime today,
}) {
  final symbolIssue = dcaSymbolError(symbol);
  if (symbolIssue != null) {
    throw InvalidDcaInput(symbolIssue);
  }
  final initialIssue = dcaInitialAmountError(initialAmount);
  if (initialIssue != null) {
    throw InvalidDcaInput(initialIssue);
  }
  final monthlyIssue = dcaMonthlyAmountError(monthlyAmount, initialAmount);
  if (monthlyIssue != null) {
    throw InvalidDcaInput(monthlyIssue);
  }
  final startIssue = dcaStartDateError(startDate);
  if (startIssue != null) {
    throw InvalidDcaInput(startIssue);
  }
  final endIssue = dcaEndDateError(endDate, startDate, today);
  if (endIssue != null) {
    throw InvalidDcaInput(endIssue);
  }
  return DcaSimulationInput(
    symbol: requiredSymbol(symbol),
    initialAmount: tryReadDcaAmount(initialAmount)!,
    monthlyAmount: tryReadDcaAmount(monthlyAmount)!,
    startDate: tryParsePurchaseDate(startDate)!,
    endDate: tryParsePurchaseDate(endDate)!,
  );
}

/// Same business rules for an input that did not come from the form.
void requireValidDcaInput(DcaSimulationInput input, DateTime today) {
  if (normalizeSymbol(input.symbol).isEmpty) {
    throw const InvalidDcaInput(dcaSymbolRequiredMessage);
  }
  if (!input.initialAmount.isFinite || input.initialAmount < 0) {
    throw const InvalidDcaInput(dcaInitialAmountMessage);
  }
  if (!input.monthlyAmount.isFinite || input.monthlyAmount < 0) {
    throw const InvalidDcaInput(dcaMonthlyNegativeMessage);
  }
  if (input.initialAmount == 0 && input.monthlyAmount == 0) {
    throw const InvalidDcaInput(dcaBothAmountsZeroMessage);
  }
  final start = calendarDate(input.startDate);
  final end = calendarDate(input.endDate);
  if (!start.isBefore(end)) {
    throw const InvalidDcaInput(dcaDateOrderMessage);
  }
  if (isAfterDay(end, calendarDay(today))) {
    throw const InvalidDcaInput(dcaFutureMessage);
  }
}
