import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class BarTitles {
  static SideTitles getTopBottomTitles() => SideTitles(
    showTitles: false,
    getTextStyles: (BuildContext context, double value) => TextStyle(color: Color.fromARGB(255, 4, 0, 0), fontSize: 10),
    margin: 50,
  );

  static SideTitles getSideTitles() => SideTitles(
    showTitles: true,
    getTextStyles: (BuildContext context, double value) => TextStyle(color: Color.fromARGB(255, 4, 0, 0), fontSize: 18),
    rotateAngle: 90,
    interval: 1, // Cambiado el intervalo para mostrar todos los títulos
    margin: 10,
    reservedSize: 30,
    getTitles: (double value) => '${value.toInt()}', // Devuelve todos los valores como títulos
  );
}