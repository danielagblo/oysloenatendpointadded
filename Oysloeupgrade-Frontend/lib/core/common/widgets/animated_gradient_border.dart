import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';

class AnimatedGradientBorder extends StatefulWidget {
  const AnimatedGradientBorder({
    super.key,
    required this.child,
    required this.borderRadius,
    this.borderWidth = 2.0,
    this.colors,
    this.stops,
    this.idleDuration = const Duration(seconds: 4),
    this.focusedDuration = const Duration(seconds: 2),
    this.focusNode,
    this.padding,
    this.backgroundColor,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double borderWidth;
  final List<Color>? colors;
  final List<double>? stops;
  final Duration idleDuration;
  final Duration focusedDuration;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _angle;
  FocusNode? _internalFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    _maybeInitFocusNode();

    _controller = AnimationController(
      vsync: this,
      duration: widget.idleDuration,
    )..repeat();

    _angle = CurvedAnimation(parent: _controller, curve: Curves.linear);

    _focusNode.addListener(_handleFocusChange);
  }

  void _maybeInitFocusNode() {
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
  }

  void _handleFocusChange() {
    if (!mounted) return;
    final focused = _focusNode.hasFocus;
    final newDuration = focused ? widget.focusedDuration : widget.idleDuration;
    if (_controller.duration != newDuration) {
      try {
        _controller.duration = newDuration;
        if (_controller.isAnimating) {
          _controller.repeat();
        } else {
          _controller.forward();
        }
      } catch (_) {
        // In rare cases duration changes can throw while animating; restart.
        if (mounted) {
          _controller.stop();
          _controller.duration = newDuration;
          _controller.repeat();
        }
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColors = (widget.colors ?? _defaultColors());
    final baseStops = (widget.stops ?? _defaultStops());
    final loopedColors = baseColors.length >= 2
        ? [...baseColors, baseColors.first]
        : baseColors;
    final loopedStops = baseStops != null ? [...baseStops, 1.0] : null;

    return AnimatedBuilder(
      animation: _angle,
      child: widget.child,
      builder: (context, child) {
        final gradient = SweepGradient(
          colors: loopedColors,
          stops: loopedStops,
          startAngle: 0.0,
          endAngle: math.pi * 2,
          transform: GradientRotation(_angle.value * math.pi * 2),
          center: Alignment.center,
        );

        return Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: widget.borderRadius,
          ),
          padding: EdgeInsets.all(widget.borderWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: widget.borderRadius,
            ),
            child: Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        );
      },
    );
  }

  List<Color> _defaultColors() => AppColors.primaryGradient.colors;

  List<double>? _defaultStops() => AppColors.primaryGradient.stops;
}
