import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:versatech_investment_companion/app/theme/app_colors.dart';
import 'package:versatech_investment_companion/features/explorer/presentation/explorer_messages.dart';
import 'package:versatech_investment_companion/features/favorites/application/favorites_providers.dart';
import 'package:versatech_investment_companion/features/favorites/presentation/favorite_button.dart';
import 'package:versatech_investment_companion/features/favorites/presentation/favorite_messages.dart';
import 'package:versatech_investment_companion/features/market_data/domain/entities/asset.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(favoriteEntriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: entries.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const _Message(
              icon: Icons.error_outline,
              title: favoriteReadErrorMessage,
            ),
            data: (items) {
              if (items.isEmpty) {
                return const _Message(
                  icon: Icons.bookmark_border,
                  title: favoriteEmptyTitle,
                  explanation: favoriteEmptyExplanation,
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text('Favoris', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Vos actions et ETF suivis sur cet appareil.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final entry in items) ...[
                    _FavoriteTile(entry: entry),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.entry});

  final FavoriteEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);
    final symbol = entry.favorite.symbol;
    final name = entry.name;
    final type = entry.type;
    final details = [
      if (entry.exchange != null) entry.exchange!,
      if (entry.currency != null) entry.currency!,
    ].join(' · ');

    return Card(
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              key: ValueKey('favorite-entry-$symbol'),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              onTap: () => _open(context),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(symbol, style: theme.textTheme.titleMedium),
                      if (name != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          details,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (type != null) ...[
                        const SizedBox(height: 8),
                        _TypeLabel(type: type, semantic: semantic),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          FavoriteButton(symbol: symbol),
        ],
      ),
    );
  }

  void _open(BuildContext context) {
    final symbol = Uri.encodeComponent(entry.favorite.symbol);
    final type = switch (entry.type) {
      AssetType.stock => 'stock',
      AssetType.etf => 'etf',
      null => null,
    };
    final location =
        type == null ? '/explorer/$symbol' : '/explorer/$symbol?type=$type';
    context.go(location);
  }
}

class _TypeLabel extends StatelessWidget {
  const _TypeLabel({
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

    return Text(
      assetTypeLabel(type),
      style: theme.textTheme.labelLarge?.copyWith(color: color),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    this.explanation,
  });

  final IconData icon;
  final String title;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final explanation = this.explanation;

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
      ],
    );
  }
}
