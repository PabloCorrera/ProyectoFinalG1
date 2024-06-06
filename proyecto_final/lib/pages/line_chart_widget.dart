import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  BarChartWidget({
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

  int get cantidadMayorPorSemana {
    if (arrayCantidades.isEmpty) {
      return 0;
    }
    return arrayCantidades.reduce((a, b) => a > b ? a : b);
  }

  double get maxY {
    return (cantidadMayorPorSemana * 1.5).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final double maxYValue = maxY == 0 ? 5 : maxY;
    final double interval = maxYValue / 5 > 0 ? maxYValue / 5 : 1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return BarChart(
            BarChartData(
              backgroundColor: const Color(0xffE0E0E0),
              minY: 0,
              maxY: maxYValue,
              barGroups: List.generate(
                arrayCantidades.length,
                (index) => BarChartGroupData(
                  x: index * 2 + 1,
                  barRods: [
                    BarChartRodData(
                      y: arrayCantidades[index].toDouble(),
                      colors: gradientColors,
                      width: 60, // Ancho de las barras aumentado
                      borderRadius: BorderRadius.circular(4),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        y: maxYValue,
                        colors: [const Color(0xffE0E0E0)],
                      ),
                      rodStackItems: [
                        BarChartRodStackItem(0, arrayCantidades[index].toDouble(), gradientColors.first),
                      ],
                    ),
                  ],
                ),
              ),
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
                    switch (value.toInt()) {
                      case 1:
                        return '1er sem';
                      case 3:
                        return '2da sem';
                      case 5:
                        return '3era sem';
                      case 7:
                        return '4ta sem';
                      default:
                        return '';
                    }
                  },
                ),
                leftTitles: SideTitles(
                  showTitles: false, // Ocultar los títulos del eje Y
                ),
              ),
              gridData: FlGridData(
                show: false,
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 2),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.blueAccent,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.y.toStringAsFixed(2),
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                touchCallback: (BarTouchResponse touchResponse) {
                  if (touchResponse.spot != null) {
                    int touchedBarGroupIndex = touchResponse.spot!.touchedBarGroupIndex;
                    String week = '';
                    switch (touchedBarGroupIndex) {
                      case 0:
                        week = 'primer';
                        break;
                      case 1:
                        week = 'segunda';
                        break;
                      case 2:
                        week = 'tercer';
                        break;
                      case 3:
                        week = 'cuarta';
                        break;
                      default:
                        week = '';
                        break;
                    }
                    if (week.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Hola $week semana'),
                            content: Text('Has tocado el punto de intersección en la $week semana.'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cerrar'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}