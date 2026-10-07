import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:versatech_investment_companion/app/theme/app_colors.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/portfolio_rules.dart';
import 'package:versatech_investment_companion/features/portfolio/presentation/portfolio_messages.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_models.dart';
import 'package:versatech_investment_companion/features/simulator/presentation/dca_messages.dart';

/// Two series: invested capital and simulated value.
///
/// Colors come from [AppSemanticColors.chartPalette]. Gain and loss colors
/// are not used to identify a series. The legend names each line.
class DcaChart extends StatelessWidget {
  const DcaChart({
    required this.points,
    super.key,
  });

  final List<SimulationPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (points.isEmpty) {
      return const _Notice(message: dcaEmptyChartMessage);
    }

    final investedColor = AppSemanticColors.chartPalette[0];
    final valueColor = AppSemanticColors.chartPalette[1];
    final values = [
      for (final point in points) ...[
        point.investedAmount,
        point.simulatedValue,
      ],
    ];
    final minValue =
        values.reduce((left, right) => left < right ? left : right);
    final maxValue =
        values.reduce((left, right) => left > right ? left : right);
    final span = maxValue - minValue;
    final padding = span == 0 ? 1.0 : span * 0.12;
    final minY = minValue - padding;
    final maxY = maxValue + padding;
    final lastIndex = points.length - 1;
    final startLabel = formatPurchaseDay(points.first.date);
    final endLabel = formatPurchaseDay(points.last.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label:
              'Graphique du capital versé et de la valeur simulée, du $startLabel au $endLabel',
          child: ExcludeSemantics(
            child: SizedBox(
              key: const Key('dca-chart'),
              height: 220,
              child: LineChart(
                duration: Duration.zero,
                LineChartData(
                  minX: points.length == 1 ? -1 : 0,
                  maxX: points.length == 1 ? 1 : lastIndex.toDouble(),
                  minY: minY,
                  maxY: maxY,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 56,
                        interval: maxY - minY,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            formatPortfolioAmount(value),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.round();
                          final showLabel = index == 0 || index == lastIndex;
                          if (!showLabel || (value - index).abs() > 0.01) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              formatPurchaseDay(points[index].date),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => theme.colorScheme.primary,
                      getTooltipItems: (spots) {
                        return [
                          for (final spot in spots)
                            LineTooltipItem(
                              _tooltip(spot),
                              theme.textTheme.labelMedium!.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                        ];
                      },
                    ),
                  ),
                  lineBarsData: [
                    _series(
                      points: points,
                      color: investedColor,
                      values: (point) => point.investedAmount,
                    ),
                    _series(
                      points: points,
                      color: valueColor,
                      values: (point) => point.simulatedValue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _Legend(color: investedColor, label: dcaInvestedSeries),
        const SizedBox(height: 8),
        _Legend(color: valueColor, label: dcaValueSeries),
      ],
    );
  }

  String _tooltip(LineBarSpot spot) {
    final point = points[spot.spotIndex];
    final name = spot.barIndex == 0 ? dcaInvestedSeries : dcaValueSeries;
    return '$name\n${formatPurchaseDay(point.date)}\n${formatPortfolioAmount(spot.y)}';
  }
}

LineChartBarData _series({
  required List<SimulationPoint> points,
  required Color color,
  required double Function(SimulationPoint point) values,
}) {
  return LineChartBarData(
    spots: [
      for (var index = 0; index < points.length; index++)
        FlSpot(index.toDouble(), values(points[index])),
    ],
    isCurved: false,
    color: color,
    barWidth: 2,
    dotData: FlDotData(show: points.length <= 12),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('dca-chart-empty'),
      height: 120,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
