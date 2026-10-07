import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:versatech_investment_companion/app/theme/app_colors.dart';
import 'package:versatech_investment_companion/features/portfolio/application/portfolio_providers.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/entities/portfolio_position.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/portfolio_math.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/portfolio_rules.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:versatech_investment_companion/features/portfolio/presentation/allocation_chart.dart';
import 'package:versatech_investment_companion/features/portfolio/presentation/portfolio_messages.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(portfolioControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portefeuille'),
        actions: [
          IconButton(
            key: const Key('portfolio-refresh'),
            tooltip: 'Actualiser les cotations',
            style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: state.status == PortfolioLoadStatus.ready
                ? () => unawaited(
                      ref.read(portfolioControllerProvider.notifier).refresh(),
                    )
                : null,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            key: const Key('portfolio-add'),
            tooltip: 'Ajouter une position',
            style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => context.push('/portfolio/new'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _body(context, ref, state, theme),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    PortfolioState state,
    ThemeData theme,
  ) {
    if (state.status == PortfolioLoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == PortfolioLoadStatus.error) {
      return const _Notice(
        icon: Icons.error_outline,
        title: portfolioReadErrorMessage,
      );
    }
    if (state.positions.isEmpty) {
      return const _Notice(
        icon: Icons.account_balance_wallet_outlined,
        title: portfolioEmptyTitle,
        explanation: portfolioEmptyExplanation,
        action: _AddPositionButton(),
      );
    }

    final summary = state.summary;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.refreshing)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
          if (summary == null)
            const _LoadingValues()
          else
            _SummaryCard(summary: summary),
          const SizedBox(height: 16),
          if (summary != null && summary.holdings.any((item) => item.isStale))
            const _StaleBanner(),
          if (summary != null) ...[
            Text('Répartition', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            AllocationChart(
              slices: summary.allocation,
              unpricedSymbols: summary.unpricedSymbols,
            ),
            const SizedBox(height: 20),
          ],
          Text('Positions', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (summary != null)
            for (final holding in summary.holdings) ...[
              _HoldingCard(
                holding: holding,
                onDelete: (position) => _confirmDelete(context, ref, position),
              ),
              const SizedBox(height: 12),
            ]
          else
            for (final holding in PortfolioMath.aggregateAll(state.positions))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LocalHolding(holding: holding),
              ),
          const SizedBox(height: 8),
          Text(
            portfolioDisclaimer,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  PortfolioPosition position,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Supprimer cette position ?'),
        content: const Text(
          'Cette position fictive sera retirée de ce portefeuille.',
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            key: const Key('confirm-delete'),
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      );
    },
  );
  if (confirmed != true || !context.mounted) {
    return;
  }
  try {
    await ref.read(portfolioRepositoryProvider).removePosition(position.id);
  } on PortfolioPersistenceException {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(portfolioDeleteErrorMessage)),
    );
  }
}

class _AddPositionButton extends StatelessWidget {
  const _AddPositionButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: const Key('portfolio-empty-add'),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      onPressed: () => context.push('/portfolio/new'),
      child: const Text('Ajouter une position'),
    );
  }
}

class _LoadingValues extends StatelessWidget {
  const _LoadingValues();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(child: Text(portfolioValuationLoading)),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLabel = summary.pricesComplete
        ? portfolioCurrentValueLabel
        : portfolioKnownValueLabel;
    final current = summary.totalCurrentValue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Synthèse', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _Figure(
              label: portfolioInvestedLabel,
              valueKey: const Key('total-invested'),
              value: formatPortfolioAmount(summary.totalInvested),
            ),
            const SizedBox(height: 12),
            if (current == null)
              Text(
                portfolioValueUnavailable,
                key: const Key('total-current'),
                style: theme.textTheme.titleMedium,
              )
            else
              _Figure(
                label: currentLabel,
                valueKey: const Key('total-current'),
                value: formatPortfolioAmount(current),
              ),
            const SizedBox(height: 12),
            _GlobalPerformance(summary: summary),
          ],
        ),
      ),
    );
  }
}

class _GlobalPerformance extends StatelessWidget {
  const _GlobalPerformance({required this.summary});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!summary.pricesComplete) {
      return Text(
        summary.totalCurrentValue == null
            ? portfolioPerformanceUnavailable
            : portfolioPartialPerformance,
        key: const Key('total-performance'),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    final gain = summary.globalGain;
    final performance = summary.globalPerformancePercent;
    if (gain == null || performance == null) {
      return Text(
        portfolioPerformanceUnavailable,
        key: const Key('total-performance'),
        style: theme.textTheme.bodyMedium,
      );
    }
    return _ResultLine(
      gain: gain,
      performance: performance,
      amountKey: const Key('total-gain'),
      performanceKey: const Key('total-performance'),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({
    required this.gain,
    required this.performance,
    required this.amountKey,
    required this.performanceKey,
  });

  final double gain;
  final double performance;
  final Key amountKey;
  final Key performanceKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);
    final positive = gain > 0;
    final negative = gain < 0;
    final color = positive
        ? semantic.gain
        : negative
            ? semantic.loss
            : theme.colorScheme.onSurfaceVariant;
    final icon = positive
        ? Icons.trending_up
        : negative
            ? Icons.trending_down
            : Icons.remove;
    final label = positive
        ? 'Gain'
        : negative
            ? 'Perte'
            : 'Écart nul';
    final semantics =
        '$label ${formatPortfolioSigned(gain)}, ${formatPortfolioPercent(performance)}';

    return Semantics(
      label: semantics,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          Icon(icon, color: color, size: 20),
          Text(label,
              style: theme.textTheme.titleSmall?.copyWith(color: color)),
          Text(
            formatPortfolioSigned(gain),
            key: amountKey,
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
          Text(
            formatPortfolioPercent(performance),
            key: performanceKey,
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final String value;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, key: valueKey, style: theme.textTheme.headlineSmall),
      ],
    );
  }
}

class _StaleBanner extends StatelessWidget {
  const _StaleBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        portfolioStaleMessage,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _HoldingCard extends StatelessWidget {
  const _HoldingCard({
    required this.holding,
    required this.onDelete,
  });

  final HoldingSnapshot holding;
  final Future<void> Function(PortfolioPosition position) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aggregated = holding.holding;
    final average = aggregated.averagePurchasePrice;
    final current = holding.currentValue;
    final gain = holding.gain;
    final performance = holding.performancePercent;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(aggregated.symbol, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Quantité ${formatQuantity(aggregated.totalQuantity)}'),
            if (average != null)
              Text('Prix moyen ${formatPortfolioAmount(average)}'),
            Text('Investi ${formatPortfolioAmount(aggregated.investedAmount)}'),
            const SizedBox(height: 8),
            if (current == null)
              Text(
                portfolioValueUnavailable,
                key: ValueKey('value-${aggregated.symbol}'),
                style: theme.textTheme.titleMedium,
              )
            else ...[
              Text(
                'Valeur ${formatPortfolioAmount(current)}',
                key: ValueKey('value-${aggregated.symbol}'),
                style: theme.textTheme.titleMedium,
              ),
              if (gain != null && performance != null) ...[
                const SizedBox(height: 4),
                _ResultLine(
                  gain: gain,
                  performance: performance,
                  amountKey: ValueKey('gain-${aggregated.symbol}'),
                  performanceKey: ValueKey('performance-${aggregated.symbol}'),
                ),
              ],
            ],
            if (holding.isStale && holding.pricedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Dernière donnée : ${formatPortfolioTimestamp(holding.pricedAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            for (final position in aggregated.positions)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${formatQuantity(position.quantity)} × ${formatPortfolioAmount(position.purchasePrice)} · ${formatPurchaseDay(position.purchaseDate)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton(
                    key: ValueKey('delete-position-${position.id}'),
                    tooltip:
                        'Supprimer la position ${position.symbol} du ${formatPurchaseDay(position.purchaseDate)}',
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: () => unawaited(onDelete(position)),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _LocalHolding extends StatelessWidget {
  const _LocalHolding({required this.holding});

  final AggregatedHolding holding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '${holding.symbol} · Investi ${formatPortfolioAmount(holding.investedAmount)}',
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.title,
    this.explanation,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? explanation;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final explanation = this.explanation;
    final action = this.action;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        Icon(icon, size: 36, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        if (explanation != null) ...[
          const SizedBox(height: 8),
          Text(
            explanation,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: 20),
          action,
        ],
      ],
    );
  }
}
