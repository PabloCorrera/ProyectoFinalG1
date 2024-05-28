import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  LineChartWidget({
    Key? key,
    required this.ultimos30,
    required this.ultimos60,
    required this.ultimos90,
    required this.sesentaDias,
    required this.noventaDias
  }) : super(key: key);

  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  final int ultimos30;
  final int ultimos60;
  final int ultimos90;
  final bool sesentaDias;
  final bool noventaDias;

  double get maxY {
    double maxReservas = [ultimos30.toDouble(), ultimos60.toDouble(), ultimos90.toDouble()].reduce((a, b) => a > b ? a : b);
    return (maxReservas * 1.5).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) => LineChart(
        LineChartData(
          backgroundColor: const Color(0xffE0E0E0), 
          minX: 0,
          maxX: sesentaDias ? 8 : 2, 
          minY: 0,
          maxY: ultimos90 == 0 ? 2 : maxY, 
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
                if (sesentaDias && noventaDias) {
                  switch (value.toInt()) {
                    case 1:
                      return 'Ult 90 días';
                    case 4:
                      return 'Ult 60 días';
                    case 7:
                      return 'Ult 30 días';
                  }
                }
                  if (sesentaDias && !noventaDias) {
                  switch (value.toInt()) {
                    case 2:
                      return 'Ult 60 días';
                    case 6:
                      return 'Ult 30 días';
      
                  }
                } else {
                  if (value.toInt() == 1) {
                    return 'Ult 30 días';
                  }
                }
                return '';
              },
            ),
            leftTitles: SideTitles(
              showTitles: true,
              getTextStyles: (context, value) => const TextStyle(
                color: Color(0xff67727d),
                fontWeight: FontWeight.bold, 
                fontSize: 10, 
              ),
              reservedSize: 35,
              margin: 10, 
              interval: 10,
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
  spots: sesentaDias
                  ? noventaDias
                      ? [
                          FlSpot(0, 0), 
                          FlSpot(
                              1,
                              ultimos90
                                  .toDouble()), 
                          FlSpot(
                              4,
                              ultimos60
                                  .toDouble()), 
                          FlSpot(
                              7,
                              ultimos30
                                  .toDouble()),
                        ]
                      : [
                          FlSpot(0, 0), 
                          FlSpot(
                              2,
                              ultimos60
                                  .toDouble()), 
                          FlSpot(
                              6,
                              ultimos30
                                  .toDouble()), 
                        ]
                  : [
                      FlSpot(0, 0),
                      FlSpot(
                          1,
                          ultimos30
                              .toDouble()), 
                    ],
              isCurved: true,
              colors: gradientColors,
              barWidth: 5,
              belowBarData: BarAreaData(
                show: true,
                colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
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
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
          ),
        ),
      );
}