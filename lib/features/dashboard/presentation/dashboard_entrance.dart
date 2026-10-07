import 'package:flutter/material.dart';

/// Third animation of the project: dashboard sections fade in and rise 12 dp.
///
/// FavoriteButton and AnimatedFinancialValue are the two animations programmed
/// with an AnimationController, a Tween and an AnimatedBuilder. This entrance
/// stays lighter: a [TweenAnimationBuilder] drives opacity and a short vertical
/// offset, with a small delay between sections. It does not run when
/// [MediaQuery.disableAnimationsOf] is set, and the figures stay readable
/// without it.
class DashboardEntrance extends StatelessWidget {
  const DashboardEntrance({
    required this.index,
    required this.child,
    super.key,
  });

  final int index;
  final Widget child;

  static const duration = Duration(milliseconds: 480);
  static const stagger = Duration(milliseconds: 80);
  static const travel = 12.0;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration + stagger * index,
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, (1 - progress) * travel),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
