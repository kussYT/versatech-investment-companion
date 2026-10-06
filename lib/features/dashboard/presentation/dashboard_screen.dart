import 'package:flutter/material.dart';
import 'package:versatech_investment_companion/core/widgets/feature_placeholder.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Accueil',
      description:
          'Retrouvez une vue d\'ensemble pour apprendre à suivre des actions et des ETF.',
    );
  }
}
