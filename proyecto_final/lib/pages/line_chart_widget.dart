import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  LineChartWidget({
    Key? key,
    required this.ultimos30,


  }) : super(key: key);

  final List<Color> gradientColors = [
    const Color(0xFF2C7F8C),
    Color.fromARGB(255, 98, 189, 203),
  ];

  final int ultimos30;

  


  double get maxY {
    double maxReservas = [
      ultimos30.toDouble(),
    ].reduce((a, b) => a > b ? a : b);
    return (maxReservas * 1.5).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final double maxYValue = maxY == 0 ? 5 : maxY;
    final double interval = maxYValue / 5 > 0 ? maxYValue / 5 : 1; 

    return LineChart(
      LineChartData(
        backgroundColor: const Color(0xffE0E0E0),
        minX: 0,
        maxX: 2,
        minY: 0,
        maxY: maxYValue,
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTextStyles: (context, value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            margin: 6,
            getTitles: (double value) {
                if (value.toInt() == 1) {
                  return 'Ultimos 30 días';
                }
              return '';
            },
          ),
          leftTitles: SideTitles(
            showTitles: true,
            getTextStyles: (context, value) => const TextStyle(
              color: Color.fromRGBO(2, 6, 11, 1),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            reservedSize: 35,
            margin: 10,
            interval: interval, 
            getTitles: (double value) {
              return value.toInt().toString();
            },
          ),
        ),
        gridData: FlGridData(
          show: false,
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 2),
        ),
        lineBarsData: [
         LineChartBarData(
  spots:  ([
              FlSpot(0, 0),
              FlSpot(1, ultimos30.toDouble()),
            ]),
            isCurved: true,
            colors: gradientColors,
            barWidth: 5,
            belowBarData: BarAreaData(
              show: true,
              colors:
                  gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: gradientColors.first,
                  strokeWidth: 2,
                  strokeColor: gradientColors.last,
                );
              },
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueAccent,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem(
                  '${barSpot.y.toStringAsFixed(2)}',
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
