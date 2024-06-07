import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/pages/BarChart/bar_titles.dart';

class BarChartWidget extends StatelessWidget {
  final int ultimos30;
  final List<int> arrayCantidades;
  final List<double> arrayRecaudaciones;

  BarChartWidget({
    Key? key,
    required this.ultimos30,
    required this.arrayCantidades,
    required this.arrayRecaudaciones,
  }) : super(key: key);

  final double barWidth = 60;

  @override
  Widget build(BuildContext context) => BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          maxY: arrayCantidades.reduce((value, element) => value > element ? value : element).toDouble() * 1.3,
          minY: 0,
          groupsSpace: 12,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String additionalValue = '\n\$${arrayRecaudaciones[groupIndex].toString()}';
                return BarTooltipItem(
                  '${rod.y.round()}$additionalValue',
                  TextStyle(
                    color: const Color.fromARGB(255, 7, 7, 0),
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: BarTitles.getTopBottomTitles(),
            bottomTitles: SideTitles(
              showTitles: true,
              getTextStyles: (context, value) => TextStyle(
                color: Colors.black, // Color de los títulos de abajo
                fontWeight: FontWeight.bold,
                fontSize: 14, // Tamaño de los títulos de abajo
              ),
              margin: 10,
              getTitles: (double value) {
                // Aquí puedes personalizar los títulos según tus datos
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
                color: Colors.black, // Color de los títulos del eje Y
                fontWeight: FontWeight.bold,
                fontSize: 14, // Tamaño de los títulos del eje Y
              ),
              margin: 8,
              reservedSize: 30, // Espacio reservado para los títulos del eje Y
              getTitles: (value) {
                // Aquí puedes personalizar las etiquetas según tus datos
                return value.toInt().toString();
              },
            ),
            rightTitles: SideTitles(showTitles: false), // Deshabilita los títulos en el eje Y derecho
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
                  width: barWidth, // Ancho de las barras
                  colors: [const Color(0xFF2C7F8C)], // Color de la barra
                  borderRadius: BorderRadius.zero, // Barras rectas
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  y: arrayCantidades[1].toDouble(),
                  width: barWidth, // Ancho de las barras
                  colors: [const Color(0xFF2C7F8C)], // Color de la barra
                  borderRadius: BorderRadius.zero, // Barras rectas
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  y: arrayCantidades[2].toDouble(),
                  width: barWidth, // Ancho de las barras
                  colors: [const Color(0xFF2C7F8C)], // Color de la barra
                  borderRadius: BorderRadius.zero, // Barras rectas
                ),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  y: arrayCantidades[3].toDouble(),
                  width: barWidth, // Ancho de las barras
                  colors: [const Color(0xFF2C7F8C)], // Color de la barra
                  borderRadius: BorderRadius.zero, // Barras rectas
                ),
              ],
            ),
          ],
        ),
      );
}