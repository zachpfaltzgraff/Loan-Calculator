import 'package:flutter/material.dart';
import 'package:loan_calculator/themes/theme.dart';
import 'package:loan_calculator/widgets/input.dart';
import 'package:loan_calculator/widgets/input_validations.dart';
import 'package:provider/provider.dart';

class CalculatorInputs extends StatefulWidget {
  const CalculatorInputs({super.key});

  @override
  State<CalculatorInputs> createState() => _CalculatorInputsState();
}

class _CalculatorInputsState extends State<CalculatorInputs> {
  TextEditingController principalController = TextEditingController();
  FocusNode principalNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Themes>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          InputBox(
            hintText: 'Principal Balance', 
            controller: principalController, 
            outlinedColor: theme.primaryColor, 
            backgroundColor: theme.backgroundColor,
            errorStyle: theme.hintStyle(context).copyWith(color: Colors.red),
            focusNode: principalNode,
            textInputType: TextInputType.number,
            prefix: Text('\$', style: theme.textStyle(context),),
            validations: [
              InputValidation.onlyNumbers(),
              InputValidation.minValue(1),
            ],
          )
        ],
      ),
    );
  }
}