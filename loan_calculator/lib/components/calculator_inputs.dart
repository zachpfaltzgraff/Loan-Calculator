import 'package:flutter/material.dart';
import 'package:loan_calculator/themes/theme.dart';
import 'package:provider/provider.dart';

class CalculatorInputs extends StatefulWidget {
  const CalculatorInputs({super.key});

  @override
  State<CalculatorInputs> createState() => _CalculatorInputsState();
}

class _CalculatorInputsState extends State<CalculatorInputs> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Themes>(context);

    return const Placeholder();
  }
}