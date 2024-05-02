import 'package:flutter/material.dart';

class UsuarioHome extends StatelessWidget {
  const UsuarioHome({Key? key}) : super(key: key);
  static const String name = 'UsuarioHome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola Usuario Consumidor'),
      ),
      body: Center(
        child: Text(
          '¡Hola usuario consumidor!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
