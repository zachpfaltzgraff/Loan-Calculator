import 'package:flutter/material.dart';
import 'package:loan_calculator/components/calculator_interface.dart';
import 'package:loan_calculator/themes/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Themes>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: theme.isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: Container(
        color: theme.backgroundColor,
        child: SafeArea(
          child: CalculatorInterface()
        ),
      ),
    );
  }
}