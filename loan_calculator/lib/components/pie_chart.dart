import 'package:loan_calculator/themes/theme.dart';
import 'package:loan_calculator/themes/vibrator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, double> data;

  const PieChartWidget({super.key, required this.data});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  double total = 0;
  int? touchedIndex; // moved here so it persists across rebuilds

  @override
  void initState() {
    super.initState();
    total = widget.data.values.fold(0, (prev, amount) => prev + amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Themes>(context);
    final entries = widget.data.entries.toList();

    final List<PieChartSectionData> sections = List.generate(widget.data.length, (i) {
      final label = entries[i].key;
      final value = entries[i].value;
      final percentage = total == 0 ? 0.0 : (value / total) * 100;
      final isTouched = i == touchedIndex;

      return PieChartSectionData(
        value: value,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '$label',
        radius: isTouched
          ? MediaQuery.of(context).size.height * 0.09
          : MediaQuery.of(context).size.height * 0.08,
        titleStyle: theme.textStyle(context).copyWith(
          color: theme.textColor,
          fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
        ),
        titlePositionPercentageOffset: (percentage < 5) ? 1.5 : 0.5,
        color: theme.primaryColor,
      );
    });

    return Column(
      children: [
        Text('Amount Paid', style: theme.textStyle(context)),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.30,
          child: widget.data.isEmpty
            ? Center(
              child: Text('No Data', style: theme.textStyle(context)),
            )
            : Column(
              children: [
                Center(
                  child: Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: theme.textStyle(context).copyWith(color: theme.textColor),
                  ),
                ),
                Center(
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: MediaQuery.of(context).size.height * 0.08,
                      sectionsSpace: 3,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.touchedSection == null) {
                              touchedIndex = null;
                            } else {
                              final index = response.touchedSection!.touchedSectionIndex;
                              if (touchedIndex != index && index != -1) {
                                Vibrator().vibrateShort();
                              }
                              touchedIndex = index;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ),
      ],
    );
  }
}
