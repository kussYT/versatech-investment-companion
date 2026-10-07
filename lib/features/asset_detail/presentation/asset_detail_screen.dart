import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:versatech_investment_companion/app/theme/app_colors.dart';
import 'package:versatech_investment_companion/features/asset_detail/application/asset_detail_controller.dart';
import 'package:versatech_investment_companion/features/asset_detail/application/asset_detail_state.dart';
import 'package:versatech_investment_companion/features/asset_detail/presentation/asset_detail_messages.dart';
import 'package:versatech_investment_companion/features/asset_detail/presentation/asset_price_chart.dart';
import 'package:versatech_investment_companion/features/favorites/presentation/favorite_button.dart';
import 'package:versatech_investment_companion/features/simulator/application/dca_controller.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset_profile.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/market_quote.dart';

class AssetDetailScreen extends ConsumerStatefulWidget {
  const AssetDetailScreen({
    required this.symbol,
    this.assetType,
    super.key,
  });

  final String symbol;
  final String? assetType;

  @override
  ConsumerState<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends ConsumerState<AssetDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(assetDetailControllerProvider(widget.symbol).notifier).load();
    });
  }

  @override
  void didUpdateWidget(AssetDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol == widget.symbol) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(assetDetailControllerProvider(widget.symbol).notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetDetailControllerProvider(widget.symbol));
    final type = _assetType(widget.assetType);
    final title = state.invalid ? 'Actif' : state.symbol;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (!state.invalid) FavoriteButton(symbol: state.symbol),
          if (!state.invalid)
            IconButton(
              key: const Key('asset-detail-refresh'),
              tooltip: 'Actualiser',
              style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: state.isBusy
                  ? null
                  : () {
                      unawaited(
                        ref
                            .read(
                              assetDetailControllerProvider(widget.symbol)
                                  .notifier,
                            )
                            .refresh(),
                      );
                    },
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (state.invalid)
                const _SectionMessage(
                  message: 'Ce symbole n’est pas valide.',
                )
              else ...[
                _Header(state: state, type: type),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  key: const Key('add-to-portfolio'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    final symbol = Uri.encodeQueryComponent(state.symbol);
                    context.push('/portfolio/new?symbol=$symbol');
                  },
                  icon: const Icon(Icons.playlist_add),
                  label: const Text('Ajouter au portefeuille'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('simulate-investment'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    ref.read(dcaRequestedSymbolProvider.notifier).state =
                        state.symbol;
                    final symbol = Uri.encodeQueryComponent(state.symbol);
                    context.go('/simulator?symbol=$symbol');
                  },
                  icon: const Icon(Icons.insights_outlined),
                  label: const Text('Simuler un investissement'),
                ),
                const SizedBox(height: 16),
                _QuoteSection(section: state.quote, currency: _currency(state)),
                const SizedBox(height: 12),
                Text(
                  variationExplanation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 20),
                _HistorySection(
                  state: state,
                  onWindowSelected: (window) {
                    ref
                        .read(
                          assetDetailControllerProvider(widget.symbol).notifier,
                        )
                        .selectWindow(window);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  historyExplanation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 20),
                _ProfileSection(section: state.profile),
                const SizedBox(height: 16),
                Text(
                  detailDisclaimer,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

AssetType? _assetType(String? raw) {
  return switch (raw?.trim().toLowerCase()) {
    'stock' || 'action' => AssetType.stock,
    'etf' => AssetType.etf,
    _ => null,
  };
}

String? _currency(AssetDetailState state) {
  final currency = state.profile.data?.currency.trim();
  if (currency == null || currency.isEmpty) {
    return null;
  }
  return currency;
}

class _Header extends StatelessWidget {
  const _Header({
    required this.state,
    required this.type,
  });

  final AssetDetailState state;
  final AssetType? type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);
    final profile = state.profile.data;
    final name = profile?.companyName.trim() ?? '';
    final exchange = profile?.exchange.trim() ?? '';
    final currency = profile?.currency.trim() ?? '';
    final details = [
      if (exchange.isNotEmpty) exchange,
      if (currency.isNotEmpty) currency,
    ].join(' · ');

    final assetType = type;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(state.symbol, style: theme.textTheme.headlineSmall),
        if (name.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(name, style: theme.textTheme.titleMedium),
        ],
        if (assetType != null) ...[
          const SizedBox(height: 8),
          _TypeChip(type: assetType, semantic: semantic),
        ],
        if (details.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            details,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.semantic,
  });

  final AssetType type;
  final AppSemanticColors semantic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEtf = type == AssetType.etf;
    final color = isEtf ? semantic.violet : theme.colorScheme.primary;
    final icon = isEtf ? Icons.pie_chart_outline : Icons.show_chart;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              assetTypeLabel(type),
              style: theme.textTheme.labelLarge?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteSection extends StatelessWidget {
  const _QuoteSection({
    required this.section,
    required this.currency,
  });

  final AssetSection<MarketQuote> section;
  final String? currency;

  @override
  Widget build(BuildContext context) {
    final quote = section.data;
    if (section.phase == SectionPhase.loading && quote == null) {
      return const _SectionMessage(
        message: 'Chargement de la cotation',
        progress: true,
      );
    }
    if (quote == null) {
      return _SectionMessage(
        message:
            'La cotation n’est pas disponible. ${assetDetailFailureMessage(section.failure!)}',
      );
    }

    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);
    final direction = quote.change != 0 ? quote.change : quote.changePercent;
    final positive = direction > 0;
    final negative = direction < 0;
    final color = positive
        ? semantic.gain
        : negative
            ? semantic.loss
            : theme.colorScheme.onSurface;
    final icon = positive
        ? Icons.arrow_upward
        : negative
            ? Icons.arrow_downward
            : Icons.remove;
    final label = variationLabel(quote.change, quote.changePercent);
    final price = formatDetailAmount(quote.price);
    final priceLabel = currency == null ? price : '$price $currency';
    final sync = sectionSyncLabel(section);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dernier prix connu', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(priceLabel, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$label ${formatSignedAmount(quote.change)} '
                    '(${formatSignedPercent(quote.changePercent)})',
                    style: theme.textTheme.titleMedium?.copyWith(color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Cotation du ${formatDetailTimestamp(quote.timestamp)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (section.failure != null) ...[
              const SizedBox(height: 8),
              Text(assetDetailFailureMessage(section.failure!)),
            ],
            if (sync != null) ...[
              const SizedBox(height: 8),
              Text(sync, style: theme.textTheme.bodyMedium),
            ],
            if (section.isRefreshing) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.state,
    required this.onWindowSelected,
  });

  final AssetDetailState state;
  final ValueChanged<HistoryWindow> onWindowSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final section = state.history;
    final sync = sectionSyncLabel(section);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Historique des clôtures', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final window in HistoryWindow.values)
              _WindowButton(
                label: window.label,
                selected: state.window == window,
                onPressed: () => onWindowSelected(window),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (sync != null) ...[
          Text(sync, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
        ],
        if (section.isRefreshing) const LinearProgressIndicator(),
        if (section.hasData && section.failure != null) ...[
          Text(assetDetailFailureMessage(section.failure!)),
          const SizedBox(height: 8),
        ],
        if (section.phase == SectionPhase.loading && !section.hasData)
          const _SectionMessage(
            message: 'Chargement de l’historique',
            progress: true,
          )
        else if (!section.hasData)
          _SectionMessage(
            message:
                'L’historique n’est pas disponible. ${assetDetailFailureMessage(section.failure!)}',
          )
        else
          AssetPriceChart(prices: state.visibleHistory),
      ],
    );
  }
}

class _WindowButton extends StatelessWidget {
  const _WindowButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.16)
              : null,
          foregroundColor: theme.colorScheme.onSurface,
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.section});

  final AssetSection<AssetProfile> section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (section.phase == SectionPhase.loading && !section.hasData) {
      return const _SectionMessage(
        message: 'Chargement du profil',
        progress: true,
      );
    }
    if (!section.hasData) {
      return _SectionMessage(
        message:
            'Le profil n’est pas disponible. ${assetDetailFailureMessage(section.failure!)}',
      );
    }

    final profile = section.data!;
    final description = profile.description.trim();
    final sector = profile.sector?.trim() ?? '';
    final industry = profile.industry?.trim() ?? '';
    final website = profile.website?.trim() ?? '';
    final rows = [
      if (sector.isNotEmpty) _ProfileRow(label: 'Secteur', value: sector),
      if (industry.isNotEmpty) _ProfileRow(label: 'Industrie', value: industry),
      if (website.isNotEmpty) _ProfileRow(label: 'Site', value: website),
    ];
    if (description.isEmpty && rows.isEmpty) {
      return const SizedBox.shrink();
    }

    final sync = sectionSyncLabel(section);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profil', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (sync != null) ...[
          Text(sync, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
        ],
        if (section.failure != null) ...[
          Text(assetDetailFailureMessage(section.failure!)),
          const SizedBox(height: 8),
        ],
        if (description.isNotEmpty)
          Text(description, style: theme.textTheme.bodyLarge),
        for (final row in rows) ...[
          const SizedBox(height: 8),
          row,
        ],
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label : ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          TextSpan(text: value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _SectionMessage extends StatelessWidget {
  const _SectionMessage({
    required this.message,
    this.progress = false,
  });

  final String message;
  final bool progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          if (progress) ...[
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
