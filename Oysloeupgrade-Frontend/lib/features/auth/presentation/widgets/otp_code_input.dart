import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class OtpCodeInput extends StatefulWidget {
  const OtpCodeInput({super.key, this.length = 6, this.onChanged});

  final int length;
  final ValueChanged<String>? onChanged;

  @override
  State<OtpCodeInput> createState() => _OtpCodeInputState();
}

class _OtpCodeInputState extends State<OtpCodeInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _applyPastedText(int startIndex, String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;
    int j = 0;
    for (int i = startIndex; i < widget.length && j < digits.length; i++, j++) {
      _controllers[i].text = digits[j];
      _controllers[i].selection = TextSelection.fromPosition(
        TextPosition(offset: _controllers[i].text.length),
      );
    }
    final next = startIndex + digits.length;
    if (next < widget.length) {
      _focusNodes[next].requestFocus();
    } else {
      _focusNodes[widget.length - 1].unfocus();
    }
    _notifyChange();
  }

  void _notifyChange() {
    final code = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);
  }

  @override
  Widget build(BuildContext context) {
    final fields = List.generate(widget.length, (i) {
      return SizedBox(
        width: 10.5.w,
        child: Focus(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace &&
                _controllers[i].text.isEmpty) {
              if (i > 0) {
                _focusNodes[i - 1].requestFocus();
                _controllers[i - 1].text = '';
                _controllers[i - 1].selection = const TextSelection.collapsed(
                  offset: 0,
                );
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: TextField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            autofocus: i == 0,
            textAlign: TextAlign.center,
            style: AppTypography.medium.copyWith(fontSize: 18.sp),
            keyboardType: TextInputType.number,
            textInputAction: i == widget.length - 1
                ? TextInputAction.done
                : TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (v) {
              if (v.length > 1) {
                _applyPastedText(i, v);
                return;
              }
              if (v.isNotEmpty) {
                if (i < widget.length - 1) {
                  _focusNodes[i + 1].requestFocus();
                } else {
                  _focusNodes[i].unfocus();
                }
              }
              if (v.isEmpty && i > 0) {
                _focusNodes[i - 1].requestFocus();
              }
              setState(() {});
              _notifyChange();
            },
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.symmetric(vertical: 1.6.h),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: AppColors.grayBFBF),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                borderSide: BorderSide(color: AppColors.blueGray374957),
              ),
            ),
          ),
        ),
      );
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < fields.length; i++) ...[
          fields[i],
          if (i != fields.length - 1) SizedBox(width: 3.w),
        ],
      ],
    );
  }
}
