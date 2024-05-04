import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UsuarioCocheraHome extends StatelessWidget {
  const UsuarioCocheraHome({super.key});
  static const String name = 'UsuarioCocheraHome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HOME COCHERA'), // Aquí estableces el título del AppBar
      ),
      body: Center(
        child: Text('Contenido de la página de la cochera'), // Agrega aquí el contenido de la página
      ),
    );
  }
}