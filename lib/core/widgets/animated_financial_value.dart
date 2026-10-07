import 'package:flutter/material.dart';

/// Counts visually from the previous figure to [value].
///
/// The widget only formats a number it is given. It does not compute a
/// simulation. A rebuild with the same [value] does not replay the motion.
class AnimatedFinancialValue extends StatefulWidget {
  const AnimatedFinancialValue({
    required this.value,
    required this.formatter,
    this.duration = const Duration(milliseconds: 800),
    this.style,
    this.textKey,
    super.key,
  });

  final double value;
  final String Function(double value) formatter;
  final Duration duration;
  final TextStyle? style;
  final Key? textKey;

  @override
  State<AnimatedFinancialValue> createState() => _AnimatedFinancialValueState();
}

class _AnimatedFinancialValueState extends State<AnimatedFinancialValue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  CurvedAnimation? _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _play(begin: 0, end: widget.value);
  }

  @override
  void didUpdateWidget(AnimatedFinancialValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value &&
        oldWidget.duration == widget.duration) {
      return;
    }
    final begin = _controller.isCompleted ? oldWidget.value : _animation.value;
    _play(begin: begin, end: widget.value);
  }

  @override
  void dispose() {
    _curve?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _play({required double begin, required double end}) {
    _curve?.dispose();
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _animation = Tween<double>(begin: begin, end: end).animate(_curve!);
    _controller
      ..duration = widget.duration
      ..forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final displayed =
            _controller.isCompleted ? widget.value : _animation.value;
        return Text(
          widget.formatter(displayed),
          key: widget.textKey,
          style: widget.style,
        );
      },
    );
  }
}
