import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:versatech_investment_companion/core/database/app_database.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/favorites/data/drift_favorite_repository.dart';
import 'package:versatech_investment_companion/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';

void main() {
  late AppDatabase database;
  late DriftFavoriteRepository repository;
  late FixedClock clock;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime.utc(2024, 6, 3, 12));
    repository = DriftFavoriteRepository(
      database.favoriteDao,
      clock: clock,
    );
  });

  tearDown(() async {
    try {
      await database.close();
    } on Object {
      // The failure test already closed the connection.
    }
  });

  test('isFavorite is false until a symbol is stored', () async {
    expect(await repository.isFavorite('AAPL'), isFalse);
    expect(await repository.getFavorites(), isEmpty);
  });

  test('inserts a favorite and reads it back', () async {
    await repository.addFavorite('AAPL');

    final stored = await repository.getFavorites();
    expect(stored, hasLength(1));
    expect(stored.single.symbol, 'AAPL');
    expect(stored.single.createdAt, DateTime.utc(2024, 6, 3, 12));
    expect(await repository.isFavorite('AAPL'), isTrue);
  });

  test('normalizes the symbol before insert, compare and read', () async {
    await repository.addFavorite(' aapl ');

    expect(await repository.isFavorite('AAPL'), isTrue);
    expect(await repository.isFavorite('aapl'), isTrue);
    expect((await repository.getFavorites()).single.symbol, 'AAPL');
    expect(await database.favoriteDao.getAll(), hasLength(1));
  });

  test('does not duplicate an idempotent add', () async {
    await repository.addFavorite('AAPL');
    clock.set(DateTime.utc(2024, 7, 1));
    await repository.addFavorite(' aapl ');

    final stored = await repository.getFavorites();
    expect(stored, hasLength(1));
    expect(stored.single.createdAt, DateTime.utc(2024, 6, 3, 12));
  });

  test('removes a favorite', () async {
    await repository.addFavorite('AAPL');
    await repository.removeFavorite(' aapl ');

    expect(await repository.isFavorite('AAPL'), isFalse);
    expect(await repository.getFavorites(), isEmpty);
  });

  test('removing an absent symbol is safe', () async {
    await repository.removeFavorite('MSFT');
    await repository.removeFavorite('   ');

    expect(await repository.getFavorites(), isEmpty);
  });

  test('lists every favorite with the newest first', () async {
    await repository.addFavorite('AAPL');
    clock.set(DateTime.utc(2024, 6, 4, 8));
    await repository.addFavorite('SPY');

    expect(
      (await repository.getFavorites()).map((favorite) => favorite.symbol),
      ['SPY', 'AAPL'],
    );
  });

  test('rejects an empty symbol without writing', () async {
    await expectLater(
      repository.addFavorite('   '),
      throwsA(isA<InvalidMarketDataException>()),
    );
    expect(await repository.isFavorite(''), isFalse);
    expect(await database.favoriteDao.getAll(), isEmpty);
  });

  test('publishes favorite changes to watchers', () async {
    final seen = <List<String>>[];
    final subscription = repository.watchFavorites().listen((favorites) {
      seen.add([for (final favorite in favorites) favorite.symbol]);
    });
    await pumpEventQueue();
    expect(seen, [<String>[]]);

    await repository.addFavorite('AAPL');
    await pumpEventQueue();
    expect(seen.last, ['AAPL']);
    expect(await repository.isFavorite('AAPL'), isTrue);

    await repository.removeFavorite('AAPL');
    await pumpEventQueue();
    expect(seen.last, isEmpty);
    expect(await repository.isFavorite('AAPL'), isFalse);
    await subscription.cancel();
  });

  test('toggle follows the stored state', () async {
    expect(await repository.toggleFavorite('AAPL'), isTrue);
    expect(await repository.isFavorite('AAPL'), isTrue);
    expect(await repository.toggleFavorite(' aapl '), isFalse);
    expect(await repository.isFavorite('AAPL'), isFalse);
  });

  test('keeps favorites after the database is closed and reopened', () async {
    final directory = await Directory.systemTemp.createTemp(
      'versatech_favorites_',
    );
    final file = File(p.join(directory.path, 'favorites.sqlite'));
    final firstDatabase = AppDatabase(NativeDatabase(file));
    final first = DriftFavoriteRepository(
      firstDatabase.favoriteDao,
      clock: clock,
    );
    await first.addFavorite(' aapl ');
    clock.set(DateTime.utc(2024, 6, 4));
    await first.addFavorite('SPY');
    await firstDatabase.close();

    final secondDatabase = AppDatabase(NativeDatabase(file));
    final second = DriftFavoriteRepository(secondDatabase.favoriteDao);
    expect(await second.isFavorite('AAPL'), isTrue);
    expect(
      (await second.getFavorites()).map((favorite) => favorite.symbol),
      ['SPY', 'AAPL'],
    );
    await second.removeFavorite('SPY');
    await secondDatabase.close();

    final thirdDatabase = AppDatabase(NativeDatabase(file));
    final third = DriftFavoriteRepository(thirdDatabase.favoriteDao);
    expect(await third.getFavorites(), hasLength(1));
    expect((await third.getFavorites()).single.symbol, 'AAPL');
    await thirdDatabase.close();
    await directory.delete(recursive: true);
  });

  test('reports a closed database without exposing the storage error',
      () async {
    expect(await repository.getFavorites(), isEmpty);
    await database.close();

    await expectLater(
      repository.addFavorite('AAPL'),
      throwsA(isA<FavoritePersistenceException>()),
    );
    expect(
      const FavoritePersistenceException().toString(),
      'FavoritePersistenceException',
    );
    expect(
      const FavoritePersistenceException().toString(),
      isNot(contains('SQL')),
    );
  });
}
