import 'package:versatech_investment_companion/features/favorites/domain/entities/favorite.dart';

/// Local favorites. Implementations must not call a market-data API.
abstract interface class FavoriteRepository {
  Future<List<Favorite>> getFavorites();

  Stream<List<Favorite>> watchFavorites();

  Future<bool> isFavorite(String symbol);

  Future<void> addFavorite(String symbol);

  Future<void> removeFavorite(String symbol);

  /// Returns whether [symbol] is a favorite after the change.
  Future<bool> toggleFavorite(String symbol);
}

/// A local write or read failed. [userMessage] is safe to show as-is.
final class FavoritePersistenceException implements Exception {
  const FavoritePersistenceException();

  static const userMessage = 'Le favori n’a pas pu être enregistré. Réessayez.';

  @override
  String toString() => 'FavoritePersistenceException';
}
