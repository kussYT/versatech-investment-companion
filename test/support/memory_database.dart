import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versatech_investment_companion/core/database/app_database.dart';
import 'package:versatech_investment_companion/core/database/app_database_provider.dart';
import 'package:versatech_investment_companion/features/favorites/application/favorites_providers.dart';
import 'package:versatech_investment_companion/features/favorites/domain/entities/favorite.dart';
import 'package:versatech_investment_companion/features/favorites/domain/repositories/favorite_repository.dart';

/// In-memory database so widget tests never open the on-device cache file.
Override memoryDatabaseOverride() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return appDatabaseProvider.overrideWith((ref) {
    final database = AppDatabase(NativeDatabase.memory());
    ref.onDispose(database.close);
    return database;
  });
}

/// Favorites that do not open Drift. Screen tests that are not about
/// favorites use this so disposing the tree does not leave a Drift timer.
Override emptyFavoritesOverride() {
  return favoriteRepositoryProvider.overrideWithValue(
    const EmptyFavoriteRepository(),
  );
}

/// Drift schedules a zero-duration timer when a watched query is cancelled.
/// Dispose the tree and flush that timer before the test ends.
Future<void> settleDriftStreams(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  // Drift closes a watched query with a zero-duration timer. A plain pump
  // does not elapse that timer when it was created during the dispose frame.
  await tester.pump(const Duration(milliseconds: 1));
}

final class EmptyFavoriteRepository implements FavoriteRepository {
  const EmptyFavoriteRepository();

  @override
  Future<List<Favorite>> getFavorites() async => const [];

  @override
  Stream<List<Favorite>> watchFavorites() => Stream.value(const []);

  @override
  Future<bool> isFavorite(String symbol) async => false;

  @override
  Future<void> addFavorite(String symbol) async {}

  @override
  Future<void> removeFavorite(String symbol) async {}

  @override
  Future<bool> toggleFavorite(String symbol) async => false;
}
