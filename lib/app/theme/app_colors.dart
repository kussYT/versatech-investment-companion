import 'package:flutter/material.dart';

/// Palette VersaTech. Réservée à la construction du thème.
abstract final class AppColors {
  static const background = Color(0xFF050814);
  static const card = Color(0xFF0B1224);
  static const secondarySurface = Color(0xFF101A30);
  static const primaryBlue = Color(0xFF4C7DFF);
  static const cyan = Color(0xFF52E5FF);
  static const violet = Color(0xFF9B7CFF);
  static const textPrimary = Color(0xFFF7F9FC);
  static const textSecondary = Color(0xFFAAB4C8);
  static const gain = Color(0xFF22C55E);
  static const loss = Color(0xFFEF4444);
  static const border = Color(0x33AAB4C8);
}

/// Couleurs sémantiques exposées aux écrans via le thème.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.card,
    required this.secondarySurface,
    required this.cyan,
    required this.violet,
    required this.gain,
    required this.loss,
  });

  final Color card;
  final Color secondarySurface;
  final Color cyan;
  final Color violet;
  final Color gain;
  final Color loss;

  /// Asset identity on the allocation ring. Gain and loss stay off this list.
  static const chartPalette = <Color>[
    AppColors.primaryBlue,
    AppColors.cyan,
    AppColors.violet,
    Color(0xFF8FB0FF),
    Color(0xFF5C6B8A),
  ];

  static AppSemanticColors of(BuildContext context) {
    final colors = Theme.of(context).extension<AppSemanticColors>();
    if (colors == null) {
      throw StateError('AppSemanticColors is missing from the theme.');
    }
    return colors;
  }

  @override
  AppSemanticColors copyWith({
    Color? card,
    Color? secondarySurface,
    Color? cyan,
    Color? violet,
    Color? gain,
    Color? loss,
  }) {
    return AppSemanticColors(
      card: card ?? this.card,
      secondarySurface: secondarySurface ?? this.secondarySurface,
      cyan: cyan ?? this.cyan,
      violet: violet ?? this.violet,
      gain: gain ?? this.gain,
      loss: loss ?? this.loss,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) {
      return this;
    }

    return AppSemanticColors(
      card: Color.lerp(card, other.card, t)!,
      secondarySurface:
          Color.lerp(secondarySurface, other.secondarySurface, t)!,
      cyan: Color.lerp(cyan, other.cyan, t)!,
      violet: Color.lerp(violet, other.violet, t)!,
      gain: Color.lerp(gain, other.gain, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
    );
  }
}
