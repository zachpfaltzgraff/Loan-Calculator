import 'package:flutter/material.dart';
import 'package:loan_calculator/themes/theme.dart';
import 'package:loan_calculator/themes/vibrator.dart';
import 'package:loan_calculator/widgets/input.dart';
import 'package:loan_calculator/widgets/input_validations.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CalculatorInputs extends StatefulWidget {
  const CalculatorInputs({super.key});

  @override
  State<CalculatorInputs> createState() => _CalculatorInputsState();
}

class _CalculatorInputsState extends State<CalculatorInputs> {
  TextEditingController principalController = TextEditingController();
  FocusNode principalNode = FocusNode();

  TextEditingController interestCalculator = TextEditingController();
  FocusNode interestNode = FocusNode();

  List<String> compoundingFrequency = [
    'Daily (365)',
    'Monthly (12)',
    'Yearly (1)',
  ];
  int selectedCompoundingIndex = 0; 

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
            hintStyle: theme.textStyle(context),
            focusNode: principalNode,
            textInputType: TextInputType.number,
            prefix: Text('\$', style: theme.textStyle(context),),
            validations: [
              InputValidation.onlyNumbers(),
            ],
          ),
          InputBox(
            hintText: 'Interest', 
            controller: interestCalculator, 
            outlinedColor: theme.primaryColor, 
            backgroundColor: theme.backgroundColor,
            errorStyle: theme.hintStyle(context).copyWith(color: Colors.red),
            hintStyle: theme.textStyle(context),
            focusNode: interestNode,
            textInputType: TextInputType.numberWithOptions(decimal: true),
            trailing: Text('%', style: theme.textStyle(context),),
            validations: [
              InputValidation.onlyNumbers(),
            ],
          ),
          compoundingInterestBox(theme, context),
        ],
      ),
    );
  }

  DropdownButtonFormField<int> compoundingInterestBox(Themes theme, BuildContext context) {
    return DropdownButtonFormField<int>(
      value: selectedCompoundingIndex,
      onChanged: (int? newIndex) {
        if (selectedCompoundingIndex != newIndex) Vibrator().vibrateShort();
        setState(() {
          selectedCompoundingIndex = newIndex!;
        });
      },
      onTap: () {
        Vibrator().vibrateShort();
      },
      decoration: InputDecoration(
        labelText: 'Compounding Frequency',
        labelStyle: theme.textStyle(context),
        filled: true,
        fillColor: theme.backgroundColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.primaryColor,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.primaryColor,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.primaryColor,
            width: 2.5,
          ),
        ),
      ),
      dropdownColor: theme.backgroundColor,
      icon: const Icon(Icons.arrow_drop_down_outlined),
      borderRadius: BorderRadius.circular(12),
      items: List.generate(compoundingFrequency.length, (index) {
        final item = compoundingFrequency[index];
        return DropdownMenuItem<int>(
          value: index,
          child: Text(item, style: theme.textStyle(context)),
        );
      }),
    );
  }
}