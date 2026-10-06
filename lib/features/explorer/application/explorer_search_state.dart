import 'package:flutter/foundation.dart';
import 'package:versatech_investment_companion/core/errors/failure.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cached_result.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';

sealed class ExplorerSearchState {
  const ExplorerSearchState();

  String get query;
}

final class ExplorerInitial extends ExplorerSearchState {
  const ExplorerInitial();

  @override
  String get query => '';
}

final class ExplorerLoading extends ExplorerSearchState {
  const ExplorerLoading(this.query);

  @override
  final String query;

  @override
  bool operator ==(Object other) {
    return other is ExplorerLoading && other.query == query;
  }

  @override
  int get hashCode => query.hashCode;
}

final class ExplorerReady extends ExplorerSearchState {
  const ExplorerReady({
    required this.query,
    required this.assets,
    required this.origin,
    required this.lastUpdatedAt,
    required this.isStale,
    this.remoteFailure,
    this.isRefreshing = false,
    this.refreshFailure,
  });

  @override
  final String query;
  final List<Asset> assets;
  final DataOrigin origin;
  final DateTime? lastUpdatedAt;
  final bool isStale;
  final Failure? remoteFailure;
  final bool isRefreshing;
  final Failure? refreshFailure;

  bool get isEmpty => assets.isEmpty;

  bool get showsStoredData => origin == DataOrigin.cache || isStale;

  ExplorerReady copyWith({
    bool? isRefreshing,
    Failure? refreshFailure,
    bool clearRefreshFailure = false,
  }) {
    return ExplorerReady(
      query: query,
      assets: assets,
      origin: origin,
      lastUpdatedAt: lastUpdatedAt,
      isStale: isStale,
      remoteFailure: remoteFailure,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshFailure:
          clearRefreshFailure ? null : refreshFailure ?? this.refreshFailure,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExplorerReady &&
        other.query == query &&
        listEquals(other.assets, assets) &&
        other.origin == origin &&
        other.lastUpdatedAt == lastUpdatedAt &&
        other.isStale == isStale &&
        other.remoteFailure == remoteFailure &&
        other.isRefreshing == isRefreshing &&
        other.refreshFailure == refreshFailure;
  }

  @override
  int get hashCode => Object.hash(
        query,
        Object.hashAll(assets),
        origin,
        lastUpdatedAt,
        isStale,
        remoteFailure,
        isRefreshing,
        refreshFailure,
      );
}

final class ExplorerFailureState extends ExplorerSearchState {
  const ExplorerFailureState({
    required this.query,
    required this.failure,
  });

  @override
  final String query;
  final Failure failure;

  @override
  bool operator ==(Object other) {
    return other is ExplorerFailureState &&
        other.query == query &&
        other.failure == failure;
  }

  @override
  int get hashCode => Object.hash(query, failure);
}
