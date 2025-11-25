import 'package:intl/intl.dart';
import 'package:loan_calculator/themes/theme.dart';
import 'package:loan_calculator/themes/vibrator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PieChartType {
  String label;
  double amount;
  Color color;

  PieChartType(
    this.label,
    this.amount,
    this.color
  );
}

class PieChartWidget extends StatefulWidget {
  final List<PieChartType> data;

  const PieChartWidget({super.key, required this.data});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  double total = 0;
  int? touchedIndex;
  final formatter = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    for(int i = 0; i < widget.data.length; i++) {
      total += widget.data[i].amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Themes>(context);
    final entries = widget.data;

    final List<PieChartSectionData> sections = List.generate(widget.data.length, (i) {
      final label = entries[i].label;
      final value = entries[i].amount;
      final percentage = total == 0 ? 0.0 : (value / total) * 100;
      final isTouched = i == touchedIndex;

      return PieChartSectionData(
        value: value,
        title: isTouched ? '\$${formatter.format(entries[i].amount)}' : label,
        radius: isTouched ? 120 : 110, // use fixed radius in pixels
        titleStyle: theme.textStyle(context).copyWith(
          color: theme.textColor,
          fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
        ),
        titlePositionPercentageOffset: (percentage < 5) ? 1.5 : 0.5,
        color: entries[i].color,
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Amount Paid', style: theme.textStyle(context), textAlign: TextAlign.center),
        Text('\$${formatter.format(total)}', style: theme.textStyle(context), textAlign: TextAlign.center,),
        SizedBox(
          height: 240,
          child: widget.data.isEmpty
            ? Center(
              child: Text('No Data', style: theme.textStyle(context)),
            )
            : LayoutBuilder(
              builder: (context, constraints) {
                return PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 0,
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
                );
              },
            ),
        ),
      ],
    );
  }
}
