import 'package:flutter/material.dart';
import 'package:loan_calculator/widgets/input_validations.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class InputBox extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final Color outlinedColor;
  final Widget? prefix;
  final bool obscureText;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final TextStyle? errorStyle;
  final Color backgroundColor;
  final bool autoFocus;
  final Widget? trailing;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;

  final List<InputValidation>? validations;
  final TextInputType? textInputType;

  const InputBox({
    super.key,
    required this.hintText,
    required this.controller,
    required this.outlinedColor,
    required this.backgroundColor,
    this.prefix,
    this.textStyle,
    this.hintStyle,
    this.trailing,
    this.autoFocus = false,
    this.obscureText = false,
    this.onSubmitted,
    this.focusNode,
    this.validations,
    this.textInputType,
    this.errorStyle
  });

  @override
  State<InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  String? errorText;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      _runValidation(widget.controller.text);
    });
  }

  void _runValidation(String value) {
    if (widget.validations == null) return;

    for (var v in widget.validations!) {
      if (!v.validate(value)) {
        setState(() => errorText = v.errorMessage);
        return;
      }
    }

    setState(() => errorText = null);
  }

  bool get hasError => errorText != null;

  @override
  Widget build(BuildContext context) {
    final outlineColor = hasError ? Colors.red : widget.outlinedColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: outlineColor, width: 2),
          ),
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                widget.prefix!,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.textInputType,
                  autofocus: widget.autoFocus,
                  onSubmitted: widget.onSubmitted,
                  inputFormatters: widget.textInputType == TextInputType.number
                    ? [ThousandsFormatter()]
                    : null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: widget.hintStyle?.copyWith(
                      color: hasError ? Colors.red : widget.hintStyle?.color,
                    ),
                    isCollapsed: true,
                  ),
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),

        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 3),
            child: Text(
              errorText!,
              style: widget.errorStyle,
            ),
          )
      ],
    );
  }
}


class ThousandsFormatter extends TextInputFormatter {
  final NumberFormat formatter = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String cleaned = newValue.text.replaceAll(',', '');
    if (cleaned.isEmpty) return newValue;

    int? number = int.tryParse(cleaned);
    if (number == null) return oldValue;

    final newText = formatter.format(number);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

