import 'package:flutter/material.dart';

class UsuarioHome extends StatelessWidget {
  final String userMail;

  const UsuarioHome({Key? key, required this.userMail}) : super(key: key);
  static const String name = 'usuarioHome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¡Bienvenido, $userMail!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // Puedes agregar más widgets aquí si es necesario
          ],
        ),
      ),
    );
  }
}
