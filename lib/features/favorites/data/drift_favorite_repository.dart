import 'package:versatech_investment_companion/core/database/app_database.dart';
import 'package:versatech_investment_companion/core/database/daos/favorite_dao.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/favorites/domain/entities/favorite.dart';
import 'package:versatech_investment_companion/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';

class DriftFavoriteRepository implements FavoriteRepository {
  DriftFavoriteRepository(
    this._dao, {
    Clock? clock,
  }) : _clock = clock ?? const SystemClock();

  final FavoriteDao _dao;
  final Clock _clock;

  @override
  Future<List<Favorite>> getFavorites() {
    return _guard(() async {
      final rows = await _dao.getAll();
      return [for (final row in rows) _toFavorite(row)];
    });
  }

  @override
  Stream<List<Favorite>> watchFavorites() {
    return _dao.watchAll().map(
          (rows) => [for (final row in rows) _toFavorite(row)],
        );
  }

  @override
  Future<bool> isFavorite(String symbol) {
    final normalized = _readSymbol(symbol);
    if (normalized == null) {
      return Future.value(false);
    }
    return _guard(() async {
      final row = await _dao.findBySymbol(normalized);
      return row != null;
    });
  }

  @override
  Future<void> addFavorite(String symbol) async {
    final normalized = requiredSymbol(symbol);
    await _guard(() async {
      await _dao.insertFavorite(
        symbol: normalized,
        createdAt: _clock.now(),
      );
    });
  }

  @override
  Future<void> removeFavorite(String symbol) async {
    final normalized = _readSymbol(symbol);
    if (normalized == null) {
      return;
    }
    await _guard(() async {
      await _dao.deleteBySymbol(normalized);
    });
  }

  @override
  Future<bool> toggleFavorite(String symbol) async {
    final normalized = requiredSymbol(symbol);
    return _guard(() async {
      final existing = await _dao.findBySymbol(normalized);
      if (existing != null) {
        await _dao.deleteBySymbol(normalized);
        return false;
      }
      await _dao.insertFavorite(
        symbol: normalized,
        createdAt: _clock.now(),
      );
      return true;
    });
  }

  String? _readSymbol(String symbol) {
    try {
      return requiredSymbol(symbol);
    } on InvalidMarketDataException {
      return null;
    }
  }

  Favorite _toFavorite(FavoriteRow row) {
    return Favorite(
      symbol: row.symbol,
      createdAt: row.createdAt.toUtc(),
    );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FavoritePersistenceException {
      rethrow;
    } catch (_) {
      throw const FavoritePersistenceException();
    }
  }
}
