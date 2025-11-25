import 'package:loan_calculator/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GlobalSnackBar {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void show(String message, Color backgroundColor) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => SnackBarWidget(
        message: message,
        backgroundColor: backgroundColor,
        onDismiss: () => entry?.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class SnackBarWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final VoidCallback onDismiss;

  const SnackBarWidget({
    super.key, 
    required this.message,
    required this.backgroundColor,
    required this.onDismiss,
  });

  @override
  SnackBarWidgetState createState() => SnackBarWidgetState();
}

class SnackBarWidgetState extends State<SnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted || _controller.isDismissed) return;
      _controller.reverse().then((_) => widget.onDismiss());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Themes>(context);

    return Positioned(
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Dismissible(
              key: Key('1'),
              direction: DismissDirection.up,
              onDismissed: (direction) {
                _controller.stop();
                widget.onDismiss();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: theme.textStyle(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
