import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/models/constant.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  ThemeData getTheme() {
    return ThemeData(
        primaryColor: botonReservaCancel,
        backgroundColor: magnolia,
        secondaryHeaderColor: logoTitulos,
        indicatorColor: botonfunc,
        bottomAppBarColor: paynesGray,
        textTheme: const TextTheme(
          titleLarge: primaryTextStyle,
          bodyMedium: secondaryTextStyle,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          color: botonReservaCancel,
        ));
  }
}
