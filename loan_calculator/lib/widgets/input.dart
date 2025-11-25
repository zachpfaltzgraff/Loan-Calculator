import 'package:flutter/material.dart';
import 'package:loan_calculator/widgets/input_validations.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class NumberTextInputFormatter extends TextInputFormatter {
  final NumberFormat formatter = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all commas to get the raw number
    String cleanText = newValue.text.replaceAll(',', '');

    // Check if it's a valid number format (allow digits and one decimal point)
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(cleanText)) {
      return oldValue;
    }

    // If it's just a period, allow it
    if (cleanText == '.') {
      return newValue;
    }

    // Handle decimal numbers
    if (cleanText.contains('.')) {
      List<String> parts = cleanText.split('.');
      String integerPart = parts[0];
      String decimalPart = parts.length > 1 ? parts[1] : '';

      // If integer part is empty (like ".5"), allow it
      if (integerPart.isEmpty) {
        return newValue;
      }

      try {
        int intValue = int.parse(integerPart);
        String formatted = formatter.format(intValue);
        String finalText = '$formatted.$decimalPart';

        // Calculate new cursor position
        int digitsBeforeCursor = newValue.text.substring(0, newValue.selection.end).replaceAll(',', '').length;
        
        // Find where cursor should be in formatted text
        int commasBeforeCursor = 0;
        int digitCount = 0;
        
        for (int i = 0; i < finalText.length && digitCount < digitsBeforeCursor; i++) {
          if (finalText[i] == ',') {
            commasBeforeCursor++;
          } else {
            digitCount++;
          }
        }

        int newCursorPos = digitsBeforeCursor + commasBeforeCursor;

        return TextEditingValue(
          text: finalText,
          selection: TextSelection.collapsed(offset: newCursorPos.clamp(0, finalText.length)),
        );
      } catch (e) {
        return oldValue;
      }
    } else {
      // No decimal point
      if (cleanText.isEmpty) {
        return newValue;
      }

      try {
        int value = int.parse(cleanText);
        String formatted = formatter.format(value);

        // Calculate cursor position based on comma changes
        int digitsBeforeCursor = newValue.text.substring(0, newValue.selection.end).replaceAll(',', '').length;
        
        // Count commas before cursor position in formatted text
        int commasBeforeCursor = 0;
        int digitCount = 0;
        for (int i = 0; i < formatted.length; i++) {
          if (formatted[i] == ',') {
            commasBeforeCursor++;
          } else {
            digitCount++;
            if (digitCount >= digitsBeforeCursor) {
              break;
            }
          }
        }

        int newCursorPos = digitsBeforeCursor + commasBeforeCursor;

        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: newCursorPos.clamp(0, formatted.length)),
        );
      } catch (e) {
        return oldValue;
      }
    }
  }
}

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
          clipBehavior: Clip.none,
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.textInputType,
          style: widget.textStyle,
          inputFormatters: [NumberTextInputFormatter()],
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
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : widget.outlinedColor,
                width: 2
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : widget.outlinedColor,
                width: 2
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : widget.outlinedColor,
                width: 2
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ]
    );
  }
}