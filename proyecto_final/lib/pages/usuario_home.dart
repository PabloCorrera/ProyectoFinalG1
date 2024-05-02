import 'package:flutter/material.dart';

class UsuarioHome extends StatelessWidget {
  const UsuarioHome({Key? key}) : super(key: key);
  static const String name = 'UsuarioHome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Usuario'),
      ),
      body: Center(
        child: Text(
          '¡Bienvenido a la página de inicio de usuario!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
