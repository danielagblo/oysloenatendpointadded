import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/multi_page_bottom_sheet.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AdInput extends StatefulWidget {
  const AdInput({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.width,
    this.prefixText,
    this.suffixText,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.enabled = true,
    this.obscureText = false,
    this.onChanged,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.suffixIcon,
    this.prefixIcon,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final double? width;
  final String? prefixText;
  final String? suffixText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? maxLength;
  final bool readOnly;
  final bool enabled;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  @override
  State<AdInput> createState() => _AdInputState();
}

class _AdInputState extends State<AdInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget textField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.white : AppColors.blueGray374957,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          obscureText: widget.obscureText,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.white : AppColors.blueGray374957,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTypography.body
                .copyWith(color: AppColors.gray8B959E, fontSize: 15.sp),
            prefixText: widget.prefixText,
            suffixText: widget.suffixText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: isDark ? AppColors.blueGray374957 : AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? AppColors.blueGray374957 : AppColors.grayD9,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? AppColors.blueGray374957 : AppColors.grayD9,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.blueGray374957.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.redFF6B6B,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.redFF6B6B,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            counterText: '',
          ),
        ),
      ],
    );

    if (widget.width != null) {
      return SizedBox(width: widget.width, child: textField);
    }

    return textField;
  }
}

class AdDropdown<T> extends StatelessWidget {
  const AdDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hintText,
    this.labelText,
    this.width,
    this.validator,
    this.enabled = true,
    this.compact = false,
    this.prefixIcon,
  });

  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String? hintText;
  final String? labelText;
  final double? width;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool compact;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget dropdown = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.white : AppColors.blueGray374957,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled && items.isNotEmpty ? onChanged : null,
          validator: validator,
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.white : AppColors.blueGray374957,
            fontSize: 15.sp,
          ),
          dropdownColor: isDark ? AppColors.blueGray374957 : AppColors.white,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.body.copyWith(
              color: AppColors.gray8B959E,
              fontSize: 15.sp,
            ),
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: isDark ? AppColors.blueGray374957 : AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(compact ? 12 : 16),
              borderSide: BorderSide(
                color: isDark ? AppColors.blueGray374957 : AppColors.grayD9,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(compact ? 12 : 16),
              borderSide: BorderSide(
                color: isDark ? AppColors.blueGray374957 : AppColors.grayD9,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(compact ? 12 : 16),
              borderSide: BorderSide(
                color: AppColors.blueGray374957.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(compact ? 12 : 16),
              borderSide: const BorderSide(
                color: AppColors.redFF6B6B,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(compact ? 12 : 16),
              borderSide: const BorderSide(
                color: AppColors.redFF6B6B,
                width: 1.5,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: compact ? 1.3.h : 14,
            ),
          ),
          icon: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.blueGray374957.withValues(alpha: 0.3)
                    : AppColors.grayD9.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: isDark ? AppColors.white : AppColors.blueGray374957,
              ),
            ),
          ),
          isExpanded: true,
          menuMaxHeight: 300,
        ),
      ],
    );

    if (width != null) {
      return SizedBox(width: width, child: dropdown);
    }

    return dropdown;
  }
}

class AdEditableDropdown extends StatefulWidget {
  const AdEditableDropdown({
    super.key,
    required this.controller,
    required this.items,
    this.labelText,
    this.hintText,
    this.width,
    this.validator,
    this.enabled = true,
    this.onChanged,
    this.keyboardType,
  });

  final TextEditingController controller;
  final List<String> items;
  final String? labelText;
  final String? hintText;
  final double? width;
  final String? Function(String?)? validator;
  final bool enabled;
  final ValueChanged<String?>? onChanged;
  final TextInputType? keyboardType;

  @override
  State<AdEditableDropdown> createState() => _AdEditableDropdownState();
}

class _AdEditableDropdownState extends State<AdEditableDropdown> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isDropdownOpen = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isDropdownOpen) {
        _closeDropdown();
      }
    });
  }

  @override
  void dispose() {
    _closeDropdown();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_isDropdownOpen) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _closeDropdown() {
    if (!_isDropdownOpen) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownOpen = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 4),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 200,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.blueGray374957
                    : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.blueGray374957
                      : AppColors.grayD9,
                  width: 1,
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return InkWell(
                    onTap: () {
                      widget.controller.text = item;
                      widget.onChanged?.call(item);
                      _closeDropdown();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: index < widget.items.length - 1
                            ? Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.blueGray374957
                                          .withValues(alpha: 0.3)
                                      : AppColors.grayD9.withValues(alpha: 0.5),
                                  width: 0.5,
                                ),
                              )
                            : null,
                      ),
                      child: Text(
                        item,
                        style: AppTypography.body.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.white
                              : AppColors.blueGray374957,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.white : AppColors.blueGray374957,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.blueGray374957 : AppColors.grayD9,
                width: 1,
              ),
              color: isDark ? AppColors.blueGray374957 : AppColors.white,
            ),
            child: widget.validator != null
                ? TextFormField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    validator: widget.validator,
                    keyboardType: widget.keyboardType,
                    onChanged: widget.onChanged,
                    textAlignVertical: TextAlignVertical.center,
                    style: AppTypography.body.copyWith(
                      color:
                          isDark ? AppColors.white : AppColors.blueGray374957,
                      fontSize: 15.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: AppTypography.body.copyWith(
                        color: AppColors.gray8B959E,
                        fontSize: 15.sp,
                      ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: widget.enabled ? _toggleDropdown : null,
                        child: UnconstrainedBox(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.blueGray374957
                                        .withValues(alpha: 0.3)
                                    : AppColors.grayD9.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isDropdownOpen
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 16,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.blueGray374957,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    keyboardType: widget.keyboardType,
                    onChanged: widget.onChanged,
                    textAlignVertical: TextAlignVertical.center,
                    style: AppTypography.body.copyWith(
                      color:
                          isDark ? AppColors.white : AppColors.blueGray374957,
                      fontSize: 15.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: AppTypography.body.copyWith(
                        color: AppColors.gray8B959E,
                        fontSize: 15.sp,
                      ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: widget.enabled ? _toggleDropdown : null,
                        child: UnconstrainedBox(
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.blueGray374957
                                      .withValues(alpha: 0.3)
                                  : AppColors.grayD9.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isDropdownOpen
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 16,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.blueGray374957,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );

    if (widget.width != null) {
      return SizedBox(width: widget.width, child: field);
    }

    return field;
  }
}

class AdCategoryDropdown extends StatelessWidget {
  const AdCategoryDropdown({
    super.key,
    required this.onChanged,
    this.value,
    this.hintText,
    this.labelText,
    this.width,
    this.validator,
    this.enabled = true,
  });

  final ValueChanged<String?> onChanged;
  final String? value;
  final String? hintText;
  final String? labelText;
  final double? width;
  final String? Function(String?)? validator;
  final bool enabled;

  static const List<_CategorySection> _categorySections = [
    _CategorySection(
      heading: 'Popular categories',
      nodes: [
        _CategoryNode(
          id: 'electronics',
          label: 'Electronics',
          children: [
            _CategoryNode(id: 'electronics-phones', label: 'Phones'),
            _CategoryNode(id: 'electronics-computers', label: 'Computers'),
            _CategoryNode(id: 'electronics-accessories', label: 'Accessories'),
          ],
        ),
        _CategoryNode(id: 'fashion', label: 'Fashion'),
        _CategoryNode(id: 'furniture', label: 'Furniture'),
      ],
    ),
    _CategorySection(
      heading: 'Other categories',
      nodes: [
        _CategoryNode(id: 'vehicle', label: 'Vehicle'),
        _CategoryNode(id: 'property', label: 'Property'),
        _CategoryNode(id: 'services', label: 'Services'),
        _CategoryNode(id: 'cosmetics', label: 'Cosmetics'),
        _CategoryNode(id: 'grocery', label: 'Grocery'),
        _CategoryNode(id: 'games', label: 'Games'),
        _CategoryNode(id: 'industrial', label: 'Industrial'),
      ],
    ),
  ];

  static final Map<String, String> _categoryLabelMap = _buildLabelMap();

  static Map<String, String> _buildLabelMap() {
    final map = <String, String>{};

    void visit(_CategoryNode node) {
      map[node.id] = node.label;
      for (final child in node.children) {
        visit(child);
      }
    }

    for (final section in _categorySections) {
      for (final node in section.nodes) {
        visit(node);
      }
    }

    return map;
  }

  Future<String?> _openCategorySheet(BuildContext context) async {
    if (!enabled) return null;

    final selected = await showMultiPageBottomSheet<String>(
      context: context,
      rootPage: MultiPageSheetPage<String>(
        title: labelText ?? 'Product Category',
        sections: _categorySections
            .map((section) => MultiPageSheetSection<String>(
                  heading: section.heading,
                  items: section.nodes.map(_buildItem).toList(),
                ))
            .toList(),
      ),
    );

    return selected;
  }

  static MultiPageSheetItem<String> _buildItem(_CategoryNode node) {
    if (node.children.isNotEmpty) {
      return MultiPageSheetItem<String>(
        label: node.label,
        childBuilder: () => MultiPageSheetPage<String>(
          title: node.label,
          sections: [
            MultiPageSheetSection<String>(
              items: node.children.map(_buildItem).toList(),
            ),
          ],
        ),
      );
    }

    return MultiPageSheetItem<String>(
      label: node.label,
      value: node.id,
    );
  }

  String? _displayLabel(String? id) {
    if (id == null) return null;
    return _categoryLabelMap[id];
  }

  @override
  Widget build(BuildContext context) {
    Widget formField = FormField<String>(
      initialValue: value,
      validator: validator,
      enabled: enabled,
      builder: (state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? AppColors.white : AppColors.blueGray374957;
        if (value != state.value) {
          state.didChange(value);
        }
        final selectedId = state.value;
        final effectiveLabel = _displayLabel(selectedId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (labelText != null) ...[
              Text(
                labelText!,
                style: AppTypography.bodySmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
            ],
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled
                  ? () async {
                      final selected = await _openCategorySheet(context);
                      if (selected != null) {
                        state.didChange(selected);
                        onChanged(selected);
                      }
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.blueGray374957 : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.blueGray374957 : AppColors.grayD9,
                    width: 1,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        effectiveLabel ??
                            (hintText ?? 'Select product category'),
                        style: AppTypography.body.copyWith(
                          color: effectiveLabel == null
                              ? AppColors.gray8B959E
                              : textColor,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.grayD9.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: AppColors.blueGray374957,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.errorText ?? '',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.redFF6B6B,
                  ),
                ),
              ),
          ],
        );
      },
    );

    if (width != null) {
      return SizedBox(width: width, child: formField);
    }

    return formField;
  }
}

class _CategorySection {
  const _CategorySection({
    this.heading,
    required this.nodes,
  });

  final String? heading;
  final List<_CategoryNode> nodes;
}

class _CategoryNode {
  const _CategoryNode({
    required this.id,
    required this.label,
    this.children = const <_CategoryNode>[],
  });

  final String id;
  final String label;
  final List<_CategoryNode> children;
}

class AdLocationDropdown extends StatelessWidget {
  const AdLocationDropdown({
    super.key,
    required this.onChanged,
    this.value,
    this.hintText,
    this.labelText,
    this.width,
    this.validator,
    this.enabled = true,
  });

  final ValueChanged<String?> onChanged;
  final String? value;
  final String? hintText;
  final String? labelText;
  final double? width;
  final String? Function(String?)? validator;
  final bool enabled;

  static const List<String> locations = [
    'Home Spintex',
    'Shop Accra',
    'Shop East Legon',
    'Shop Kumasi',
    'Tema',
    'Takoradi',
    'Ashanti Region',
    'Western Region',
    'Central Region',
    'Greater Accra',
  ];

  @override
  Widget build(BuildContext context) {
    return AdDropdown<String>(
      value: value,
      onChanged: onChanged,
      hintText: hintText ?? 'Ad Area Location',
      labelText: labelText,
      width: width,
      validator: validator,
      enabled: enabled,
      items: locations.map((location) {
        return DropdownMenuItem<String>(
          value: location,
          child: Text(location),
        );
      }).toList(),
    );
  }
}
