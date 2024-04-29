import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:proyecto_final/entities/user.dart';
import 'package:proyecto_final/services/database_sevice.dart'; // Importa el servicio de base de datos

class UsuarioHome extends StatelessWidget {
  final String userMail;

  UsuarioHome({Key? key, required this.userMail}) : super(key: key);
  static const String name = 'usuarioHome';
  String? emailUsuario = FirebaseAuth.FirebaseAuth.instance.currentUser?.email;

  // Instancia de DatabaseService
  final DatabaseService _databaseService = DatabaseService();
 

  @override
  Widget build(BuildContext context) {
    // Llama al método getUserByEmail para obtener el usuario correspondiente al correo electrónico actual
    _databaseService.getUserByEmail(emailUsuario!).then((user) {
      // Haz algo con el usuario obtenido, como mostrar su nombre en la pantalla
      if (user != null) {
        print('El usuario actual es: ${user.nombre}');
      } else {
        print('No se encontró ningún usuario con el correo electrónico actual');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¡Bienvenido, $emailUsuario!',
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
