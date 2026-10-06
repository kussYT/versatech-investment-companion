import 'package:flutter/material.dart';

/// Temporary destination used to confirm navigation from Explorer.
///
/// The full asset page is intentionally not implemented here.
class AssetPreviewScreen extends StatelessWidget {
  const AssetPreviewScreen({
    required this.symbol,
    super.key,
  });

  final String symbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(symbol),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Fiche de $symbol',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'La fiche détaillée de cet actif sera disponible prochainement.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
