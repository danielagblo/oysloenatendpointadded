import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.leadingIcon,
    this.leadingSvgAsset,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.textInputAction,
    this.focusNode,
    this.maxLines,
    this.autofillHints,
    this.autocorrect = true,
    this.obscuringCharacter = '•',
    this.compact = false,
    this.trailingIcon,
  });

  final TextEditingController? controller;
  final String? hint;
  final Widget? leadingIcon;
  final String? leadingSvgAsset;
  final bool isPassword;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final int? maxLines;
  final Iterable<String>? autofillHints;
  final bool autocorrect;
  final String obscuringCharacter;
  // When true, reduces vertical padding to make the field more compact in height.
  final bool compact;
  // Optional trailing icon (e.g. dropdown indicator) for non-password fields.
  final Widget? trailingIcon;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;
  late FocusNode _focusNode;
  bool _ownFocusNode = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.focusNode == null) _ownFocusNode = true;
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focusColor = AppColors.blueGray374957.withValues(alpha: 0.6);
    final iconColor = _focusNode.hasFocus
        ? focusColor
        : (theme.iconTheme.color ??
            theme.colorScheme.onSurface.withValues(alpha: 0.6));
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.compact ? 12 : 20),
      borderSide: BorderSide(color: AppColors.grayBFBF, width: 1),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.compact ? 12 : 20),
      borderSide: BorderSide(color: focusColor, width: 1.5),
    );

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType ??
          (widget.isPassword
              ? TextInputType.visiblePassword
              : TextInputType.text),
      textInputAction: widget.textInputAction ?? TextInputAction.next,
      validator: widget.validator,
      onChanged: widget.onChanged,
      autofillHints: widget.autofillHints,
      autocorrect: widget.autocorrect && !widget.isPassword,
      enableSuggestions: !widget.isPassword,
      obscureText: widget.isPassword ? _obscure : false,
      obscuringCharacter: widget.obscuringCharacter,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTypography.body.copyWith(
          color: Color(0xFF646161).withValues(alpha: 0.81),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 2.5.h,
          vertical: widget.compact ? 1.3.h : 2.2.h,
        ),
        prefixIcon: _buildPrefix(iconColor),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: iconColor,
                ),
                tooltip: _obscure ? 'Show password' : 'Hide password',
              )
            : (widget.trailingIcon != null
                ? Padding(
                    padding:
                        const EdgeInsetsDirectional.only(end: 16.0, start: 8.0),
                    child: widget.trailingIcon,
                  )
                : null),
        border: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: focusedBorder,
      ),
    );
  }

  Widget? _buildPrefix(Color iconColor) {
    if (widget.leadingSvgAsset != null) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(start: 24, end: 12),
        child: SvgPicture.asset(widget.leadingSvgAsset!, width: 20, height: 20),
      );
    }
    if (widget.leadingIcon != null) {
      return IconTheme.merge(
        data: IconThemeData(color: iconColor, size: 20),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 24, end: 12),
          child: widget.leadingIcon!,
        ),
      );
    }
    return null;
  }
}
