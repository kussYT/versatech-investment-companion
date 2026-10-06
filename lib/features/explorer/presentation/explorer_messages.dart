import 'package:versatech_investment_companion/core/errors/failure.dart';
import 'package:versatech_investment_companion/features/explorer/application/explorer_search_state.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';

String explorerFailureMessage(Failure failure) {
  return switch (failure.code) {
    FailureCode.networkUnavailable =>
      'Connexion indisponible. Les données distantes ne peuvent pas être récupérées.',
    FailureCode.timeout =>
      'Le délai de réponse est dépassé. Réessayez dans un instant.',
    FailureCode.rateLimited =>
      'Le quota de l’API est atteint. Patientez avant une nouvelle recherche.',
    FailureCode.unauthorized => 'L’accès au service de données est refusé.',
    FailureCode.missingApiKey =>
      'La clé API n’est pas configurée. La recherche distante est indisponible.',
    FailureCode.unknownRemote =>
      'Le service de données est momentanément indisponible.',
    FailureCode.invalidResponse => 'Les données reçues sont inutilisables.',
    FailureCode.notFound => 'Aucun actif ne correspond à cette recherche.',
  };
}

String assetTypeLabel(AssetType type) {
  return switch (type) {
    AssetType.stock => 'Action',
    AssetType.etf => 'ETF',
  };
}

String formatExplorerTimestamp(DateTime value) {
  final utc = value.toUtc();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(utc.day)}/${two(utc.month)}/${utc.year} '
      '${two(utc.hour)}:${two(utc.minute)} UTC';
}

String? explorerSyncStatus(ExplorerReady state) {
  if (!state.showsStoredData) {
    return null;
  }
  final when = state.lastUpdatedAt == null
      ? null
      : formatExplorerTimestamp(state.lastUpdatedAt!);
  final offline = state.remoteFailure?.code == FailureCode.networkUnavailable ||
      state.refreshFailure?.code == FailureCode.networkUnavailable;
  if (offline) {
    if (when == null) {
      return 'Hors connexion — données enregistrées';
    }
    return 'Hors connexion — données du $when';
  }
  if (when == null) {
    return 'Données enregistrées';
  }
  return 'Données enregistrées — dernière mise à jour : $when';
}
