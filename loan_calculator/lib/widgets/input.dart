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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.textInputType,
          inputFormatters: widget.textInputType == TextInputType.number
            ? [ThousandsFormatter()]
            : null,
          decoration: InputDecoration(
            labelText: widget.hintText,
            labelStyle: widget.hintStyle?.copyWith(
              color: errorText != null ? Colors.red : widget.hintStyle?.color,
            ),
            suffixStyle: widget.hintStyle,
            prefixStyle: widget.hintStyle,
            prefix: widget.prefix,
            suffix: widget.trailing,
            filled: true,
            fillColor: widget.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : widget.outlinedColor,
                width: 2
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : widget.outlinedColor,
                width: 2
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : widget.outlinedColor,
                width: 2
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        Text(
          errorText ?? ' ',
          style: widget.errorStyle,
        ),
      ]
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

