import 'package:flutter/material.dart';
import 'package:versatech_investment_companion/core/widgets/feature_placeholder.dart';

class SimulatorScreen extends StatelessWidget {
  const SimulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Simulateur',
      description:
          'Simulez un investissement pour visualiser son évolution dans le temps.',
    );
  }
}
