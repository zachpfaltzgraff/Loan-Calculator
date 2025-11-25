import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:loan_calculator/themes/vibrator.dart';

class RaisedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color primaryColor;
  final Color backgroundColor;
  final double? width;
  final TextStyle textStyle;
  final BorderRadius? borderRadius;

  const RaisedButton(
    {required this.text, 
    required this.primaryColor, 
    required this.onPressed,
    required this.backgroundColor,
    this.width,
    this.borderRadius,
    required this.textStyle,
    super.key});

  @override
  State<RaisedButton> createState() => _RaisedButtonState();
}

class _RaisedButtonState extends State<RaisedButton> {
  bool isPressed = false;
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown:(details) {
        Vibrator().vibrateShort();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(500.0),
          color: widget.primaryColor,
          border: Border.all(
            width: 2,
            color: widget.backgroundColor,
          ),
        ),
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: widget.textStyle,
        ),
      ),
    );
  }
}
