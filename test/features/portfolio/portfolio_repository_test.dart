import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:versatech_investment_companion/core/database/app_database.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/portfolio/data/drift_portfolio_repository.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/portfolio_rules.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/repositories/portfolio_repository.dart';

void main() {
  late AppDatabase database;
  late DriftPortfolioRepository repository;
  late FixedClock clock;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime.utc(2024, 6, 3, 12));
    repository = DriftPortfolioRepository(
      database.portfolioPositionDao,
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

  test('adds a position and reads it back', () async {
    final stored = await repository.addPosition(_draft());

    expect(stored.symbol, 'AAPL');
    expect(stored.quantity, 2);
    expect(stored.purchasePrice, 150);
    expect(stored.purchaseDate, DateTime.utc(2024, 6, 3));
    expect(await repository.getPositions(), [stored]);
  });

  test('removes one position and ignores an absent id', () async {
    final stored = await repository.addPosition(_draft());
    await repository.removePosition(stored.id);
    await repository.removePosition(stored.id);

    expect(await repository.getPositions(), isEmpty);
  });

  test('keeps several positions for the same symbol', () async {
    await repository.addPosition(_draft(quantity: 2, purchasePrice: 150));
    await repository.addPosition(_draft(quantity: 1, purchasePrice: 170));

    final stored = await repository.positionsFor('aapl');
    expect(stored, hasLength(2));
    expect(
      stored.map((position) => position.purchasePrice),
      [150, 170],
    );
  });

  test('normalizes the symbol before insert and lookup', () async {
    await repository.addPosition(_draft(symbol: ' aapl '));

    final stored = await repository.positionsFor('AAPL');
    expect(stored, hasLength(1));
    expect(stored.single.symbol, 'AAPL');
    expect(await repository.positionsFor(' aapl '), stored);
  });

  test('rejects an invalid position without writing', () async {
    await expectLater(
      repository.addPosition(
        _draft(quantity: 0),
      ),
      throwsA(isA<InvalidPortfolioInput>()),
    );
    await expectLater(
      repository.addPosition(
        _draft(purchasePrice: -5),
      ),
      throwsA(isA<InvalidPortfolioInput>()),
    );
    await expectLater(
      repository.addPosition(
        PortfolioPositionDraft(
          symbol: 'AAPL',
          quantity: 1,
          purchasePrice: 10,
          purchaseDate: DateTime.utc(2024, 6, 4),
        ),
      ),
      throwsA(isA<InvalidPortfolioInput>()),
    );
    expect(await repository.getPositions(), isEmpty);
    expect(
      const InvalidPortfolioInput(quantityPositiveMessage).toString(),
      'InvalidPortfolioInput',
    );
  });

  test('updates a stored position', () async {
    final stored = await repository.addPosition(_draft());
    await repository.updatePosition(
      id: stored.id,
      draft: _draft(quantity: 4, purchasePrice: 90),
    );

    final updated = await repository.getPositions();
    expect(updated.single.quantity, 4);
    expect(updated.single.purchasePrice, 90);
    expect(updated.single.id, stored.id);
  });

  test('publishes position changes to watchers', () async {
    final seen = <int>[];
    final subscription = repository.watchPositions().listen((positions) {
      seen.add(positions.length);
    });
    await pumpEventQueue();
    expect(seen, [0]);

    final stored = await repository.addPosition(_draft());
    await pumpEventQueue();
    expect(seen.last, 1);

    await repository.removePosition(stored.id);
    await pumpEventQueue();
    expect(seen.last, 0);
    await subscription.cancel();
  });

  test('keeps positions after the database is closed and reopened', () async {
    final directory = await Directory.systemTemp.createTemp(
      'versatech_portfolio_',
    );
    final file = File(p.join(directory.path, 'portfolio.sqlite'));
    final firstDatabase = AppDatabase(NativeDatabase(file));
    final first = DriftPortfolioRepository(
      firstDatabase.portfolioPositionDao,
      clock: clock,
    );
    await first.addPosition(_draft(symbol: ' aapl '));
    await first.addPosition(_draft(symbol: 'MSFT', quantity: 1));
    await firstDatabase.close();

    final secondDatabase = AppDatabase(NativeDatabase(file));
    final second =
        DriftPortfolioRepository(secondDatabase.portfolioPositionDao);
    expect(await second.positionsFor('AAPL'), hasLength(1));
    expect(await second.getPositions(), hasLength(2));
    final msft = (await second.positionsFor('MSFT')).single;
    await second.removePosition(msft.id);
    await secondDatabase.close();

    final thirdDatabase = AppDatabase(NativeDatabase(file));
    final third = DriftPortfolioRepository(thirdDatabase.portfolioPositionDao);
    expect(await third.getPositions(), hasLength(1));
    expect((await third.getPositions()).single.symbol, 'AAPL');
    await thirdDatabase.close();
    await directory.delete(recursive: true);
  });

  test('reports a closed database without exposing the storage error',
      () async {
    expect(await repository.getPositions(), isEmpty);
    await database.close();

    await expectLater(
      repository.addPosition(_draft()),
      throwsA(isA<PortfolioPersistenceException>()),
    );
    expect(
      const PortfolioPersistenceException().toString(),
      'PortfolioPersistenceException',
    );
    expect(
      const PortfolioPersistenceException().toString(),
      isNot(contains('SQL')),
    );
  });
}

PortfolioPositionDraft _draft({
  String symbol = 'AAPL',
  double quantity = 2,
  double purchasePrice = 150,
}) {
  return PortfolioPositionDraft(
    symbol: symbol,
    quantity: quantity,
    purchasePrice: purchasePrice,
    purchaseDate: DateTime.utc(2024, 6, 3),
  );
}
