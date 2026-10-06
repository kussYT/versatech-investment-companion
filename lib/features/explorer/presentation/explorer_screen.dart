import 'package:flutter/material.dart';
import 'package:versatech_investment_companion/core/widgets/feature_placeholder.dart';

class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Explorer',
      description:
          'Parcourez des actions et des ETF afin d\'en comprendre les caractéristiques.',
    );
  }
}
