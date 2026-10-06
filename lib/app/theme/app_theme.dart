import 'package:flutter/material.dart';
import 'package:versatech_investment_companion/app/theme/app_colors.dart';

abstract final class AppTheme {
  static final ThemeData dark = _buildDark();

  static ThemeData _buildDark() {
    const semanticColors = AppSemanticColors(
      card: AppColors.card,
      secondarySurface: AppColors.secondarySurface,
      cyan: AppColors.cyan,
      violet: AppColors.violet,
      gain: AppColors.gain,
      loss: AppColors.loss,
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryBlue,
      onPrimary: AppColors.textPrimary,
      primaryContainer: AppColors.secondarySurface,
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.cyan,
      onSecondary: AppColors.background,
      secondaryContainer: AppColors.secondarySurface,
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.violet,
      onTertiary: AppColors.background,
      tertiaryContainer: AppColors.secondarySurface,
      onTertiaryContainer: AppColors.textPrimary,
      error: AppColors.loss,
      onError: AppColors.textPrimary,
      errorContainer: AppColors.secondarySurface,
      onErrorContainer: AppColors.loss,
      surface: AppColors.card,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.secondarySurface,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      shadow: Color(0xFF000000),
      scrim: Color(0x99000000),
      inverseSurface: AppColors.textPrimary,
      onInverseSurface: AppColors.background,
      inversePrimary: AppColors.primaryBlue,
    );

    final textTheme = ThemeData(brightness: Brightness.dark).textTheme.apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      extensions: const [semanticColors],
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: const CardTheme(
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.secondarySurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        height: 72,
        indicatorColor: AppColors.primaryBlue.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primaryBlue : AppColors.textSecondary,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
      ),
    );
  }
}
