import 'package:versatech_investment_companion/features/portfolio/domain/entities/portfolio_position.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/portfolio_rules.dart';

/// Local fictitious positions. Implementations must not call a market API.
abstract interface class PortfolioRepository {
  Future<List<PortfolioPosition>> getPositions();

  Stream<List<PortfolioPosition>> watchPositions();

  Future<List<PortfolioPosition>> positionsFor(String symbol);

  Future<PortfolioPosition> addPosition(PortfolioPositionDraft draft);

  Future<void> removePosition(int id);

  Future<void> updatePosition({
    required int id,
    required PortfolioPositionDraft draft,
  });
}

/// A local write or read failed. [userMessage] is safe to show as-is.
final class PortfolioPersistenceException implements Exception {
  const PortfolioPersistenceException();

  static const userMessage =
      'La position n’a pas pu être enregistrée. Réessayez.';

  @override
  String toString() => 'PortfolioPersistenceException';
}
