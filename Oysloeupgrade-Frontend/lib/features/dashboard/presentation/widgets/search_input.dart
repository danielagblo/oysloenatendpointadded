import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';

class SearchInput extends StatelessWidget {
  const SearchInput({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText,
    this.backgroundColor,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(32);
    final Color innerColor =
        backgroundColor ??
        Theme.of(context).inputDecorationTheme.fillColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppColors.blueGray374957
            : AppColors.white);

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: radius,
      ),
      padding: const EdgeInsets.all(1.8),
      child: Container(
        decoration: BoxDecoration(color: innerColor, borderRadius: radius),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: AppTypography.body,
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText ?? 'Search anything up for good',
            hintStyle: AppTypography.body,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixIconConstraints: const BoxConstraints(minWidth: 48),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: SvgPicture.asset(
                'assets/icons/search.svg',
                width: 20,
                height: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
