import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:versatech_investment_companion/app/theme/app_colors.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/portfolio_math.dart';
import 'package:versatech_investment_companion/features/portfolio/presentation/portfolio_messages.dart';

/// Ring of current-value weights.
///
/// Holdings without a price are omitted here and from the denominator.
/// They are named under the chart instead of being drawn as a zero slice.
class AllocationChart extends StatelessWidget {
  const AllocationChart({
    required this.slices,
    required this.unpricedSymbols,
    super.key,
  });

  final List<AllocationSlice> slices;
  final List<String> unpricedSymbols;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (slices.isEmpty) {
      return Text(
        portfolioAllocationUnavailable,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final label = [
      for (final slice in slices)
        '${slice.symbol} ${formatPortfolioWeight(slice.weightPercent)}',
    ].join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Répartition par valeur actuelle : $label',
          child: ExcludeSemantics(
            child: SizedBox(
              key: const Key('portfolio-allocation-chart'),
              height: 200,
              child: PieChart(
                duration: Duration.zero,
                PieChartData(
                  centerSpaceRadius: 42,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                  sections: [
                    for (var index = 0; index < slices.length; index++)
                      PieChartSectionData(
                        value: slices[index].weightPercent,
                        color: AppSemanticColors.chartPalette[
                            index % AppSemanticColors.chartPalette.length],
                        title: '',
                        radius: 28,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < slices.length; index++) ...[
          _LegendRow(
            color: AppSemanticColors
                .chartPalette[index % AppSemanticColors.chartPalette.length],
            symbol: slices[index].symbol,
            percent: formatPortfolioWeight(slices[index].weightPercent),
          ),
          const SizedBox(height: 8),
        ],
        for (final symbol in unpricedSymbols)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              portfolioExcludedMessage(symbol),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.symbol,
    required this.percent,
  });

  final Color color;
  final String symbol;
  final String percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const SizedBox(width: 12, height: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(symbol, style: theme.textTheme.bodyMedium),
        ),
        Text(percent, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
