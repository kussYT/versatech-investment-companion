import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:versatech_investment_companion/app/theme/app_colors.dart';
import 'package:versatech_investment_companion/features/explorer/application/explorer_search_controller.dart';
import 'package:versatech_investment_companion/features/explorer/application/explorer_search_state.dart';
import 'package:versatech_investment_companion/features/explorer/presentation/explorer_messages.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';

class ExplorerScreen extends ConsumerStatefulWidget {
  const ExplorerScreen({super.key});

  @override
  ConsumerState<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends ConsumerState<ExplorerScreen> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    final query = ref.read(explorerSearchControllerProvider).query;
    _queryController = TextEditingController(text: query);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(explorerSearchControllerProvider);
    final refreshing = state is ExplorerReady && state.isRefreshing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  'Parcourez des actions et des ETF afin d\'en comprendre les caractéristiques.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: TextField(
                  controller: _queryController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: 'Rechercher une action ou un ETF',
                    hintText: 'Symbole ou nom',
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _refreshButton(state, refreshing),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                  ),
                  onChanged: (value) {
                    ref
                        .read(explorerSearchControllerProvider.notifier)
                        .onQueryChanged(value);
                  },
                ),
              ),
              Expanded(child: _ExplorerBody(state: state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _refreshButton(ExplorerSearchState state, bool refreshing) {
    if (state is ExplorerInitial) {
      return null;
    }
    final busy = state is ExplorerLoading || refreshing;
    return IconButton(
      tooltip: 'Actualiser',
      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      onPressed: busy
          ? null
          : () {
              unawaited(
                ref.read(explorerSearchControllerProvider.notifier).refresh(),
              );
            },
      icon: busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
    );
  }
}

class _ExplorerBody extends StatelessWidget {
  const _ExplorerBody({required this.state});

  final ExplorerSearchState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ExplorerInitial() => const _StatusMessage(
          icon: Icons.travel_explore_outlined,
          message: 'Recherchez une action ou un ETF',
        ),
      ExplorerLoading() => const _StatusMessage(
          icon: Icons.hourglass_top_outlined,
          message: 'Recherche en cours',
          progress: true,
        ),
      ExplorerFailureState(:final failure) => _StatusMessage(
          icon: Icons.error_outline,
          message: explorerFailureMessage(failure),
          actionLabel: 'Réessayer',
        ),
      ExplorerReady ready => _ResultList(state: ready),
    };
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({required this.state});

  final ExplorerReady state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final syncStatus = explorerSyncStatus(state);
    final refreshFailure = state.refreshFailure;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        if (state.isRefreshing)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LinearProgressIndicator(),
          ),
        if (syncStatus != null)
          _InfoBanner(
            icon: Icons.cloud_off_outlined,
            message: syncStatus,
          ),
        if (refreshFailure != null)
          _InfoBanner(
            icon: Icons.error_outline,
            message: explorerFailureMessage(refreshFailure),
          ),
        if (state.isEmpty)
          const _StatusMessage(
            icon: Icons.search_off,
            message: 'Aucun actif trouvé',
            embedded: true,
          )
        else
          for (final asset in state.assets) ...[
            _AssetCard(asset: asset),
            const SizedBox(height: 12),
          ],
        if (!state.isEmpty)
          Text(
            '${state.assets.length} résultat${state.assets.length > 1 ? 's' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);
    final isEtf = asset.type == AssetType.etf;
    final typeColor = isEtf ? semantic.violet : theme.colorScheme.primary;
    final typeIcon = isEtf ? Icons.pie_chart_outline : Icons.show_chart;
    final place = asset.exchange.trim();
    final currency = asset.currency.trim();
    final details = [
      if (place.isNotEmpty) place,
      if (currency.isNotEmpty) currency,
    ].join(' · ');

    return Semantics(
      button: true,
      label: '${asset.symbol}, ${asset.name}, ${assetTypeLabel(asset.type)}',
      child: Card(
        child: InkWell(
          key: ValueKey('asset-${asset.symbol}'),
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            final type = asset.type == AssetType.etf ? 'etf' : 'stock';
            final symbol = Uri.encodeComponent(asset.symbol);
            context.push('/explorer/$symbol?type=$type');
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.symbol,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          asset.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (details.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            details,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 16, color: typeColor),
                          const SizedBox(width: 4),
                          Text(
                            assetTypeLabel(asset.type),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusMessage extends ConsumerWidget {
  const _StatusMessage({
    required this.icon,
    required this.message,
    this.progress = false,
    this.actionLabel,
    this.embedded = false,
  });

  final IconData icon;
  final String message;
  final bool progress;
  final String? actionLabel;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final content = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (progress)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: CircularProgressIndicator(),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Icon(icon, size: 36, color: theme.colorScheme.primary),
            ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(48, 48),
              ),
              onPressed: () {
                unawaited(
                  ref.read(explorerSearchControllerProvider.notifier).refresh(),
                );
              },
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );

    if (embedded) {
      return content;
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [content],
    );
  }
}
