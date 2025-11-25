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

  resetValues() {
    setState(() {
      principalController.text = '';
      interestCalculator.text = '';
      selectedCompoundingIndex = 0;
      selectedPayFrequency = 0;
      paymentAmountController.text = '';
      loanTermController.text = '';
      pieChartData = [
        PieChartType('Principal', 0, Themes().primaryColor),
        PieChartType('Interest', 0, Colors.red),
      ];
    });
  }

  calculateResults({String? forceCalculate}) {
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

      int compoundingFreq = [365, 12, 1][selectedCompoundingIndex];
      int paymentFreqMap = [12, 24, 26, 52][selectedPayFrequency];

      if (loanTerm != null && selectedLoanTermIndex == 0) {
        loanTerm = loanTerm / 12;
      }

      // Force calculate specific field
      if (forceCalculate != null) {
        switch (forceCalculate) {
          case 'principal':
            principal = null;
            break;
          case 'interest':
            annualRate = null;
            break;
          case 'loanTerm':
            loanTerm = null;
            break;
          case 'payment':
            paymentAmount = null;
            break;
        }
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

      // Calculate missing field
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
        totalPayments = N.round();
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

      // Calculate pie chart data - total over lifetime of loan
      double j = ratePerPeriod(annualRate);
      double totalPaymentAmount = paymentAmount * totalPayments;
      double totalInterest = totalPaymentAmount - principal;
      
      pieChartData[0].amount = principal;
      pieChartData[1].amount = totalInterest > 0 ? totalInterest : 0;
      
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
                spacing: 10,
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        child: InputBox(
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
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: theme.primaryColor),
                        onPressed: () {
                          Vibrator().vibrateShort();
                          calculateResults(forceCalculate: 'principal');
                        },
                      ),
                    ],
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        child: Row(
                          spacing: 5,
                          children: [
                            Expanded(
                              child: InputBox(
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
                            ),
                            Expanded(
                              child: dropdownWidget(
                                theme, 
                                context, 
                                compoundingFrequency, 
                                'Compounding Freq.',
                                (newIndex) {
                                  setState(() {
                                    selectedCompoundingIndex = newIndex;
                                  });
                                },
                                selectedCompoundingIndex,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: theme.primaryColor),
                        onPressed: () {
                          Vibrator().vibrateShort();
                          calculateResults(forceCalculate: 'interest');
                        },
                      ),
                    ],
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        child: Row(
                          spacing: 5,
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
                              child: dropdownWidget(
                                theme, 
                                context, 
                                loanTerms, 
                                'Term Length',
                                (newIndex) {
                                  setState(() {
                                    selectedLoanTermIndex = newIndex;
                                  });
                                },
                                selectedLoanTermIndex,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: theme.primaryColor),
                        onPressed: () {
                          Vibrator().vibrateShort();
                          calculateResults(forceCalculate: 'loanTerm');
                        },
                      ),
                    ],
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        child: Row(
                          spacing: 5,
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
                              child: dropdownWidget(
                                theme, 
                                context, 
                                payFrequency, 
                                'Frequency',
                                (newIndex) {
                                  setState(() {
                                    selectedPayFrequency = newIndex;
                                  });
                                },
                                selectedPayFrequency,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: theme.primaryColor),
                        onPressed: () {
                          Vibrator().vibrateShort();
                          calculateResults(forceCalculate: 'payment');
                        },
                      ),
                    ],
                  ),
                  PieChartWidget(data: pieChartData),
                ],
              ),
            ),
          ),
          Row(
            spacing: 5,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      width: 2,
                      color: Colors.red,
                    )
                  ),
                  child: RaisedButton(
                    text: 'Reset',
                    width: double.infinity,
                    primaryColor:  Colors.red,
                    backgroundColor: theme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () {
                      resetValues();
                      GlobalSnackBar.show('Values all Reset', theme.primaryColor);
                    },
                    textStyle: theme.textStyle(context)
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget dropdownWidget(
    Themes theme, 
    BuildContext context, 
    List<String> list, 
    String label,
    Function(int) onChanged,
    int currentValue,
  ) {
    return DropdownButtonFormField<int>(
      value: currentValue,
      onChanged: (int? newIndex) {
        if (newIndex != null && currentValue != newIndex) {
          Vibrator().vibrateShort();
          onChanged(newIndex);
        }
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