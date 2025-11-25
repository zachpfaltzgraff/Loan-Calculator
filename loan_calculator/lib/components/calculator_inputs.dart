import 'package:flutter/material.dart';
import 'package:loan_calculator/components/pie_chart.dart';
import 'package:loan_calculator/themes/raised_button.dart';
import 'package:loan_calculator/themes/theme.dart';
import 'package:loan_calculator/themes/vibrator.dart';
import 'package:loan_calculator/widgets/global_keys.dart';
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

  TextEditingController interestCalculator = TextEditingController();
  FocusNode interestNode = FocusNode();

  List<String> compoundingFrequency = [
    'Daily (365)',
    'Monthly (12)',
    'Yearly (1)',
  ];
  int selectedCompoundingIndex = 0; 

  List<String> loanTerms = [
    'Month(s)',
    'Year(s)',
  ];
  int selectedLoanTermIndex= 0; 
  TextEditingController loanTermController = TextEditingController();
  FocusNode loanNode = FocusNode();

  List<String> payFrequency = [
    'Monthly',
    'Semi-Monthly',
    'Bi-Weekly',
    'Weekly',
  ];
  int selectedPayFrequency = 0; 
  TextEditingController paymentAmountController = TextEditingController();
  FocusNode paymentAmountNode = FocusNode();

  List<PieChartType> pieChartData = [
    PieChartType('Principal', 0, Themes().primaryColor),
    PieChartType('Interest', 0, Colors.red)
  ];


  @override
  void initState() {
    super.initState();
    principalController.addListener(() {
      setState(() {
        String clean = principalController.text.replaceAll(',', '');
        pieChartData[0].amount = double.parse(clean);
      });
    });
  }


  calculateResults() {
    for(int i = 0; i < 6; i++) {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Themes>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 15,
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
          // compounding frequency box
          dropdownWidget(theme, context, selectedCompoundingIndex, compoundingFrequency, 'Compounding Frequency'),

          // Loan Term
          Row(
            spacing: 15,
            children: [
              Flexible(
                child: InputBox(
                  hintText: 'Loan Term', 
                  controller: loanTermController, 
                  outlinedColor: theme.primaryColor, 
                  backgroundColor: theme.backgroundColor,
                  errorStyle: theme.hintStyle(context).copyWith(color: Colors.red),
                  hintStyle: theme.textStyle(context),
                  focusNode: loanNode,
                  textInputType: TextInputType.numberWithOptions(decimal: true),
                  validations: [
                    InputValidation.onlyNumbers(),
                  ],
                ),
              ),
              Flexible(
                child: dropdownWidget(theme, context, selectedLoanTermIndex, loanTerms, 'Term Length')
              ),
            ],
          ),
          Row(
            spacing: 20,
            children: [
              Flexible(
                child: InputBox(
                  hintText: 'Payment Amount', 
                  controller: paymentAmountController, 
                  outlinedColor: theme.primaryColor, 
                  backgroundColor: theme.backgroundColor,
                  errorStyle: theme.hintStyle(context).copyWith(color: Colors.red),
                  hintStyle: theme.textStyle(context),
                  focusNode: paymentAmountNode,
                  textInputType: TextInputType.numberWithOptions(decimal: true),
                  prefix: Text('\$', style: theme.textStyle(context),),
                  validations: [
                    InputValidation.onlyNumbers(),
                  ],
                ),
              ),
              Flexible(
                child: dropdownWidget(theme, context, selectedPayFrequency, payFrequency, 'Frequency')
              ),
            ],
          ),
          PieChartWidget(data: pieChartData),
          Spacer(),
          // TODO have an add here
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: BoxBorder.all(
                width: 2,
                color: theme.primaryColor,
              )
            ),
            child: RaisedButton(
              text: 'Calculate', 
              width: double.infinity,
              primaryColor: theme.primaryColor,
              backgroundColor: theme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              onPressed: () {
                GlobalSnackBar.show('Hello', theme.primaryColor);
              },
              textStyle: theme.textStyle(context)
            ),
          ),
        ],
      ),
    );
  }

  Widget dropdownWidget(Themes theme, BuildContext context, int index, List<String> list, String label) {
    return DropdownButtonFormField<int>(
      value: index,
      onChanged: (int? newIndex) {
        if (index != newIndex) Vibrator().vibrateShort();
        setState(() {
          index = newIndex!;
        });
      },
      onTap: () {
        Vibrator().vibrateShort();
      },
      decoration: InputDecoration(
        labelText: label,
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
      items: List.generate(list.length, (index) {
        final item = list[index];
        return DropdownMenuItem<int>(
          value: index,
          child: Text(item, style: theme.textStyle(context)),
        );
      }),
    );
  }
}