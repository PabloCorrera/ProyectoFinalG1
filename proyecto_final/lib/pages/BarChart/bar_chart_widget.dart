import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
  final int ultimos28;
  final List<int> arrayCantidades;
  final List<double> arrayRecaudaciones;
  final double interval;

  BarChartWidget({
    Key? key,
    required this.ultimos28,
    required this.arrayCantidades,
    required this.arrayRecaudaciones,
    required this.interval,
  }) : super(key: key);

  final double barWidth = 60;

  @override
  Widget build(BuildContext context) {
    if (this.ultimos28 == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel,
              color: Colors.red,
              size: 120,
            ),
            SizedBox(height: 20),
            Text(
              'Sin reservas',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        maxY: arrayCantidades.reduce((value, element) => value > element ? value : element).toDouble() * 1.5,
        minY: 0,
        groupsSpace: 12,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String additionalValue = '\nRecaudado: \$${arrayRecaudaciones[groupIndex].toString()}';
              return BarTooltipItem(
                'Reservas: ${rod.y.round()}$additionalValue',
                TextStyle(
                  color: const Color.fromARGB(255, 7, 7, 0),
                  fontWeight: FontWeight.bold,
                  fontSize: 18, 
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(
            showTitles: true,
            getTextStyles: (context, value) => TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            margin: 10,
            getTitles: (double value) {
              switch (value.toInt()) {
                case 0:
                  return '1er Sem';
                case 1:
                  return '2da Sem';
                case 2:
                  return '3er Sem';
                case 3:
                  return '4ta Sem';
                default:
                  return '';
              }
            },
          ),
leftTitles: SideTitles(
            showTitles: true,
            getTextStyles: (context, value) => TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            margin: 8,
            reservedSize: 30,
            interval: interval, 
            getTitles: (value) {
              return value.toInt().toString();
            },
          ),
          rightTitles: SideTitles(showTitles: false),
        ),
        gridData: FlGridData(
          checkToShowHorizontalLine: (value) => value % 5 == 0,
          getDrawingHorizontalLine: (value) {
            if (value == 0) {
              return FlLine(
                color: const Color(0xff363753),
                strokeWidth: 3,
              );
            } else {
              return FlLine(
                color: const Color(0xff2a2747),
                strokeWidth: 0.8,
              );
            }
          },
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                y: arrayCantidades[0].toDouble(),
                width: barWidth,
                colors: [const Color(0xFF2C7F8C)],
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                y: arrayCantidades[1].toDouble(),
                width: barWidth,
                colors: [const Color(0xFF2C7F8C)],
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                y: arrayCantidades[2].toDouble(),
                width: barWidth,
                colors: [const Color(0xFF2C7F8C)],
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                y: arrayCantidades[3].toDouble(),
                width: barWidth,
                colors: [const Color(0xFF2C7F8C)],
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
