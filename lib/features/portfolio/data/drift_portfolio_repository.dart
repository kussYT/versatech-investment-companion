import 'package:versatech_investment_companion/core/database/app_database.dart';
import 'package:versatech_investment_companion/core/database/daos/portfolio_position_dao.dart';
import 'package:versatech_investment_companion/core/database/financial_values.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/entities/portfolio_position.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/portfolio_rules.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/repositories/portfolio_repository.dart';

class DriftPortfolioRepository implements PortfolioRepository {
  DriftPortfolioRepository(
    this._dao, {
    Clock? clock,
  }) : _clock = clock ?? const SystemClock();

  final PortfolioPositionDao _dao;
  final Clock _clock;

  @override
  Future<List<PortfolioPosition>> getPositions() {
    return _guard(() async {
      final rows = await _dao.getAll();
      return [for (final row in rows) _toPosition(row)];
    });
  }

  @override
  Stream<List<PortfolioPosition>> watchPositions() {
    return _dao.watchAll().map(
          (rows) => [for (final row in rows) _toPosition(row)],
        );
  }

  @override
  Future<List<PortfolioPosition>> positionsFor(String symbol) {
    final normalized = _readSymbol(symbol);
    if (normalized == null) {
      return Future.value(const []);
    }
    return _guard(() async {
      final rows = await _dao.findBySymbol(normalized);
      return [for (final row in rows) _toPosition(row)];
    });
  }

  @override
  Future<PortfolioPosition> addPosition(PortfolioPositionDraft draft) async {
    final checked = _checked(draft);
    final id = await _guard(() {
      return _dao.insertPosition(
        symbol: checked.symbol,
        quantity: FinancialValues.toSql(checked.quantity),
        purchasePrice: FinancialValues.toSql(checked.purchasePrice),
        purchaseDate: checked.purchaseDate,
        createdAt: _clock.now(),
      );
    });
    final stored = await _guard(() => _dao.findById(id));
    if (stored == null) {
      throw const PortfolioPersistenceException();
    }
    return _toPosition(stored);
  }

  @override
  Future<void> removePosition(int id) {
    return _guard(() async {
      await _dao.deleteById(id);
    });
  }

  @override
  Future<void> updatePosition({
    required int id,
    required PortfolioPositionDraft draft,
  }) {
    final checked = _checked(draft);
    return _guard(() async {
      await _dao.updatePosition(
        id: id,
        symbol: checked.symbol,
        quantity: FinancialValues.toSql(checked.quantity),
        purchasePrice: FinancialValues.toSql(checked.purchasePrice),
        purchaseDate: checked.purchaseDate,
      );
    });
  }

  PortfolioPositionDraft _checked(PortfolioPositionDraft draft) {
    final today = calendarDay(_clock.now());
    final symbolIssue = symbolError(draft.symbol);
    if (symbolIssue != null) {
      throw InvalidPortfolioInput(symbolIssue);
    }
    if (!draft.quantity.isFinite || draft.quantity <= 0) {
      throw const InvalidPortfolioInput(quantityPositiveMessage);
    }
    if (!draft.purchasePrice.isFinite || draft.purchasePrice <= 0) {
      throw const InvalidPortfolioInput(pricePositiveMessage);
    }
    if (isAfterDay(draft.purchaseDate, today)) {
      throw const InvalidPortfolioInput(dateFutureMessage);
    }
    return PortfolioPositionDraft(
      symbol: requiredSymbol(draft.symbol),
      quantity: draft.quantity,
      purchasePrice: draft.purchasePrice,
      purchaseDate: DateTime.utc(
        draft.purchaseDate.year,
        draft.purchaseDate.month,
        draft.purchaseDate.day,
      ),
    );
  }

  String? _readSymbol(String symbol) {
    try {
      return requiredSymbol(symbol);
    } on InvalidMarketDataException {
      return null;
    }
  }

  PortfolioPosition _toPosition(PortfolioPositionRow row) {
    final purchased = row.purchaseDate.toUtc();
    return PortfolioPosition(
      id: row.id,
      symbol: row.symbol,
      quantity: FinancialValues.fromSql(row.quantity),
      purchasePrice: FinancialValues.fromSql(row.purchasePrice),
      purchaseDate: DateTime.utc(
        purchased.year,
        purchased.month,
        purchased.day,
      ),
      createdAt: row.createdAt.toUtc(),
    );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on InvalidPortfolioInput {
      rethrow;
    } on PortfolioPersistenceException {
      rethrow;
    } catch (_) {
      throw const PortfolioPersistenceException();
    }
  }
}
