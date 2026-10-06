import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatech_investment_companion/app/theme/app_colors.dart';
import 'package:versatech_investment_companion/core/errors/app_exception.dart';
import 'package:versatech_investment_companion/features/favorites/application/favorites_providers.dart';
import 'package:versatech_investment_companion/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:versatech_investment_companion/features/favorites/presentation/favorite_messages.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';

/// Bookmark control whose scale and opacity are driven by an [AnimationController].
class FavoriteButton extends ConsumerStatefulWidget {
  const FavoriteButton({
    required this.symbol,
    super.key,
  });

  final String symbol;

  static const addDuration = Duration(milliseconds: 280);
  static const removeDuration = Duration(milliseconds: 160);
  static const addedPeakScale = 1.16;
  static const removedValleyScale = 0.92;
  static const addedOpacityStart = 0.55;
  static const removedOpacityDip = 0.78;

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: FavoriteButton.addDuration,
    );
    _holdStill();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final symbol = normalizeSymbol(widget.symbol);
    final mark = ref.watch(favoriteMarkProvider(symbol));
    ref.listen(favoriteMarkProvider(symbol), (previous, next) {
      if (previous == null || previous == FavoriteMark.unknown) {
        return;
      }
      if (previous == next || next == FavoriteMark.unknown) {
        return;
      }
      if (next == FavoriteMark.present) {
        _playAdded();
      } else {
        _playRemoved();
      }
    });

    final selected = mark == FavoriteMark.present;
    final label = selected
        ? 'Retirer $symbol des favoris'
        : 'Ajouter $symbol aux favoris';
    final theme = Theme.of(context);

    return IconButton(
      key: ValueKey('favorite-$symbol'),
      tooltip: label,
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      onPressed: symbol.isEmpty ? null : () => unawaited(_toggle()),
      icon: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacity.value.clamp(0.0, 1.0),
            child: Transform.scale(
              key: const Key('favorite-scale'),
              scale: _scale.value,
              child: child,
            ),
          );
        },
        child: Icon(
          selected ? Icons.bookmark : Icons.bookmark_border,
          color:
              selected ? AppColors.violet : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Future<void> _toggle() async {
    try {
      await ref.read(favoriteRepositoryProvider).toggleFavorite(widget.symbol);
    } on FavoritePersistenceException {
      _show(favoriteWriteErrorMessage);
    } on InvalidMarketDataException {
      _show('Ce symbole n’est pas valide.');
    }
  }

  void _show(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _playAdded() {
    _controller.duration = FavoriteButton.addDuration;
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: FavoriteButton.addedPeakScale,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: FavoriteButton.addedPeakScale,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 55,
      ),
    ]).animate(_controller);
    _opacity = Tween<double>(
      begin: FavoriteButton.addedOpacityStart,
      end: 1,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(_controller);
    _controller.forward(from: 0);
  }

  void _playRemoved() {
    _controller.duration = FavoriteButton.removeDuration;
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: FavoriteButton.removedValleyScale,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: FavoriteButton.removedValleyScale,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: FavoriteButton.removedOpacityDip,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: FavoriteButton.removedOpacityDip,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
    _controller.forward(from: 0);
  }

  void _holdStill() {
    _scale = ConstantTween<double>(1).animate(_controller);
    _opacity = ConstantTween<double>(1).animate(_controller);
  }
}
