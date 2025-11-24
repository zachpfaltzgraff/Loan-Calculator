import 'package:flutter/material.dart';

class InputBox extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final Color outlinedColor;
  final Widget? prefix;
  final bool obscureText;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Color backgroundColor;
  final bool autoFocus;
  final Widget? trailing;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;

  const InputBox({
    super.key,
    required this.hintText,
    required this.controller,
    required this.outlinedColor,
    required this.backgroundColor,
    this.autoFocus = false,
    this.textStyle,
    this.prefix,
    this.obscureText = false,
    this.hintStyle,
    this.onSubmitted,
    this.trailing,
    this.focusNode,
  });

  @override
  State<InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Focus(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: widget.outlinedColor,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.outlinedColor,
                offset: const Offset(0, 4),
                blurRadius: 0.0,
                spreadRadius: 0.0,
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                widget.prefix!,
                const SizedBox(width: 8.0),
              ],
              Expanded(
                child: TextField(
                  onTapOutside: (event) {
                    widget.focusNode?.unfocus();
                  },
                  onTap: () {
                    
                  },
                  focusNode: widget.focusNode,
                  onSubmitted: widget.onSubmitted,
                  autofocus: widget.autoFocus,
                  controller: widget.controller,
                  obscureText: widget.obscureText,
                  style: widget.textStyle,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: widget.hintStyle,
                    isCollapsed: true,
                  ),
                ),
              ),
              if (widget.trailing != null)
                widget.trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
