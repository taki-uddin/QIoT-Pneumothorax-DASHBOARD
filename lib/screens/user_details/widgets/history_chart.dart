import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pneumothoraxdashboard/constants/app_colors.dart';

class HistoryChart extends StatelessWidget {
  final List<dynamic> data;
  final String yAxisField; // Field name for y-axis values
  final String xAxisLabel;
  final String yAxisLabel;
  final Color lineColor;
  final double lineWidth;
  final bool showGrid;
  final bool showDots;
  final bool showBelowBar;

  const HistoryChart({
    super.key,
    required this.data,
    required this.yAxisField, // Specify which field to use for y-axis values
    this.xAxisLabel = 'Date',
    this.yAxisLabel = 'Value',
    this.lineColor = AppColors.primaryBlue,
    this.lineWidth = 2.0,
    this.showGrid = false,
    this.showDots = true,
    this.showBelowBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final range = data.length;

    // Convert data to FlSpot
    List<FlSpot> spots = data
        .map((item) {
          final createdAt = DateTime.tryParse(item['createdAt']);
          final value = item[yAxisField]?.toDouble(); // Use specified field

          // Ensure both createdAt and value are valid
          if (createdAt != null && value != null && value.isFinite) {
            // Use timestamp for x-axis
            return FlSpot(
              createdAt.millisecondsSinceEpoch.toDouble(),
              value,
            );
          } else {
            return null; // Discard invalid entries
          }
        })
        .where((spot) => spot != null)
        .cast<FlSpot>()
        .toList();

    // Determine the min and max values for x and y axes
    double minX = spots.isNotEmpty
        ? spots.map((e) => e.x).reduce((a, b) => a < b ? a : b)
        : 0;
    double maxX = spots.isNotEmpty
        ? spots.map((e) => e.x).reduce((a, b) => a > b ? a : b)
        : 0;
    double minY = spots.isNotEmpty
        ? spots.map((e) => e.y).reduce((a, b) => a < b ? a : b)
        : 0;
    double maxY = spots.isNotEmpty
        ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 1000;

    // Handle cases with no data or only one data point
    final xInterval = (range > 1) ? (maxX - minX) / (range - 1) : 1.0;
    final yInterval = (range > 1) ? (maxY - minY) / (range - 1) : 1.0;

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => AppColors.highlightLight,
          ),
        ),
        gridData: FlGridData(show: showGrid),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 128,
              interval: xInterval, // Adjust based on number of x-ticks
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              getTitlesWidget: leftTitleWidgets,
              showTitles: true,
              interval: yInterval, // Adjust based on number of y-ticks
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.highlightLight, width: 1),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: false,
            color: lineColor,
            barWidth: lineWidth,
            isStrokeCapRound: true,
            dotData: FlDotData(show: showDots),
            belowBarData: BarAreaData(show: showBelowBar),
            spots: spots,
          ),
        ],
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
      ),
      duration: const Duration(milliseconds: 250),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 14,
    );

    // Round the value to a reasonable precision for display
    String text = value.toInt().toString();

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 10,
      color: Colors.black, // Adjust the color based on your design
    );

    // Convert the x-axis value (milliseconds since epoch) back to a DateTime object
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());

    // Format the date as 'Sep 13, 2024 03:20 PM'
    final formattedDate = DateFormat('MMM d, yyyy hh:mm a').format(date);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: RotatedBox(
        quarterTurns: 3, // Rotates the text to vertical
        child: Text(formattedDate, style: style, textAlign: TextAlign.center),
      ),
    );
  }
}
