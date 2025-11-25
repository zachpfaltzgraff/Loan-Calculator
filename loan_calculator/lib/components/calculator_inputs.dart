import 'dart:math';
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
  int selectedLoanTermIndex = 0;
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

  // NEW: Payments made
  TextEditingController paymentsMadeController = TextEditingController();
  FocusNode paymentsMadeNode = FocusNode();

  List<PieChartType> pieChartData = [
    PieChartType('Principal', 0, Themes().primaryColor),
    PieChartType('Interest', 0, Colors.red),
  ];

  @override
  void initState() {
    super.initState();
    principalController.addListener(() {
      setState(() {
        String clean = principalController.text.replaceAll(',', '');
        pieChartData[0].amount = double.tryParse(clean) ?? 0;
      });
    });
  }

  calculateResults() {
    try {
      double? principal = principalController.text.isEmpty
          ? null
          : double.parse(principalController.text.replaceAll(',', ''));
      double? annualRate = interestCalculator.text.isEmpty
          ? null
          : double.parse(interestCalculator.text) / 100;
      double? loanTerm = loanTermController.text.isEmpty
          ? null
          : double.parse(loanTermController.text);
      double? paymentAmount = paymentAmountController.text.isEmpty
          ? null
          : double.parse(paymentAmountController.text.replaceAll(',', ''));
      int paymentsMade = paymentsMadeController.text.isEmpty
          ? 0
          : int.parse(paymentsMadeController.text);

      int compoundingFreq = [365, 12, 1][selectedCompoundingIndex];
      int paymentFreqMap = [12, 24, 26, 52][selectedPayFrequency];

      if (loanTerm != null && selectedLoanTermIndex == 0) {
        loanTerm = loanTerm / 12; // convert months to years
      }

      int nullCount = [principal, annualRate, loanTerm, paymentAmount]
          .where((e) => e == null)
          .length;
      if (nullCount != 1) {
        GlobalSnackBar.show(
            'Please leave exactly one field empty to calculate.', Colors.red);
        return;
      }

      double ratePerPeriod(double r) =>
          pow(1 + r / compoundingFreq, compoundingFreq / paymentFreqMap) - 1;

      int totalPayments = ((loanTerm ?? 0) * paymentFreqMap).round();
      int remainingPayments = max(0, totalPayments - paymentsMade);

      if (principal == null) {
        double j = ratePerPeriod(annualRate!);
        principal = paymentAmount! * (1 - pow(1 + j, -totalPayments)) / j;
        principalController.text = principal.toStringAsFixed(2);
      } else if (paymentAmount == null) {
        double j = ratePerPeriod(annualRate!);
        paymentAmount = principal * j / (1 - pow(1 + j, -totalPayments));
        paymentAmountController.text = paymentAmount.toStringAsFixed(2);
      } else if (loanTerm == null) {
        double j = ratePerPeriod(annualRate!);
        double N = -log(1 - principal * j / paymentAmount) / log(1 + j);
        loanTerm = N / paymentFreqMap;
        if (selectedLoanTermIndex == 0) loanTerm = loanTerm * 12;
        loanTermController.text = loanTerm.toStringAsFixed(1);
      } else if (annualRate == null) {
        double low = 0.0;
        double high = 1.0;
        double r = 0.05;
        for (int i = 0; i < 1000; i++) {
          r = (low + high) / 2;
          double j = ratePerPeriod(r);
          double estimate = principal * j / (1 - pow(1 + j, -totalPayments));
          if ((estimate - paymentAmount).abs() < 1e-8) break;
          if (estimate > paymentAmount) {
            high = r;
          } else {
            low = r;
          }
        }
        annualRate = r;
        interestCalculator.text = (annualRate * 100).toStringAsFixed(3);
      }

      // 5️⃣ Update Pie Chart with payments made
      double j = ratePerPeriod(annualRate!);
      double principalRemaining = principal * pow(1 + j, paymentsMade) -
          paymentAmount * (pow(1 + j, paymentsMade) - 1) / j;
      double interestRemaining = (paymentAmount * remainingPayments) - principalRemaining;

      pieChartData[0].amount = max(0, principalRemaining);
      pieChartData[1].amount = max(0, interestRemaining);
      setState(() {});

      GlobalSnackBar.show('Calculation complete', Colors.green);
    } catch (e) {
      GlobalSnackBar.show('Invalid input: ${e.toString()}', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Themes>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                    textInputType: TextInputType.numberWithOptions(decimal: true),
                    prefix: Text('\$', style: theme.textStyle(context)),
                    validations: [InputValidation.onlyNumbers()],
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
                    trailing: Text('%', style: theme.textStyle(context)),
                    validations: [InputValidation.onlyNumbers()],
                  ),
                  dropdownWidget(
                      theme, context, selectedCompoundingIndex, compoundingFrequency, 'Compounding Frequency'),
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
                          validations: [InputValidation.onlyNumbers()],
                        ),
                      ),
                      Flexible(
                          child: dropdownWidget(theme, context, selectedLoanTermIndex, loanTerms, 'Term Length')),
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
                          prefix: Text('\$', style: theme.textStyle(context)),
                          validations: [InputValidation.onlyNumbers()],
                        ),
                      ),
                      Flexible(
                        child: dropdownWidget(theme, context, selectedPayFrequency, payFrequency, 'Frequency')),
                    ],
                  ),
                  // NEW: Payments Made
                  InputBox(
                    hintText: 'Payments Made',
                    controller: paymentsMadeController,
                    outlinedColor: theme.primaryColor,
                    backgroundColor: theme.backgroundColor,
                    errorStyle: theme.hintStyle(context).copyWith(color: Colors.red),
                    hintStyle: theme.textStyle(context),
                    focusNode: paymentsMadeNode,
                    textInputType: TextInputType.number,
                    validations: [InputValidation.onlyNumbers()],
                  ),
                  PieChartWidget(data: pieChartData),
                ],
              ),
            ),
          ),
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
                calculateResults();
              },
              textStyle: theme.textStyle(context)
            ),
          ),
        ],
      ),
    );
  }

  Widget dropdownWidget(
      Themes theme, BuildContext context, int index, List<String> list, String label) {
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
