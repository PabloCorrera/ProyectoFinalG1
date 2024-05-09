import 'package:flutter/material.dart';

class GarageHome extends StatelessWidget {
  const GarageHome({Key? key}) : super(key: key);
  static const String name = 'GarageHome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido Dueño'),
      ),
      body: Center(
        child: Text(
          '¡Bienvenido dueño!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
