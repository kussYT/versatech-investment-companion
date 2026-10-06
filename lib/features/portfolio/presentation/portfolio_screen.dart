import 'package:flutter/material.dart';
import 'package:versatech_investment_companion/core/widgets/feature_placeholder.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Portefeuille',
      description:
          'Composez un portefeuille fictif et observez sa répartition.',
    );
  }
}
