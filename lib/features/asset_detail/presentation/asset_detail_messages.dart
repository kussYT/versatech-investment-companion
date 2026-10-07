import 'package:versatech_investment_companion/core/errors/failure.dart';
import 'package:versatech_investment_companion/features/asset_detail/application/asset_detail_state.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';

const variationExplanation =
    'La variation en pourcentage compare le dernier prix connu au cours précédent. Elle décrit un écart déjà constaté, pas une prévision.';

const historyExplanation =
    'L’historique montre les cours de clôture passés. Une hausse passée ne garantit pas une hausse future.';

const detailDisclaimer =
    'Ces informations aident à lire une action ou un ETF. Elles ne constituent pas un conseil d’investissement.';

String assetTypeLabel(AssetType type) {
  return switch (type) {
    AssetType.stock => 'Action',
    AssetType.etf => 'ETF',
  };
}

String assetDetailFailureMessage(Failure failure) {
  return switch (failure.code) {
    FailureCode.networkUnavailable =>
      'Connexion indisponible. Cette partie n’a pas pu être mise à jour.',
    FailureCode.timeout => 'Le délai de réponse est dépassé pour cette partie.',
    FailureCode.rateLimited =>
      'Le quota de l’API est atteint. Cette partie n’a pas pu être actualisée.',
    FailureCode.unauthorized => 'L’accès au service de données est refusé.',
    FailureCode.missingApiKey =>
      'La clé API n’est pas configurée. Cette partie reste indisponible.',
    FailureCode.unknownRemote =>
      'Le service de données est momentanément indisponible.',
    FailureCode.invalidResponse => 'Les données reçues sont inutilisables.',
    FailureCode.notFound =>
      'Cette information est introuvable pour ce symbole.',
  };
}

String formatDetailAmount(double value) {
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

String formatSignedAmount(double value) {
  final amount = formatDetailAmount(value);
  if (amount.startsWith('-') || amount == '0.00' || amount == '—') {
    return amount;
  }
  return '+$amount';
}

String formatSignedPercent(double value) {
  return '${formatSignedAmount(value)} %';
}

String formatDetailTimestamp(DateTime value) {
  final utc = value.toUtc();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(utc.day)}/${two(utc.month)}/${utc.year} '
      '${two(utc.hour)}:${two(utc.minute)} UTC';
}

String formatDetailDate(DateTime value) {
  final utc = value.toUtc();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(utc.day)}/${two(utc.month)}/${utc.year}';
}

String? sectionSyncLabel(AssetSection<Object?> section) {
  final stored = section.origin == DataOrigin.cache || section.isStale;
  if (!stored || section.phase != SectionPhase.ready) {
    return null;
  }
  final when = section.lastUpdatedAt;
  final offline = section.remoteFailure?.code == FailureCode.networkUnavailable;
  if (when == null) {
    return offline
        ? 'Hors connexion — données enregistrées'
        : 'Données enregistrées';
  }
  final formatted = formatDetailTimestamp(when);
  if (offline) {
    return 'Hors connexion — données du $formatted';
  }
  return 'Données enregistrées — mise à jour le $formatted';
}

String variationLabel(double change, double changePercent) {
  final direction = change != 0 ? change : changePercent;
  if (direction > 0) {
    return 'Hausse';
  }
  if (direction < 0) {
    return 'Baisse';
  }
  return 'Stable';
}
