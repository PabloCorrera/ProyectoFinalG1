import 'package:flutter/material.dart';
import 'package:proyecto_final/pages/BarChart/bar_chart_widget.dart';

class BarChartPage extends StatelessWidget {
  BarChartPage({
    Key? key,
    required this.ultimos28,
    List<int>? arrayCantidades,
    List<double>? arrayRecaudaciones,
  }) : super(key: key) {
    this.arrayCantidades = arrayCantidades ?? [];
    this.arrayRecaudaciones = arrayRecaudaciones ?? [];
  }

  final List<Color> gradientColors = [
    const Color(0xFF2C7F8C),
    Color.fromARGB(255, 98, 189, 203),
  ];

  final int ultimos28;
  late final List<int> arrayCantidades;
  late final List<double> arrayRecaudaciones;

  @override
  Widget build(BuildContext context) {
    double maxY = arrayCantidades.reduce((value, element) => value > element ? value : element).toDouble() * 1.5;
    double interval = _calculateInterval(maxY);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
     // color: Color.fromARGB(255, 151, 151, 176),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
  
            SizedBox(height: 8),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  BarChartWidget(
                    ultimos28: ultimos28,
                    arrayCantidades: arrayCantidades,
                    arrayRecaudaciones: arrayRecaudaciones,
                    interval: interval,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

double _calculateInterval(double maxY) {
    if (maxY < 40) {
      return 2;
    } else if (maxY >= 40 && maxY <= 60) {
      return 5;
    } else {
      return 20;
    }
  }
}