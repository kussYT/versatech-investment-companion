import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:versatech_investment_companion/app/theme/app_colors.dart';
import 'package:versatech_investment_companion/features/dashboard/presentation/dashboard_entrance.dart';
import 'package:versatech_investment_companion/features/dashboard/presentation/dashboard_messages.dart';
import 'package:versatech_investment_companion/features/favorites/presentation/favorites_screen.dart';
import 'package:versatech_investment_companion/features/portfolio/application/portfolio_providers.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/portfolio_math.dart';
import 'package:versatech_investment_companion/features/portfolio/presentation/portfolio_messages.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardEntrance(
                  index: 0,
                  child: const _Header(),
                ),
                const SizedBox(height: 20),
                DashboardEntrance(
                  index: 1,
                  child: _PortfolioCard(state: portfolio),
                ),
                const SizedBox(height: 20),
                const DashboardEntrance(
                  index: 2,
                  child: _Shortcuts(),
                ),
                const SizedBox(height: 20),
                const DashboardEntrance(
                  index: 3,
                  child: FavoriteEntriesView(),
                ),
                const SizedBox(height: 20),
                DashboardEntrance(
                  index: 4,
                  child: _Lesson(theme: theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dashboardGreeting, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          dashboardSubtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({required this.state});

  final PortfolioState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _body(theme),
      ),
    );
  }

  Widget _body(ThemeData theme) {
    if (state.status == PortfolioLoadStatus.loading) {
      return Text(dashboardPortfolioLoading, style: theme.textTheme.bodyLarge);
    }
    if (state.status == PortfolioLoadStatus.error) {
      return Text(
        portfolioReadErrorMessage,
        key: const Key('dashboard-portfolio-error'),
        style: theme.textTheme.bodyLarge,
      );
    }
    final summary = state.summary;
    if (summary == null) {
      return Text(portfolioValuationLoading, style: theme.textTheme.bodyLarge);
    }
    if (summary.isEmpty) {
      return const _EmptyPortfolio();
    }
    return _Summary(state: state, summary: summary);
  }
}

class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dashboardEmptyPortfolioTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          dashboardEmptyPortfolioBody,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              key: const Key('dashboard-add-position'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(48, 48),
              ),
              onPressed: () => context.push('/portfolio/new'),
              child: const Text(dashboardAddPosition),
            ),
            OutlinedButton(
              key: const Key('dashboard-empty-explorer'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(48, 48),
              ),
              onPressed: () => context.go('/explorer'),
              child: const Text(dashboardShortcutExplorer),
            ),
          ],
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.state,
    required this.summary,
  });

  final PortfolioState state;
  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stale = summary.holdings.any((holding) => holding.isStale);
    final sync = _syncLine(state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Portefeuille fictif', style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          dashboardHoldingCount(
              summary.holdings.length, state.positions.length),
          key: const Key('dashboard-counts'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (stale) ...[
          const SizedBox(height: 8),
          Text(
            portfolioStaleMessage,
            key: const Key('dashboard-stale'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (sync != null) ...[
          const SizedBox(height: 4),
          Text(
            sync,
            key: const Key('dashboard-sync'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _Amount(
          label: portfolioInvestedLabel,
          value: formatPortfolioAmount(summary.totalInvested),
          valueKey: const Key('dashboard-invested'),
        ),
        const SizedBox(height: 12),
        _CurrentValue(summary: summary),
        const SizedBox(height: 12),
        _Performance(summary: summary),
      ],
    );
  }
}

class _CurrentValue extends StatelessWidget {
  const _CurrentValue({required this.summary});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    if (!summary.pricesComplete && summary.totalCurrentValue == null) {
      return const Text(
        portfolioValueUnavailable,
        key: Key('dashboard-current'),
      );
    }
    final label = summary.pricesComplete
        ? portfolioCurrentValueLabel
        : portfolioKnownValueLabel;
    return _Amount(
      label: label,
      value: formatPortfolioAmount(summary.totalCurrentValue!),
      valueKey: const Key('dashboard-current'),
    );
  }
}

class _Performance extends StatelessWidget {
  const _Performance({required this.summary});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!summary.pricesComplete) {
      return Text(
        summary.totalCurrentValue == null
            ? portfolioPerformanceUnavailable
            : portfolioPartialPerformance,
        key: const Key('dashboard-performance'),
        style: theme.textTheme.bodyMedium,
      );
    }
    final gain = summary.globalGain;
    final performance = summary.globalPerformancePercent;
    if (gain == null || performance == null) {
      return Text(
        portfolioPerformanceUnavailable,
        key: const Key('dashboard-performance'),
      );
    }
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

    return Semantics(
      label:
          '$label ${formatPortfolioSigned(gain)}, ${formatPortfolioPercent(performance)}',
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          Icon(icon, color: color),
          Text(label,
              style: theme.textTheme.titleSmall?.copyWith(color: color)),
          Text(
            formatPortfolioSigned(gain),
            key: const Key('dashboard-gain'),
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
          Text(
            formatPortfolioPercent(performance),
            key: const Key('dashboard-performance'),
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({
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
    return Semantics(
      label: '$label $value',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              key: valueKey,
              style: theme.textTheme.headlineMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Shortcuts extends StatelessWidget {
  const _Shortcuts();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _Shortcut(
          buttonKey: const Key('dashboard-shortcut-explorer'),
          label: dashboardShortcutExplorer,
          icon: Icons.travel_explore,
          onPressed: () => context.go('/explorer'),
        ),
        _Shortcut(
          buttonKey: const Key('dashboard-shortcut-portfolio'),
          label: dashboardShortcutPortfolio,
          icon: Icons.account_balance_wallet_outlined,
          onPressed: () => context.go('/portfolio'),
        ),
        _Shortcut(
          buttonKey: const Key('dashboard-shortcut-simulator'),
          label: dashboardShortcutSimulator,
          icon: Icons.insights_outlined,
          onPressed: () => context.go('/simulator'),
        ),
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.buttonKey,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final Key buttonKey;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: buttonKey,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _Lesson extends StatelessWidget {
  const _Lesson({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dashboardLessonTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(dashboardLessonBody, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              dashboardAdviceDisclaimer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _syncLine(PortfolioState state) {
  final dates = <DateTime>{};
  var stale = false;
  for (final quote in state.quotes.values) {
    if (quote.lookup != QuoteLookup.available) {
      continue;
    }
    if (quote.isStale) {
      stale = true;
    }
    final at = quote.asOf;
    if (at != null) {
      dates.add(at);
    }
  }
  if (dates.length == 1) {
    return dashboardRecordedAt(formatPortfolioTimestamp(dates.single));
  }
  if (dates.length > 1 || stale) {
    return dashboardCacheMessage;
  }
  return null;
}
