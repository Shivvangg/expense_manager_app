import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class ExpensesBarChart extends StatelessWidget {
  final List<double> monthlyExpenses;
  final List<String> months; // Add months parameter

  const ExpensesBarChart({
    required this.monthlyExpenses,
    required this.months, // Initialize months
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: const ChartTitle(
        text: 'Monthly Expenses',
        textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      legend: const Legend(
        isVisible: false,
      ),
      primaryXAxis: const CategoryAxis(
        labelStyle: TextStyle(color: Colors.white),
        axisLine: AxisLine(color: Colors.white),
        majorGridLines: MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
        labelStyle: const TextStyle(color: Colors.white),
        axisLine: const AxisLine(color: Colors.white),
        majorGridLines: const MajorGridLines(
          color: Colors.white24,
          dashArray: [5, 5],
        ),
      ),
      series: <CartesianSeries>[
        ColumnSeries<double, String>(
          dataSource: monthlyExpenses,
          xValueMapper: (double expense, int index) {
            return months[index]; // Use the months list for X values
          },
          yValueMapper: (double expense, _) => expense,
          color: Colors.teal,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          enableTooltip: true,
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: Colors.teal,
        textStyle: const TextStyle(color: Colors.white),
      ),
      plotAreaBorderWidth: 0,
    );
  }
}
