import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatech_investment_companion/core/database/app_database_provider.dart';
import 'package:versatech_investment_companion/features/favorites/data/drift_favorite_repository.dart';
import 'package:versatech_investment_companion/features/favorites/domain/entities/favorite.dart';
import 'package:versatech_investment_companion/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:versatech_investment_companion/features/market_data/data/datasources/local_market_data_source.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/cached_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';

enum FavoriteMark { unknown, absent, present }

/// A favorite plus market metadata already stored on the device.
class FavoriteEntry {
  const FavoriteEntry({
    required this.favorite,
    this.name,
    this.type,
    this.exchange,
    this.currency,
  });

  final Favorite favorite;
  final String? name;
  final AssetType? type;
  final String? exchange;
  final String? currency;
}

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return DriftFavoriteRepository(
    ref.watch(favoriteDaoProvider),
    clock: ref.watch(clockProvider),
  );
});

final favoritesProvider = StreamProvider<List<Favorite>>((ref) {
  return ref.watch(favoriteRepositoryProvider).watchFavorites();
});

final favoriteMarkProvider = Provider.family<FavoriteMark, String>((ref, raw) {
  final symbol = normalizeSymbol(raw);
  if (symbol.isEmpty) {
    return FavoriteMark.absent;
  }
  final favorites = ref.watch(favoritesProvider);
  return favorites.when(
    data: (items) => items.any((item) => item.symbol == symbol)
        ? FavoriteMark.present
        : FavoriteMark.absent,
    loading: () => FavoriteMark.unknown,
    error: (_, __) => FavoriteMark.unknown,
  );
});

final favoriteEntriesProvider = StreamProvider<List<FavoriteEntry>>((ref) {
  final repository = ref.watch(favoriteRepositoryProvider);
  final local = ref.watch(localMarketDataSourceProvider);
  return repository.watchFavorites().asyncMap(
        (favorites) => _entries(favorites, local),
      );
});

Future<List<FavoriteEntry>> _entries(
  List<Favorite> favorites,
  LocalMarketDataSource local,
) async {
  if (favorites.isEmpty) {
    return const [];
  }

  final assets = await _assetsBySymbol(local, favorites);
  final entries = <FavoriteEntry>[];
  for (final favorite in favorites) {
    final asset = assets[favorite.symbol];
    if (asset != null) {
      entries.add(
        FavoriteEntry(
          favorite: favorite,
          name: _present(asset.name),
          type: asset.type,
          exchange: _present(asset.exchange),
          currency: _present(asset.currency),
        ),
      );
      continue;
    }

    final profile = await _profileOrNull(local, favorite.symbol);
    entries.add(
      FavoriteEntry(
        favorite: favorite,
        name: _present(profile?.companyName),
        exchange: _present(profile?.exchange),
        currency: _present(profile?.currency),
      ),
    );
  }
  return entries;
}

Future<Map<String, Asset>> _assetsBySymbol(
  LocalMarketDataSource local,
  List<Favorite> favorites,
) async {
  try {
    final stored = await local.assetsBySymbols([
      for (final favorite in favorites) favorite.symbol,
    ]);
    return {for (final asset in stored) asset.symbol: asset};
  } catch (_) {
    return const {};
  }
}

Future<AssetProfile?> _profileOrNull(
  LocalMarketDataSource local,
  String symbol,
) async {
  try {
    return await local.readProfile(symbol);
  } catch (_) {
    return null;
  }
}

String? _present(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
