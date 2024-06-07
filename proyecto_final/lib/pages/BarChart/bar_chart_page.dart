
import 'package:flutter/material.dart';
import 'package:proyecto_final/pages/BarChart/bar_chart_widget.dart';

class BarChartPage extends StatelessWidget {

  BarChartPage({
    Key? key,
    required this.ultimos30,
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

  final int ultimos30;
  late final List<int> arrayCantidades;
  late final List<double> arrayRecaudaciones;


  @override
  Widget build(BuildContext context) => Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        color: Color.fromARGB(255, 151, 151, 176),
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: BarChartWidget(

                ultimos30: ultimos30,
                arrayCantidades : arrayCantidades,
                arrayRecaudaciones: arrayRecaudaciones,
          ),
        ),
      );
}
