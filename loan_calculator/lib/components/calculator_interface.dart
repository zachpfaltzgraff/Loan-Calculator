import 'package:flutter/material.dart';
import 'package:loan_calculator/components/calculator_inputs.dart';
import 'package:loan_calculator/themes/theme.dart';
import 'package:provider/provider.dart';

class CalculatorInterface extends StatefulWidget {
  const CalculatorInterface({super.key});

  @override
  State<CalculatorInterface> createState() => _CalculatorInterfaceState();
}

class _CalculatorInterfaceState extends State<CalculatorInterface> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Themes>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('LoanSense', style: theme.titleStyle(context),),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: CalculatorInputs(),
    );
  }
}