import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'animated_gradient_border.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';

class AnimatedGradientSearchInput extends StatefulWidget {
  const AnimatedGradientSearchInput.full({
    super.key,
    required this.controller,
    this.hintText = 'Search anything up for good',
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.inputColor,
  }) : compact = false;

  const AnimatedGradientSearchInput.compact({
    super.key,
    required this.controller,
    this.hintText = 'Search anything up for good',
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.inputColor,
  }) : compact = true;

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool compact;
  final Color? inputColor;

  @override
  State<AnimatedGradientSearchInput> createState() =>
      _AnimatedGradientSearchInputState();
}

class _AnimatedGradientSearchInputState
    extends State<AnimatedGradientSearchInput> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = widget.compact;
    final BorderRadius radius = BorderRadius.circular(isCompact ? 24 : 30);

    final Color innerColor =
        widget.inputColor ??
        Theme.of(context).inputDecorationTheme.fillColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppColors.blueGray374957
            : AppColors.white);

    final double? height = isCompact ? 38 : null;
    final EdgeInsetsGeometry contentPadding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 15, vertical: 19);
    final double iconSize = isCompact ? 14 : 17;
    final double fontSize = isCompact
        ? 14.sp
        : AppTypography.body.fontSize ?? 16;
    final double hintFontSize = isCompact
        ? 13.sp
        : AppTypography.body.fontSize ?? 16;

    return SizedBox(
      height: height,
      child: AnimatedGradientBorder(
        focusNode: _focusNode,
        borderRadius: radius,
        borderWidth: 2.0,
        backgroundColor: innerColor,
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          style: AppTypography.body.copyWith(fontSize: fontSize.toDouble()),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hintText,
            hintStyle: AppTypography.body.copyWith(
              fontSize: hintFontSize.toDouble(),
              color: Theme.of(context).hintColor.withValues(alpha: 0.7),
            ),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixIconConstraints: BoxConstraints(
              minWidth: isCompact ? 36 : 40,
            ),
            contentPadding: contentPadding,
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: isCompact ? 8 : 12),
              child: SvgPicture.asset(
                'assets/icons/search.svg',
                width: iconSize,
                height: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
