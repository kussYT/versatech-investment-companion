import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:versatech_investment_companion/features/asset_detail/presentation/asset_detail_messages.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/historical_price.dart';

class AssetPriceChart extends StatelessWidget {
  const AssetPriceChart({
    required this.prices,
    super.key,
  });

  final List<HistoricalPrice> prices;

  @override
  Widget build(BuildContext context) {
    if (prices.isEmpty) {
      return const _ChartNotice(
        message: 'Aucun cours de clôture sur cette période.',
      );
    }

    final theme = Theme.of(context);
    final closes = [for (final price in prices) price.close];
    final minClose =
        closes.reduce((left, right) => left < right ? left : right);
    final maxClose =
        closes.reduce((left, right) => left > right ? left : right);
    final span = maxClose - minClose;
    final padding = span == 0 ? 1.0 : span * 0.12;
    final minY = minClose - padding;
    final maxY = maxClose + padding;
    final lastIndex = prices.length - 1;

    return Semantics(
      label: 'Graphique des cours de clôture',
      child: SizedBox(
        key: const Key('close-price-chart'),
        height: 220,
        child: LineChart(
          duration: Duration.zero,
          LineChartData(
            minX: prices.length == 1 ? -1 : 0,
            maxX: prices.length == 1 ? 1 : lastIndex.toDouble(),
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
                  reservedSize: 52,
                  interval: maxY - minY,
                  getTitlesWidget: (value, meta) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        formatDetailAmount(value),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formatDetailDate(prices[index].date),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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
                        '${formatDetailDate(prices[spot.spotIndex].date)}\n'
                        '${formatDetailAmount(prices[spot.spotIndex].close)}',
                        theme.textTheme.labelMedium!.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                  ];
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (var index = 0; index < prices.length; index++)
                    FlSpot(index.toDouble(), prices[index].close),
                ],
                isCurved: false,
                color: theme.colorScheme.primary,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartNotice extends StatelessWidget {
  const _ChartNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
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
